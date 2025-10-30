# src/invidious/kemal_noop_patch.cr

# require "kemal" の直後でこれを require します

module Kemal
  class Context
    # 既存の macro finished を無効化（何もしないマクロとして再定義）
    # これにより、オリジナルのマクロ（Preferencesに依存）は展開されなくなります。
    macro finished
      # API_ONLY ビルドの場合は空にする
      {% if flag?(:api_only) %}
        # Do nothing (マクロを展開しない)
      {% else %}
        # API_ONLY ではない場合は、オリジナルのマクロをそのまま展開（互換性のため）
        {{ super }}
      {% end %}
    end
  end
end
