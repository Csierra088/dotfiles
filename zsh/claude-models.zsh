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
