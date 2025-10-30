require "time"
require "uri" # URIConverterで必要
require "socket" # FamilyConverterで必要
require "http/cookie" # StringToCookiesで必要

# Preferenceはclassであるため、classで拡張します。
class Preferences
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

  # 4. クッキー文字列を HTTP::Cookies オブジェクトに変換するコンバータ
  class StringToCookies
    def self.from_yaml(ctx : YAML::ParseContext, node : YAML::Nodes::Node)
      case node
      when YAML::Nodes::Scalar
        HTTP::Cookies.parse(node.value) # クッキー文字列を解析してHTTP::Cookiesを生成
      else
        raise YAML::ParseException.new("Expected a scalar value for cookies", node.start_line, node.start_column)
      end
    end
  end
end

puts "Converters: URIConverter, FamilyConverter, StringToCookies を作成しました。"
# Converters: URIConverter, FamilyConverter, StringToCookies を作成しました。
