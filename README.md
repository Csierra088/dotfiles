# dotfiles — Carlos Sierra

Config personal de terminal: Ghostty + tmux + Starship + Fastfetch.

## Instalación rápida

**macOS / Linux**
```bash
git clone https://github.com/Csierra088/dotfiles.git ~/dotfiles
cd ~/dotfiles && bash install.sh
```

**Windows**
```powershell
git clone https://github.com/Csierra088/dotfiles.git $HOME\dotfiles
cd $HOME\dotfiles
Set-ExecutionPolicy Bypass -Scope Process
.\install.ps1
```

## Qué incluye

| Archivo | Descripción |
|---------|-------------|
| `ghostty/config` | Tema Synthwave, JetBrains Mono NL, tabs, atajos |
| `ghostty/shaders/` | Shader CRT retro opcional |
| `tmux/.tmux.conf` | Prefix Ctrl+A, colores cyberpunk, sesiones por proyecto |
| `starship/starship.toml` | Prompt dos líneas, hora, git, runtimes |
| `fastfetch/` | Config aliencat + ASCII art |
| `bin/dev` | Arranca sesiones tmux por proyecto |
| `bin/keys` | Cheatsheet de atajos en terminal |

## Atajos principales

Corre `keys` en la terminal para ver el cheatsheet completo.

## Notas Windows

- Ghostty, Starship y Fastfetch funcionan nativamente en Windows
- tmux requiere WSL2 (`sudo apt install tmux` dentro de tu distro)
- Los scripts `dev` y `keys` son zsh — úsalos desde WSL2 o adapta a PowerShell
