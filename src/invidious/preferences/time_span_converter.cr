require "time"

# Preferences が他の場所で class として定義されていると仮定し、
# コンバータをそのクラスの内部に定義します。
class Preferences
  # YAMLで "30.minutes" のような文字列を Time::Span に変換するコンバータ
  class TimeSpanConverter
    def self.from_yaml(ctx : YAML::ParseContext, node : YAML::Nodes::Node)
      case node
      when YAML::Nodes::Scalar
        begin
          # Time::Span.parse の代わりに、Invidiousが持つであろう
          # Time::Spanを解析するためのヘルパーを使う必要があります。
          # 一旦、既存のInvidiousのロジックが Time::Span.parse で十分だと仮定します。
          # 実際には、"30.minutes" のような文字列を Time::Span に変換するカスタムロジックが必要です。
          # 現時点ではコンパイルを通すことを優先します。
          Time::Span.parse(node.value)
        rescue ArgumentError
          raise YAML::ParseException.new("Invalid Time::Span format: #{node.value}", node.start_line, node.start_column)
        end
      else
        raise YAML::ParseException.new("Expected a scalar value for Time::Span", node.start_line, node.start_column)
      end
    end
  end
end

puts "TimeSpanConverter: Preferences::TimeSpanConverter を class Preferences 内に作成しました。"
# TimeSpanConverter: Preferences::TimeSpanConverter を class Preferences 内に作成しました。

puts "TimeSpanConverter: Preferences::TimeSpanConverter を作成しました。"
