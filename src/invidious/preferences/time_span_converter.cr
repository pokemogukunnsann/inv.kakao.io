require "time" # Time::Span を使うために必要

module Preferences
  # YAMLで "30.minutes" のような文字列を Time::Span に変換するコンバータ
  class TimeSpanConverter
    def self.from_yaml(ctx : YAML::ParseContext, node : YAML::Nodes::Node)
      # YAMLノードがスカラー（文字列など）であることを確認
      case node
      when YAML::Nodes::Scalar
        begin
          # 文字列を Time::Span に変換するロジック（Invidiousの既存のヘルパーを利用する可能性が高い）
          # 今回は直接的なヘルパーがないと仮定し、暫定的に Time::Span.parse を使用
          Time::Span.parse(node.value)
        rescue ArgumentError
          # 変換失敗時はエラーを出す
          raise YAML::ParseException.new("Invalid Time::Span format: #{node.value}", node.start_line, node.start_column)
        end
      else
        # スカラーノードでない場合はエラー
        raise YAML::ParseException.new("Expected a scalar value for Time::Span", node.start_line, node.start_column)
      end
    end
  end
end

puts "TimeSpanConverter: Preferences::TimeSpanConverter を作成しました。"
