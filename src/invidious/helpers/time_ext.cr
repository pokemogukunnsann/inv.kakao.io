require "time"

# Time::Span クラスを拡張します
struct Time::Span
  # 独自に .parse クラスメソッドを定義します。
  # YAMLファイルからの "30.minutes" のような文字列を Time::Span に変換するのが目的です。
  # NOTE: これはシンプルな実装例であり、オリジナルの Invidious のロジックとは異なる可能性があります。
  def self.parse(value : String)
    case value
    when /^\s*(\d+)\s*\.\s*minutes\s*$/i # "30.minutes"
      minutes = $1.to_i
      return Time::Span.new(minutes: minutes)
    when /^\s*(\d+)\s*\.\s*hours\s*$/i # "1.hours"
      hours = $1.to_i
      return Time::Span.new(hours: hours)
    when /^\s*(\d+)\s*\.\s*days\s*$/i # "7.days"
      days = $1.to_i
      return Time::Span.new(days: days)
    # 必要に応じて他の単位（seconds, weeks, etc.）も追加
    else
      # パターンに一致しない場合は、一般的な Time::Span.parse の代わりに
      # ArgumentError を発生させ、TimeSpanConverter にエラーを処理させます。
      raise ArgumentError.new("Invalid time span string format: #{value}")
    end
  end
end

puts "TimeExt: Time::Span.parse ヘルパーメソッドを作成しました。"
# TimeExt: Time::Span.parse ヘルパーメソッドを作成しました。
