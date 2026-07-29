# Claude Code CLI — alias y wrappers de modelos alternos
# Las API keys viven SIEMPRE en el Keychain de macOS, NUNCA en este archivo.
# Este archivo se versiona en Csierra088/dotfiles y se carga vía `source` desde ~/.zshrc.

# Claude Code — skip permissions por default
alias claude='claude --dangerously-skip-permissions'

# MiniMax M3 en terminal — mismo REPL que `claude`, pero con MiniMax M3 de modelo.
# Guarda la key UNA vez:  security add-generic-password -a "$USER" -s minimax_api_key -w
# Uso:  claude-mm   (igual que `claude`, acepta los mismos args)
claude-mm() {
  local key
  key=$(security find-generic-password -a "$USER" -s minimax_api_key -w 2>/dev/null)
  if [[ -z "$key" ]]; then
    echo "Falta la key de MiniMax. Guárdala una vez con:"
    echo '  security add-generic-password -a "$USER" -s minimax_api_key -w'
    return 1
  fi
  ANTHROPIC_BASE_URL="https://api.minimax.io/anthropic" \
  ANTHROPIC_AUTH_TOKEN="$key" \
  ANTHROPIC_MODEL="MiniMax-M3" \
  ANTHROPIC_SMALL_FAST_MODEL="MiniMax-M3" \
  ~/.local/bin/claude --dangerously-skip-permissions --model MiniMax-M3 "$@"
}

# DeepSeek V4 Pro via Claude Code CLI.
# Guarda la key UNA vez:  security add-generic-password -a "$USER" -s deepseek_api_key -w
# Uso:  claude-ds   (igual que `claude`, acepta los mismos args)
# IMPORTANTE: usar los nombres de modelo NATIVOS de DeepSeek (deepseek-v4-pro / deepseek-v4-flash).
# NO usar ids Anthropic (claude-opus-4-8, ni con sufijo [1m]): EMPÍRICAMENTE (jun 9 2026, probado por
# Carlos) el CLI reconoce el id Anthropic y, con una sesión de Claude logueada, se va a la API REAL de
# Anthropic ignorando ANTHROPIC_BASE_URL → termina usando Claude, NO DeepSeek. El truco del [1m] para
# abrir 1M de contexto NO sirve aquí por eso. Trade-off aceptado: el CLI muestra 200K de ventana, pero
# de verdad usa deepseek-v4-pro (que internamente sí soporta 1M en su API).
claude-ds() {
  local key
  key=$(security find-generic-password -a "$USER" -s deepseek_api_key -w 2>/dev/null)
  if [[ -z "$key" ]]; then
    echo "Falta la key de DeepSeek. Guárdala una vez con:"
    echo '  security add-generic-password -a "$USER" -s deepseek_api_key -w'
    return 1
  fi
  ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic" \
  ANTHROPIC_API_KEY="$key" \
  ANTHROPIC_AUTH_TOKEN="$key" \
  ANTHROPIC_MODEL="deepseek-v4-pro" \
  ANTHROPIC_SMALL_FAST_MODEL="deepseek-v4-flash" \
  ~/.local/bin/claude --dangerously-skip-permissions --model deepseek-v4-pro "$@"
}

