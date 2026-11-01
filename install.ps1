# Trestle - Installer (Windows PowerShell)
# One-liner: git clone https://github.com/liormesh/trestle $env:TEMP\trestle; & $env:TEMP\trestle\install.ps1

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeDir = Join-Path $env:USERPROFILE ".claude"
$SkillsDir = Join-Path $ClaudeDir "skills"
$TrestleDir = Join-Path $ClaudeDir "trestle"
$Version = (Get-Content (Join-Path $ScriptDir "tools\VERSION") -Raw).Trim()
$BackupDir = Join-Path $TrestleDir ("backups\" + (Get-Date -Format "yyyyMMdd-HHmmss"))
$Updated = $false

Write-Host ""
Write-Host "  Trestle v$Version"
Write-Host "  -----------------"
Write-Host ""
Write-Host "  Installing to: $ClaudeDir"
Write-Host ""
Write-Host "  What this does:"
Write-Host "    1. Copies the starter skills (/onboard, /cq, /73, /visualize) to $SkillsDir\"
Write-Host "       (already installed? older copies are backed up, then updated)"
Write-Host "    2. Copies three small tools to $TrestleDir\ - a secret guard, a link guard"
Write-Host "       and the /73 health check (Node.js scripts, no dependencies)"
Write-Host "    3. Creates a bootstrap CLAUDE.md (triggers /onboard on first run)"
Write-Host ""
Write-Host "  That's it - a handful of files. The real setup happens when you type /onboard."
Write-Host ""

# 1. Ensure ~/.claude exists
New-Item -ItemType Directory -Force -Path $SkillsDir | Out-Null

# 2. Copy the starter skills. An existing copy that differs is backed up first, then replaced.
function Get-TreeHash($Dir) {
    (Get-ChildItem -Recurse -File $Dir | Sort-Object FullName | ForEach-Object {
        $_.FullName.Substring($Dir.Length) + ":" + (Get-FileHash $_.FullName).Hash
    }) -join "|"
}
foreach ($skill in @("onboard", "cq", "73", "visualize")) {
    $Src = Join-Path $ScriptDir "skills\$skill"
    $DestDir = Join-Path $SkillsDir $skill
    if (Test-Path $DestDir) {
        if ((Get-TreeHash $Src) -eq (Get-TreeHash $DestDir)) {
            Write-Host "  [ok]   /$skill skill is up to date"
            continue
        }
        $Bak = Join-Path $BackupDir "skills"
        New-Item -ItemType Directory -Force -Path $Bak | Out-Null
        Move-Item $DestDir (Join-Path $Bak $skill)
        Copy-Item -Recurse $Src $DestDir
        $Updated = $true
        Write-Host "  [done] Updated /$skill skill (previous copy -> $Bak\$skill)"
    } else {
        Copy-Item -Recurse $Src $DestDir
        Write-Host "  [done] Installed /$skill skill -> $DestDir"
    }
}

# 2b. Tools: hooks + health check (config.json, written by /onboard, is never touched here)
New-Item -ItemType Directory -Force -Path $TrestleDir | Out-Null
$VersionFile = Join-Path $TrestleDir "VERSION"
if ((Test-Path $VersionFile) -and ((Get-Content $VersionFile -Raw).Trim() -ne $Version)) { $Updated = $true }
Copy-Item (Join-Path $ScriptDir "tools\*") $TrestleDir -Force
Write-Host "  [done] Installed tools -> $TrestleDir (v$Version)"

$Node = Get-Command node -ErrorAction SilentlyContinue
if ($Node -and ([int](& node -p "process.versions.node.split('.')[0]") -ge 18)) {
    Write-Host "  [ok]   Node.js $(& node --version) found"
} else {
    Write-Host "  [warn] Node.js 18+ not found - the hooks and the /73 health check need it (https://nodejs.org)"
}

# 3. Create bootstrap CLAUDE.md (only if none exists)
$ClaudeMd = Join-Path $ClaudeDir "CLAUDE.md"
if (Test-Path $ClaudeMd) {
    Write-Host "  [skip] ~/.claude/CLAUDE.md already exists"
} else {
    @"
# First Time Setup

If no knowledge base exists yet (no ~/Documents/knowledge-base/ or the user hasn't been onboarded), suggest running /onboard to set up the user's AI workspace. This is a one-time setup that creates a personal knowledge base, memory system, and profile.

After onboarding is complete, this file will be replaced with permanent global instructions.
"@ | Set-Content -Path $ClaudeMd -Encoding UTF8
    Write-Host "  [done] Created bootstrap CLAUDE.md"
}

# 4. Clean up clone if installed from temp
if ($ScriptDir -like "$env:TEMP*") {
    Remove-Item -Recurse -Force $ScriptDir
    Write-Host "  [done] Cleaned up temporary files"
}

Write-Host ""
if ($Updated) {
    Write-Host "  Updated to v$Version. Open Claude Code from your home directory, type /onboard"
    Write-Host "  and pick (d) to bring your workspace's rules up to date. Your content is not touched."
} else {
    Write-Host "  Ready. Open Claude Code from your home directory and type /onboard."
}
Write-Host ""
