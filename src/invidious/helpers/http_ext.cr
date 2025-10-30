# src/invidious/helpers/http_ext.cr の修正案

require "http/cookie" 

# HTTP::Cookies クラスを拡張します
class HTTP::Cookies
  # 文字列を受け取って新しい HTTP::Cookies インスタンスを生成するクラスメソッド
  def self.from_string(str : String) : self
    # Hashで初期化された新しいインスタンスを生成
    cookies = self.new 
    
    puts "HTTPExt: HTTP::Cookies.from_string(#{str.size} bytes) called."
    
    unless str.empty?
      str.split(';').each do |cookie_string|
        cookie_string = cookie_string.strip
        if cookie_string.includes?('=')
          # 単一のクッキー文字列として解析
          if cookie = HTTP::Cookie.parse(cookie_string)
            # Hash に追加: キーはクッキー名
            cookies.instance_variable_get("@cookies")[cookie.name] = cookie
          end
        end
      end
    end
    
    cookies
  end
end