# z.ai (Zhipu) GLM-5.2 via Claude Code CLI.
# Guarda la key UNA vez:  security add-generic-password -a "$USER" -s zai_api_key -w
# Uso:  claude-z   (igual que `claude`, acepta los mismos args)
# Endpoint Anthropic-compatible de z.ai: https://api.z.ai/api/anthropic
# Modelo principal: glm-5.2 (flagship más actual, jun 2026, ventana 1M tokens, MoE 753B/40B activos).
# Modelo rápido: glm-4.5-air (variant Air documentada por z.ai como mapeo de Haiku).
# IMPORTANTE: usar los nombres de modelo NATIVOS de z.ai (glm-5.2 / glm-4.5-air), NO ids Anthropic:
# como con DeepSeek, el CLI reconoce un id Anthropic y se va a la API REAL de Claude ignorando
# ANTHROPIC_BASE_URL. Con ids GLM nativos el ruteo a z.ai es correcto.
claude-z() {
  local key
  key=$(security find-generic-password -a "$USER" -s zai_api_key -w 2>/dev/null)
  if [[ -z "$key" ]]; then
    echo "Falta la key de z.ai. Guárdala una vez con:"
    echo '  security add-generic-password -a "$USER" -s zai_api_key -w'
    return 1
  fi
  ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic" \
  ANTHROPIC_API_KEY="$key" \
  ANTHROPIC_AUTH_TOKEN="$key" \
  ANTHROPIC_MODEL="glm-5.2" \
  ANTHROPIC_SMALL_FAST_MODEL="glm-4.5-air" \
  ~/.local/bin/claude --dangerously-skip-permissions --model glm-5.2 "$@"
}

