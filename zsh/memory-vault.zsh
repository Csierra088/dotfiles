# Memory vault — respaldo y búsqueda de la memoria de Claude Code
# Repo privado: Csierra088/memory-vault
# El vault VIVE en ~/Documents/memory-vault (abrible como vault de Obsidian).
# ~/.claude/projects/-Users-carloss/memory es un symlink → ~/Documents/memory-vault,
# así Claude Code lee/escribe por su ruta de siempre de forma transparente.
#
# Este archivo se versiona en Csierra088/dotfiles y se carga vía `source` desde ~/.zshrc.

export MEM_VAULT="$HOME/Documents/memory-vault"

# Uso:  mem-save                 (commit con mensaje automático con fecha)
#       mem-save "lo que cambió" (commit con tu mensaje)
# Hace pull --rebase primero (por si editaste en otra máquina/móvil) y luego push.
mem-save() {
  local msg="${*:-mem: snapshot $(date '+%Y-%m-%d %H:%M')}"
  git -C "$MEM_VAULT" pull --rebase --autostash -q 2>/dev/null
  if [[ -z "$(git -C "$MEM_VAULT" status --porcelain)" ]]; then
    echo "  \033[2mmemory-vault: nada que guardar (limpio)\033[0m"
    return 0
  fi
  git -C "$MEM_VAULT" add -A
  git -C "$MEM_VAULT" -c user.name='Csierra088' -c user.email='serioguy99@gmail.com' commit -q -m "$msg"
  git -C "$MEM_VAULT" push -q origin main && \
    echo "  \033[32m✓\033[0m memory-vault guardado: \033[2m$msg\033[0m"
}

# Uso:  mem-cd   → entrar a la carpeta del vault
alias mem-cd='cd "$MEM_VAULT"'

# Uso:  mem-vault → abrir el repo en GitHub
alias mem-vault='open https://github.com/Csierra088/memory-vault'

# Uso:  mem-grep "término"     → busca en todas las notas, muestra archivo:línea con contexto
#       mem-grep -l "término"  → solo lista los archivos que coinciden
# Decisión (jun-2026): grep + índice MEMORY.md en vez de MCP de embeddings/RAG.
# Con ~176 notas cortas es suficiente; reconsiderar embeddings si el vault pasa de ~500-800 notas.
mem-grep() {
  if [[ -z "$1" ]]; then
    echo "uso: mem-grep [-l] \"término\""
    return 1
  fi
  grep -rin --color=auto --include="*.md" "$@" "$MEM_VAULT"
}
