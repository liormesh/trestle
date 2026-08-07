# Trestle - Installer (Windows PowerShell)
# One-liner: git clone https://github.com/liormesh/trestle $env:TEMP\trestle; & $env:TEMP\trestle\install.ps1

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeDir = Join-Path $env:USERPROFILE ".claude"
$SkillsDir = Join-Path $ClaudeDir "skills"

Write-Host ""
Write-Host "  Trestle"
Write-Host "  -----------------"
Write-Host ""
Write-Host "  Installing to: $ClaudeDir"
Write-Host ""
Write-Host "  What this does:"
Write-Host "    1. Copies the starter skills (/onboard, /cq, /73, /visualize) to $SkillsDir\"
Write-Host "    2. Creates a bootstrap CLAUDE.md (triggers /onboard on first run)"
Write-Host ""
Write-Host "  That's it - a handful of files. The real setup happens when you type /onboard."
Write-Host ""

# 1. Ensure ~/.claude exists
New-Item -ItemType Directory -Force -Path $SkillsDir | Out-Null

# 2. Copy the starter skills (onboard + the session rituals cq / 73 + the /visualize skill and its book)
foreach ($skill in @("onboard", "cq", "73", "visualize")) {
    $DestDir = Join-Path $SkillsDir $skill
    if (Test-Path $DestDir) {
        Write-Host "  [skip] /$skill skill already installed"
    } else {
        Copy-Item -Recurse (Join-Path $ScriptDir "skills\$skill") $DestDir
        Write-Host "  [done] Installed /$skill skill -> $DestDir"
    }
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
Write-Host "  Ready. Open Claude Code from your home directory and type /onboard."
Write-Host ""
