# src/invidious/kemal_final_patch.cr

puts "⭐ [FINAL PATCH] Kemal::Context#finished マクロの最終上書きを試みます！"

module Kemal
  class Context
    macro finished
      {% if flag?(:api_only) %}
        puts "  👉 [FINAL PATCH] Kemal::Context#finished マクロを無効化 (No-Op) します。"
      {% else %}
        puts "  👉 [FINAL PATCH] Kemal::Context#finished マクロをオリジナルで展開します。"
        {{ super }}
      {% end %}
    end
  end
end
