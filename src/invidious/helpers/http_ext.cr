require "http/cookie" 

# HTTP::Cookies クラスを拡張します
class HTTP::Cookies
  # 文字列を受け取ってクッキーコレクションを生成する new メソッドを定義
  # @cookies の型を Array から Hash に修正し、解析ロジックも修正
  def initialize(@cookies = Hash(String, HTTP::Cookie).new, str : String = "")
    puts "HTTPExt: HTTP::Cookies.new(string) called for parsing cookies."
    unless str.empty?
      str.split(';').each do |cookie_string|
        cookie_string = cookie_string.strip
        if cookie_string.includes?('=')
          # 単一のクッキー文字列として解析
          if cookie = HTTP::Cookie.parse(cookie_string)
            # Hash に追加: キーはクッキー名
            @cookies[cookie.name] = cookie
          end
        end
      end
    end
  end

  # 引数なしの既存の new メソッドもオーバーロードで保持
  def initialize(@cookies = Hash(String, HTTP::Cookie).new)
    puts "HTTPExt: HTTP::Cookies.new() called (empty init)."
  end
end

puts "HTTPExt: HTTP::Cookies 拡張ヘルパーメソッドが定義されました。"
