# Link every whetstone skill (and skills/_shared) into ~/.claude/skills
# using directory junctions (no admin rights or developer mode needed).
# Re-run after adding, removing, or renaming a skill.
# Output: one line per entry, tab separated: <status> <name> [detail]
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = 'Stop'

$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$src = Join-Path $repo 'skills'
$configDir = $env:CLAUDE_CONFIG_DIR
if (-not $configDir) { $configDir = Join-Path $HOME '.claude' }
$dest = Join-Path $configDir 'skills'
if (-not (Test-Path $dest)) { New-Item -ItemType Directory -Path $dest | Out-Null }

function Get-LinkTarget($item) {
    if (-not $item.LinkType) { return $null }
    $t = @($item.Target)[0]
    if ($t) { return $t.TrimEnd('\') }
    return $null
}

function Test-UnderSrc($path) {
    return $path.StartsWith($src + '\', [System.StringComparison]::OrdinalIgnoreCase)
}

foreach ($dir in Get-ChildItem -Path $src -Directory) {
    $name = $dir.Name
    if ($name -ne '_shared' -and -not (Test-Path (Join-Path $dir.FullName 'SKILL.md'))) { continue }
    $link = Join-Path $dest $name
    $item = Get-Item -LiteralPath $link -Force -ErrorAction SilentlyContinue
    if ($item) {
        $current = Get-LinkTarget $item
        if (-not $current) {
            Write-Output "skipped`t$name`ta real directory exists; move it away and re-run"
            continue
        }
        if ($current -ieq $dir.FullName) {
            Write-Output "ok`t$name"
            continue
        }
        if (-not (Test-UnderSrc $current)) {
            Write-Output "skipped`t$name`tlinked elsewhere: $current"
            continue
        }
        $item.Delete()
    }
    New-Item -ItemType Junction -Path $link -Target $dir.FullName | Out-Null
    Write-Output "linked`t$name"
}

# Remove links into this repo whose skill no longer exists.
foreach ($item in Get-ChildItem -Path $dest -Force) {
    $current = Get-LinkTarget $item
    if ($current -and (Test-UnderSrc $current) -and -not (Test-Path -LiteralPath $current)) {
        $item.Delete()
        Write-Output "removed`t$($item.Name)"
    }
}
