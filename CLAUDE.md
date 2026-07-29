# CLAUDE.md — Dotfiles de Carlos Sierra

Contexto para sesiones de Claude Code que trabajen sobre este repo o la config de terminal.

## Qué es esto

Config personal de terminal: Ghostty + tmux + Starship + Fastfetch, con estética cyberpunk/Synthwave.
Repo: `Csierra088/dotfiles` — local en `~/dotfiles/`.

## Archivos y su propósito

| Archivo | Destino real | Notas clave |
|---------|-------------|-------------|
| `ghostty/config` | `~/.config/ghostty/config` | Tema Synthwave, JetBrains Mono NL Nerd Font 13px, `macos-titlebar-style = tabs` |
| `ghostty/shaders/in-game-crt.glsl` | `~/.config/ghostty/shaders/` | CRT shader — actualmente **INACTIVO** (comentado en config) |
| `ghostty/shaders/retro-terminal.glsl` | `~/.config/ghostty/shaders/` | Alternativo guardado, no activo |
| `tmux/.tmux.conf` | `~/.tmux.conf` | Prefix `Ctrl+A`, colores neon pink/cyan/purple |
| `starship/starship.toml` | `~/.config/starship.toml` | 2 líneas con `╔`/`╚❯`, hora a la derecha con `$fill` |
| `fastfetch/config.jsonc` | `~/.config/fastfetch/config.jsonc` | Aliencat ASCII art, colores cyan+green; ANSI = `` en JSON |
| `fastfetch/ascii.txt` | `~/.config/fastfetch/ascii.txt` | Braille aliencat (KaykCaputo/aliencat-fastfetch) |
| `bin/dev` | `~/.local/bin/dev` | Arranca sesiones tmux por proyecto |
| `bin/keys` | `~/.local/bin/keys` | Cheatsheet de atajos Ghostty+tmux en terminal |
| `zsh/claude-models.zsh` | `source` desde `~/.zshrc` | `alias claude` (skip-permissions) + wrappers `claude-mm`/`claude-ds`/`claude-z`/`claude-kimi` (alias `claude-k`). **API keys SIEMPRE en Keychain, nunca en el repo.** |
| `zsh/memory-vault.zsh` | `source` desde `~/.zshrc` | Aliases del memory vault: `mem-save`/`mem-cd`/`mem-vault`/`mem-grep`. Requiere clonar `Csierra088/memory-vault` en `~/Documents/memory-vault`. |
| `install.sh` | — | Instalador macOS/Linux (brew + cp) |
| `install.ps1` | — | Instalador Windows (winget + PowerShell profile) |

## Sesiones tmux (`dev`)

| Sesión | Directorio |
|--------|-----------|
| `precot` | `~/Documents/precotizaciones-main` |
| `sierra` | `~/Documents/syscom-shopify-sync` |
| `spl` | `~/Documents/sierra-print-lab-storefront` |
| `int` | `~/Documents/integradores-sierrastore` |
| `erp` | `~/Documents/connexum-erp` |
| `hermes` | `~/Documents/openclaw-sierra` |

Uso: `dev` (adjunta a `precot` por default) · `dev sierra` (adjunta directo a esa sesión).

## Ghostty — atajos configurados

| Acción | Atajo |
|--------|-------|
| Split horizontal | `Cmd+Shift+H` |
| Split vertical | `Cmd+Shift+V` |
| Navegar splits | `Cmd+]` / `Cmd+[` |
| Cerrar split | `Cmd+W` |
| Zoom split | `Cmd+Enter` |
| Igualar splits | `Cmd+Shift+E` |
| Overview | `Cmd+Shift+O` |
| Nueva tab | `Cmd+T` |
| Cerrar tab | `Cmd+Shift+W` |
| Ir a tab N | `Cmd+1…9` |
| Mover tab | `Cmd+Ctrl+←/→` |
| Renombrar split | `Cmd+Shift+P` |
| Recargar config | `Cmd+Shift+R` |

## Decisiones de diseño relevantes

- **Sin transparencia** — `background-opacity = 1.0` (Carlos lo pidió explícitamente).
- **Sin shader CRT activo** — los shaders están guardados pero comentados en config.
- **`macos-titlebar-style = tabs`** — necesario para que aparezca la barra visual con botón +. `hidden`/`transparent` eliminan los controles de ventana.
- **ANSI en JSON de fastfetch** — los ESC chars deben ser `` (no bytes raw). Generar con `json.dumps` en Python, no con `echo -e`.
- **`$fill` en Starship** — alinea el reloj a la derecha sin módulo adicional.
- **`{user-name}` y `{host-name}`** en fastfetch (no `{user}` ni `{hostname}`).

## Workflow de actualización

Después de cambiar cualquier config local, sincronizar al repo:

```bash
cp ~/.config/ghostty/config ~/dotfiles/ghostty/config
# (repetir para el archivo que cambió)
cd ~/dotfiles
git add . && git commit -m "update: descripción" && git push
```

## Windows

- Ghostty, Starship, Fastfetch → nativos via winget
- tmux → solo en WSL2
- Scripts `dev`/`keys` → desde WSL2 o adaptar a PowerShell
