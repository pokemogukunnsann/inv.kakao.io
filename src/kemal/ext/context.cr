# src/kemal/ext/context.cr

require "../context" # Kemal::Contextが定義されているファイルを require

module Kemal
  class Context
    # オリジナルと同名同場所でマクロを再定義し、強制的に上書きする
    macro finished
      # API_ONLY ビルドの場合は Preferences と Invidious::User を除外
      alias StoreTypes = Union(Nil, String, Int32, Int64, Float64, Bool, Array(String)
        {% unless flag?(:api_only) %}
          , Preferences
          , Invidious::User
        {% end %}
      )
      @store = {} of String => StoreTypes
    end
  end
end
