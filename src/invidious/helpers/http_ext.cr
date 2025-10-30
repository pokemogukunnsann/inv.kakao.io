require "http/cookie" # HTTP::Cookie::parse を使うために必要

# HTTP::Cookies クラスを拡張します
class HTTP::Cookies
  # 文字列を受け取ってクッキーコレクションを生成する new メソッドを定義
  # YAMLコンバータはこれを利用し、クッキー文字列を解析します。
  def initialize(@cookies = [] of HTTP::Cookie, str : String = "")
    # 文字列が空でなければ解析する
    unless str.empty?
      str.split(';').each do |cookie_string|
        cookie_string = cookie_string.strip
        if cookie_string.includes?('=')
          # 単一のクッキー文字列として解析
          if cookie = HTTP::Cookie.parse(cookie_string)
            @cookies << cookie
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
