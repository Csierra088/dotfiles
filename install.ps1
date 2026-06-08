# Instalador de dotfiles — Windows (PowerShell)
# Requiere PowerShell 7+ y winget instalado
# Ejecutar como: Set-ExecutionPolicy Bypass -Scope Process; .\install.ps1

$DOTFILES = $PSScriptRoot
$ErrorActionPreference = "Stop"

function Log  { Write-Host "  > $args" -ForegroundColor Cyan }
function Ok   { Write-Host "  OK $args" -ForegroundColor Green }
function Warn { Write-Host "  ! $args" -ForegroundColor Magenta }

Write-Host "`n  [dotfiles] Instalando config de Carlos`n" -ForegroundColor Magenta

# ─── Dependencias ─────────────────────────────────────────────────────────────
Log "Instalando Ghostty..."
winget install --id Mitchell.Ghostty -e --silent 2>$null
Ok "Ghostty"

Log "Instalando Starship..."
winget install --id Starship.Starship -e --silent 2>$null
Ok "Starship"

Log "Instalando Fastfetch..."
winget install --id fastfetch-cli.fastfetch -e --silent 2>$null
Ok "Fastfetch"

# tmux no existe en Windows nativo, se usa via WSL2
Warn "tmux solo funciona en WSL2. Instálalo dentro de tu distro WSL con: sudo apt install tmux"

# ─── Ghostty ──────────────────────────────────────────────────────────────────
Log "Configurando Ghostty..."
$ghosttyConfig = "$env:APPDATA\ghostty"
New-Item -ItemType Directory -Force -Path "$ghosttyConfig\shaders" | Out-Null
Copy-Item "$DOTFILES\ghostty\config"                       "$ghosttyConfig\config" -Force
Copy-Item "$DOTFILES\ghostty\shaders\in-game-crt.glsl"    "$ghosttyConfig\shaders\" -Force
Copy-Item "$DOTFILES\ghostty\shaders\retro-terminal.glsl" "$ghosttyConfig\shaders\" -Force
Ok "Ghostty configurado en $ghosttyConfig"

# ─── Starship ─────────────────────────────────────────────────────────────────
Log "Configurando Starship..."
$configDir = "$env:USERPROFILE\.config"
New-Item -ItemType Directory -Force -Path $configDir | Out-Null
Copy-Item "$DOTFILES\starship\starship.toml" "$configDir\starship.toml" -Force
Ok "Starship configurado"

# ─── Fastfetch ─���───────────────────────────���──────────────────────────────────
Log "Configurando Fastfetch..."
$ffDir = "$env:USERPROFILE\.config\fastfetch"
New-Item -ItemType Directory -Force -Path $ffDir | Out-Null
Copy-Item "$DOTFILES\fastfetch\config.jsonc" "$ffDir\config.jsonc" -Force
Copy-Item "$DOTFILES\fastfetch\ascii.txt"    "$ffDir\ascii.txt" -Force
Ok "Fastfetch configurado"

# ─── Scripts ──────────────────────────────────────────────────────────────────
Log "Instalando scripts en ~/bin..."
$binDir = "$env:USERPROFILE\bin"
New-Item -ItemType Directory -Force -Path $binDir | Out-Null
Copy-Item "$DOTFILES\bin\keys" "$binDir\keys.sh" -Force
Ok "Scripts instalados en $binDir"

# ─── PowerShell profile ─────��─────────────────────────────────────────────────
Log "Configurando PowerShell profile..."
$profileDir = Split-Path $PROFILE
New-Item -ItemType Directory -Force -Path $profileDir | Out-Null

$initBlock = @'

# Dotfiles — starship + fastfetch
Invoke-Expression (&starship init powershell)
if (-not $env:TERM_PROGRAM) {
    $now = Get-Date -Format "dddd dd MMM  HH:mm"
    Write-Host ""
    Write-Host "  > bienvenido, $env:USERNAME" -ForegroundColor Magenta
    Write-Host "  . sesion actual   $now" -ForegroundColor Cyan
    Write-Host ""
    fastfetch
}
'@

if (-not (Test-Path $PROFILE)) { New-Item -ItemType File -Force -Path $PROFILE | Out-Null }
if (-not (Select-String -Path $PROFILE -Pattern "starship init powershell" -Quiet)) {
    Add-Content -Path $PROFILE -Value $initBlock
}
Ok "PowerShell profile configurado en $PROFILE"

Write-Host "`n  Instalacion completa. Abre Ghostty para ver los cambios.`n" -ForegroundColor Green
