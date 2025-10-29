require "http/client"

# A basic pool similar to the one provided by crystal-db but without any
# of the database specific logic. It is mainly used as a replacement
# for those who wish to run Invidious without a database.
#
# It is only used for the YouTube and Companion clients
class HttpPool(T)
  class Options
    getter initial_pool_size
    getter max_pool_size
    getter max_idle_pool_size
    getter checkout_timeout

    def initialize(
      @initial_pool_size : Int32 = 0,
      @max_pool_size : Int32 = 1,
      @max_idle_pool_size : Int32 = 1,
      @checkout_timeout : Float64 = 5.0
    )
    end
  end

  # Pool of available connections
  private getter pool = [] of T
  # Pool of waiting fibers
  private getter queue = [] of Fiber
  # Max number of active connections
  private getter max_pool_size : Int32
  # Max number of idle connections
  private getter max_idle_pool_size : Int32
  # Time in seconds to wait for a connection to be available
  private getter checkout_timeout : Float64
  # Number of currently active connections
  private getter active_connections = 0

  private getter make_connection : (-> T)

  # Initializes a new instance of the pool
  #
  # The pool will create connections using the block passed to this method
  def initialize(@max_pool_size, @max_idle_pool_size, @checkout_timeout, &@make_connection)
  end

  # Initializes a new instance of the pool
  #
  # The pool will create connections using the block passed to this method
  def initialize(options : Options, &@make_connection)
    @max_pool_size = options.max_pool_size
    @max_idle_pool_size = options.max_idle_pool_size
    @checkout_timeout = options.checkout_timeout
  end

  # Returns a connection to the caller
  def checkout : T
    while pool.empty?
      if active_connections < max_pool_size
        @active_connections += 1
        return make_connection.call
      end

      # Wait until a connection is available
      begin
        Fiber.yield_timeout(checkout_timeout)
      rescue ex : TimeoutException
        raise TimeoutError.new("Timed out while waiting for a connection")
      end

      # If the connection we wanted to checkout is now available, we can
      # just proceed to the `unless pool.empty?` check. If it's not,
      # we go to the start of the loop and either wait again or make a new
      # connection.
      unless pool.empty?
        # A connection became available while we were waiting
        conn = pool.pop
        @active_connections += 1
        return conn
      end
    end

    # There are available connections in the pool
    conn = pool.pop
    @active_connections += 1
    return conn
  end

  # Releases a connection back to the pool
  def release(conn : T)
    @active_connections -= 1

    if pool.size < max_idle_pool_size
      pool << conn
    end

    # Resume the next waiting fiber
    if next_fiber = queue.shift?
      next_fiber.resume
    end
  end

  # Closes all connections in the pool
  def close
    # Nothing to do here
  end
end
