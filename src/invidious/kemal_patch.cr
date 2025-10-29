# src/invidious/kemal_patch.cr

# API_ONLY=1 の場合は、Preferences と Invidious::User を除外してマクロを再定義する
require "kemal"

module Kemal
  class Context
    # 元々 lib/kemal/src/kemal/ext/context.cr で定義されているマクロを上書き
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
