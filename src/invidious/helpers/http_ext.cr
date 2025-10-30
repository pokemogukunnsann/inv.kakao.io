require "http/cookie" # HTTP::Cookie::parse を使うために必要

# HTTP::Cookies クラスを拡張します
class HTTP::Cookies
  # 文字列を受け取ってクッキーコレクションを生成する new メソッドを定義
  # 修正前: def initialize(@cookies = [] of HTTP::Cookie, str : String = "") 
  # 修正後: @cookies の初期化を Hash に変更します
  def initialize(@cookies = Hash(String, HTTP::Cookie).new, str : String = "")
    unless str.empty?
      str.split(';').each do |cookie_string|
        cookie_string = cookie_string.strip
        if cookie_string.includes?('=')
          if cookie = HTTP::Cookie.parse(cookie_string)
            # Hash に追加する際は、キー（クッキー名）が必要です
            @cookies[cookie.name] = cookie
          end
        end
      end
    end
  end
  # 引数なしの既存の new メソッドもオーバーロードで保持
  def initialize(@cookies = [] of HTTP::Cookie)
  end
end

puts "HTTPExt: HTTP::Cookies.new(string) ヘルパーメソッドを作成しました。"
# HTTPExt: HTTP::Cookies.new(string) ヘルパーメソッドを作成しました。
