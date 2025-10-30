require "time"
require "uri" # URIConverterで必要
require "socket" # FamilyConverterで必要
require "http/cookie" # StringToCookiesで必要
require "yaml"
#require "yaml/serializable"
require "./time_span_converter"
require "../helpers/http_ext" # または他の必要なファイル

# Preferenceはclassであるため、classで拡張します。
class Preferences
#  require "yaml"
  # 1. YAMLで "30.minutes" のような文字列を Time::Span に変換するコンバータ (前回作成済み)
  class TimeSpanConverter
    def self.from_yaml(ctx : YAML::ParseContext, node : YAML::Nodes::Node)
      case node
      when YAML::Nodes::Scalar
        begin
          Time::Span.parse(node.value) # time_ext.crで定義したメソッドを使用
        rescue ArgumentError
          raise YAML::ParseException.new("Invalid Time::Span format: #{node.value}", node.start_line, node.start_column)
        end
      else
        raise YAML::ParseException.new("Expected a scalar value for Time::Span", node.start_line, node.start_column)
      end
    end
  end

  # 2. URIの文字列を URI オブジェクトに変換するコンバータ
  class URIConverter
    def self.from_yaml(ctx : YAML::ParseContext, node : YAML::Nodes::Node)
      case node
      when YAML::Nodes::Scalar
        URI.parse(node.value)
      else
        raise YAML::ParseException.new("Expected a scalar value for URI", node.start_line, node.start_column)
      end
    end
  end

  # 3. IPアドレスファミリーの文字列を Socket::Family enum に変換するコンバータ
  class FamilyConverter
    def self.from_yaml(ctx : YAML::ParseContext, node : YAML::Nodes::Node)
      case node
      when YAML::Nodes::Scalar
        case node.value.downcase
        when "ipv4" then Socket::Family::INET
        when "ipv6" then Socket::Family::INET6
        when "unspec" then Socket::Family::UNSPEC
        else
          raise YAML::ParseException.new("Invalid Socket::Family value: #{node.value}", node.start_line, node.start_column)
        end
      else
        raise YAML::ParseException.new("Expected a scalar value for Socket::Family", node.start_line, node.start_column)
      end
    end
  end
  #require "yaml"
  # 4. クッキー文字列を HTTP::Cookies オブジェクトに変換するコンバータ
  class StringToCookies
  # include YAML::Serializable::TypeConverter # 👈 これを削除！
  
  # from_yamlメソッドを他のコンバータと同じように定義します
  def self.from_yaml(ctx : YAML::ParseContext, node : YAML::Nodes::Node)
    case node
    when YAML::Nodes::Scalar
      # HTTP::Cookies.from_string(node.value) はあなたのヘルパーが追加しているものかもしれません
      # 標準的な実装では、HTTP::Cookie.parse の方が一般的です
      begin
        # 既存のコードを尊重:
        return HTTP::Cookies.from_string(node.value)
      rescue NoMethodError # from_stringがない場合（ヘルパーが未ロードなど）
        # 標準的なHTTP/Cookieの解析を使用する場合：
        # return HTTP::Cookie.parse(node.value)
        raise YAML::ParseException.new("Cookie parsing failed (check if http_ext is loaded): #{node.value}", node.start_line, node.start_column)
      end
    else
      raise YAML::ParseException.new("Expected a scalar value for Cookies", node.start_line, node.start_column)
    end
  end
end
  