# Kimi Code (suscripción Kimi, NO la API de pago por token) via Claude Code CLI.
# Doc oficial del producto: https://www.kimi.com/code/docs/en/third-party-tools/claude-code.html
# Verificado empíricamente el 29-jul-2026: HTTP 200 y respuesta real de Kimi en los 4 modelos.
#
# ⚠️ OJO CON EL ENDPOINT — hay DOS productos distintos de Moonshot y NO comparten credenciales:
#   1. Kimi API Platform (platform.moonshot.ai) → base `https://api.moonshot.ai/anthropic`,
#      pago por token, keys de platform.kimi.ai/console/api-keys.
#   2. Kimi Code / "KFC" (www.kimi.com/code/console) → base `https://api.kimi.com/coding/`,
#      incluido en la SUSCRIPCIÓN, keys con prefijo `sk-kimi-`.  ← ESTE es el de Carlos.
# Una key del producto 2 contra el endpoint del producto 1 da `401 Invalid Authentication`
# (probado). Si algún día da 401, lo primero que hay que revisar es de qué consola salió la key.
#
# Guarda la key UNA vez:  security add-generic-password -a "$USER" -s moonshot_api_key -U -w
# Uso:  claude-kimi                              → k3 con ventana 1M (default)
#       KIMI_MODEL=k3-256k     claude-kimi       → K3 con 256K, para tareas chicas
#       KIMI_MODEL=k2.7-code   claude-kimi       → K2.7 Code, 256K
#       KIMI_MODEL=kimi-for-coding claude-kimi   → modelo del plan Andante, 256K
#
# Notas del proveedor:
#  - El `[1m]` de `k3[1m]` es convención de Kimi Code para pedir la ventana de 1M y SOLO aplica a
#    las env vars del CLI (en llamadas directas a la API el id es `k3` pelón). No confundir con el
#    truco del id Anthropic que falló con DeepSeek: `k3` no es un id que el CLI reconozca como
#    Anthropic, así que respeta ANTHROPIC_BASE_URL.
#  - Verificar dentro de la sesión con `/status`: el Base URL debe decir `api.kimi.com/coding/`.
#    NO confiar en preguntarle al modelo "¿qué modelo eres?": el system prompt de Claude Code le
#    dice que es Claude, así que CUALQUIER modelo detrás contesta "soy Claude". Es prueba nula.
#  - Thinking DEBE ir encendido para usar K3 / K2.7: apagarlo rutea silenciosamente a K2.6.
#    Cambiar esfuerzo en caliente con `/effort` (K3 soporta low/high/max).
#  - Si los tool calls se portan raro, probar con `ENABLE_TOOL_SEARCH=false`: la doc de la otra
#    plataforma dice que su endpoint aún no soporta Tool Search. La doc de Kimi Code no lo pide,
#    por eso no va activado aquí (probado: NO era la causa del 401 de abajo).
#
# ⚠️ DOS GOTCHAS QUE COSTARON DEBUGGEO (29-jul-2026, ambos aislados empíricamente):
#
#  1. CLAUDE_CONFIG_DIR PROPIO — OBLIGATORIO. Con el config dir default (`~/.claude`) y la sesión
#     de Claude logueada, el CLI usa las credenciales OAuth de Anthropic e IGNORA
#     ANTHROPIC_AUTH_TOKEN → las manda al endpoint de Kimi → `401 The API Key appears to be
#     invalid`. Aislado a punta de bisección: copias de `~/.claude.json`, `settings.json`,
#     `settings.local.json`, `plugins`, `agents`, `skills`, `commands`, `hooks` y `CLAUDE.md`
#     dentro de un CLAUDE_CONFIG_DIR alterno funcionan TODAS; el único factor que rompe es usar
#     el config dir default. Es el mismo fenómeno de [[claude-ds]]: sesión logueada gana.
#     Por eso este wrapper usa `~/.claude-kimi/` con symlinks a los assets reales (mismos skills,
#     plugins, agentes, CLAUDE.md y settings; historial de proyectos compartido vía .claude.json).
#
#  2. NO pasar `--model` en la línea de comandos. El flag manda el id LITERAL y Kimi rechaza
#     `k3[1m]` con `401 ... Your model id does not exist, recognized as other:k3[1m]`. Vía la env
#     var ANTHROPIC_MODEL el CLI sí interpreta el `[1m]` y manda `k3` limpio. Ojo: Kimi devuelve
#     401 (no 400) para ids de modelo inválidos, así que un "401" aquí NO siempre es la key.
#     ANTHROPIC_MODEL gana sobre el `"model"` de settings.json — verificado.
claude-kimi() {
  local key model window cfg
  key=$(security find-generic-password -a "$USER" -s moonshot_api_key -w 2>/dev/null)
  if [[ -z "$key" ]]; then
    echo "Falta la key de Kimi Code. Créala en https://www.kimi.com/code/console"
    echo "y guárdala una vez (el prompt oculta lo que pegues):"
    echo '  security add-generic-password -a "$USER" -s moonshot_api_key -U -w'
    return 1
  fi

  # Config dir propio, idempotente: symlinks a los assets reales para no duplicar nada.
  cfg="$HOME/.claude-kimi"
  mkdir -p "$cfg"
  ln -sfn "$HOME/.claude.json" "$cfg/.claude.json"
  local asset
  for asset in settings.json settings.local.json plugins agents skills commands hooks CLAUDE.md; do
    [[ -e "$HOME/.claude/$asset" ]] && ln -sfn "$HOME/.claude/$asset" "$cfg/$asset"
  done

  model="${KIMI_MODEL:-k3[1m]}"
  case "$model" in
    *\[1m\]) window=1048576 ;;  # 1M
    *)       window=262144  ;;  # 256K — k3-256k, k2.7-code, kimi-for-coding
  esac
  CLAUDE_CONFIG_DIR="$cfg" \
  ANTHROPIC_BASE_URL="https://api.kimi.com/coding/" \
  ANTHROPIC_API_KEY="$key" \
  ANTHROPIC_AUTH_TOKEN="$key" \
  ANTHROPIC_MODEL="$model" \
  ANTHROPIC_SMALL_FAST_MODEL="$model" \
  ANTHROPIC_DEFAULT_OPUS_MODEL="$model" \
  ANTHROPIC_DEFAULT_SONNET_MODEL="$model" \
  ANTHROPIC_DEFAULT_HAIKU_MODEL="$model" \
  ANTHROPIC_DEFAULT_FABLE_MODEL="$model" \
  CLAUDE_CODE_SUBAGENT_MODEL="$model" \
  CLAUDE_CODE_AUTO_COMPACT_WINDOW="$window" \
  CLAUDE_CODE_MAX_CONTEXT_TOKENS="$window" \
  CLAUDE_CODE_EFFORT_LEVEL="high" \
  ~/.local/bin/claude --dangerously-skip-permissions "$@"
}

# Atajo corto, mismo comportamiento que claude-kimi.
alias claude-k='claude-kimi'
