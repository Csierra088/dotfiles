#!/usr/bin/env bash
# Instalador de dotfiles — macOS / Linux
set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"

GREEN='\033[38;2;0;255;159m'
CYAN='\033[38;2;5;217;232m'
PINK='\033[38;2;255;42;109m'
R='\033[0m'

log()  { printf "${CYAN}  ▸ %s${R}\n" "$1"; }
ok()   { printf "${GREEN}  ✓ %s${R}\n" "$1"; }
warn() { printf "${PINK}  ⚠ %s${R}\n" "$1"; }

printf "\n${PINK}  ⬡  Instalando dotfiles de Carlos${R}\n\n"

# ─── Dependencias ─────────────────────────────────────────────────────────────
if [[ "$OS" == "Darwin" ]]; then
  if ! command -v brew &>/dev/null; then
    warn "Homebrew no encontrado. Instálalo en https://brew.sh"
    exit 1
  fi

  log "Instalando dependencias con Homebrew..."
  brew install tmux starship fastfetch 2>/dev/null || true
  ok "Dependencias listas"

  if [[ ! -d "/Applications/Ghostty.app" ]]; then
    warn "Ghostty no está instalado. Descárgalo en https://ghostty.org/download"
  fi

elif [[ "$OS" == "Linux" ]]; then
  log "Instalando dependencias..."
  if command -v apt &>/dev/null; then
    sudo apt install -y tmux curl 2>/dev/null || true
  elif command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm tmux curl 2>/dev/null || true
  fi
  command -v starship &>/dev/null || curl -sS https://starship.rs/install.sh | sh
  command -v fastfetch &>/dev/null || warn "Instala fastfetch manualmente para tu distro"
  ok "Dependencias listas"
fi

# ─── Ghostty ──────────────────────────────────────────────────────────────────
log "Configurando Ghostty..."
mkdir -p ~/.config/ghostty/shaders
cp "$DOTFILES/ghostty/config"                          ~/.config/ghostty/config
cp "$DOTFILES/ghostty/shaders/in-game-crt.glsl"       ~/.config/ghostty/shaders/
cp "$DOTFILES/ghostty/shaders/retro-terminal.glsl"    ~/.config/ghostty/shaders/
ok "Ghostty configurado"

# ─── tmux ─────────────────────────────────────────────────────────────────────
log "Configurando tmux..."
cp "$DOTFILES/tmux/.tmux.conf" ~/.tmux.conf
ok "tmux configurado"

# ─── Starship ─────────────────────────────────────────────────────────────────
log "Configurando Starship..."
mkdir -p ~/.config
cp "$DOTFILES/starship/starship.toml" ~/.config/starship.toml
ok "Starship configurado"

# ─── Fastfetch ────────────────────────────────────────────────────────────────
log "Configurando Fastfetch..."
mkdir -p ~/.config/fastfetch
cp "$DOTFILES/fastfetch/config.jsonc" ~/.config/fastfetch/config.jsonc
cp "$DOTFILES/fastfetch/ascii.txt"    ~/.config/fastfetch/ascii.txt
ok "Fastfetch configurado"

# ─── Scripts bin ──────────────────────────────────────────────────────────────
log "Instalando scripts..."
mkdir -p ~/.local/bin
cp "$DOTFILES/bin/dev"  ~/.local/bin/dev
cp "$DOTFILES/bin/keys" ~/.local/bin/keys
chmod +x ~/.local/bin/dev ~/.local/bin/keys
ok "Scripts instalados"

# ─── hushlogin ────────────────────────────────────────────────────────────────
touch ~/.hushlogin

# ─── Shell (zsh) ──────────────────────────────────────────────────────────────
SHELL_RC="$HOME/.zshrc"
[[ "$SHELL" == */bash ]] && SHELL_RC="$HOME/.bashrc"

log "Configurando shell ($SHELL_RC)..."

add_if_missing() {
  grep -qF "$1" "$SHELL_RC" 2>/dev/null || echo "$1" >> "$SHELL_RC"
}

add_if_missing 'export PATH="$HOME/.local/bin:$PATH"'
add_if_missing 'eval "$(starship init zsh)"'
add_if_missing '[[ -z "$TMUX" ]] && { _last=$(last "$USER" 2>/dev/null | awk '"'"'NR==2 && NF>=8 {printf "%s %s %s  %s", $3, $4, $5, $6}'"'"'); _now=$(date "+%A %d %b  %H:%M"); echo ""; echo "  \033[35m⬡\033[0m  \033[95mbienvenido, $USER\033[0m"; echo "  \033[35m·\033[0m  \033[2msesión actual   \033[0m\033[96m$_now\033[0m"; [[ -n "$_last" ]] && echo "  \033[35m·\033[0m  \033[2múltima sesión   \033[0m\033[35m$_last\033[0m"; echo ""; fastfetch; }'
# Memory vault: aliases mem-save/mem-cd/mem-vault/mem-grep (requiere clonar Csierra088/memory-vault en ~/Documents/memory-vault)
add_if_missing '[ -f "$HOME/dotfiles/zsh/memory-vault.zsh" ] && source "$HOME/dotfiles/zsh/memory-vault.zsh"'
ok "Shell configurado"

printf "\n${GREEN}  ⬡  Instalación completa.${R} Abre una terminal nueva o corre: source $SHELL_RC\n\n"
