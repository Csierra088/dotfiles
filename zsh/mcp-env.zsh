# Variables de entorno para los MCP servers de Claude Code.
# Los MCP heredan el entorno del shell que lanzó `claude`, así que exportarlas aquí
# basta y NO hay que meter secretos en ~/.claude.json.
#
# ESTE REPO ES PÚBLICO. Aquí va solo el MECANISMO.
#   - Secretos            -> Keychain de macOS.
#   - Datos identificables -> ~/.mcp-env.local.zsh (fuera de git; ver plantilla abajo).
# Creado 2026-07-31 al migrar de Mac (ver nota migracion-mac-2026-07-31 del vault).
#
# Plantilla de ~/.mcp-env.local.zsh:
#   export MEDUSA_BACKEND_URL="https://<tu-panel-admin>"
#   export MEDUSA_USERNAME="<tu-usuario>"
#   export UNIFI_NETWORK_HOST="<ip-o-host-de-la-consola>"
#   export UNIFI_NETWORK_USERNAME="<admin-local>"

[ -f "$HOME/.mcp-env.local.zsh" ] && source "$HOME/.mcp-env.local.zsh"

_mcp_key() { security find-generic-password -a "$USER" -s "$1" -w 2>/dev/null }

# ── medusa-store (SGFGOV/medusa-mcp) ─────────────────────────────────────────
export MEDUSA_PASSWORD="$(_mcp_key medusa_admin_password)"
export PUBLISHABLE_KEY="$(_mcp_key medusa_publishable_key)"

# ── unifi-network (uvx unifi-network-mcp==0.24.1) ────────────────────────────
# OJO: el API key NO autentica la sesión; hace falta una cuenta de admin LOCAL
# de la consola, no la de ui.com.
export UNIFI_NETWORK_PASSWORD="$(_mcp_key unifi_local_admin_password)"

# ── octoeverywhere ───────────────────────────────────────────────────────────
# Es HTTP: el token va como header en ~/.claude.json, no por env.
# Token regenerable en https://octoeverywhere.com/mcp
#   claude mcp remove --scope user octoeverywhere
#   claude mcp add --scope user --transport http octoeverywhere \
#     https://octoeverywhere.com/api/mcp --header "Authorization: Bearer <token>"

unset -f _mcp_key

# Aviso si falta algo.
# SOLO en shells interactivos y SOLO por stderr: los MCP stdio usan stdout para
# JSON-RPC, y cualquier cosa impresa ahí corrompe el protocolo.
if [[ -o interactive ]]; then
  _mcp_falta=()
  [[ -z "$MEDUSA_PASSWORD" ]]        && _mcp_falta+=("keychain:medusa_admin_password")
  [[ -z "$PUBLISHABLE_KEY" ]]        && _mcp_falta+=("keychain:medusa_publishable_key")
  [[ -z "$UNIFI_NETWORK_PASSWORD" ]] && _mcp_falta+=("keychain:unifi_local_admin_password")
  [[ -z "$MEDUSA_BACKEND_URL" ]]     && _mcp_falta+=("~/.mcp-env.local.zsh")
  if (( ${#_mcp_falta[@]} )); then
    print -u2 "MCP: falta -> ${_mcp_falta[*]}"
    print -u2 "  secretos:  security add-generic-password -a \"\$USER\" -s <nombre> -w"
  fi
  unset _mcp_falta
fi
