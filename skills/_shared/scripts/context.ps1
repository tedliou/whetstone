# Usage: context.ps1
# Prints gh, repo, branch, and working tree state. Always exits 0.
# Output format is documented in skills/_shared/github.md.
# Test hook: WHETSTONE_OFFLINE=1 skips every gh call.
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$ghOk = $false
$hasGh = [bool](Get-Command gh -ErrorAction SilentlyContinue)
$ghHelp = ''
if ($hasGh -and -not $env:WHETSTONE_OFFLINE) {
    $ghHelp = (gh issue create --help 2>$null) -join "`n"
}
if ($env:WHETSTONE_OFFLINE) {
    Write-Output "gh`tskipped"
} elseif (-not $hasGh) {
    Write-Output "gh`tmissing`tinstall from https://cli.github.com then run: gh auth login"
} elseif (-not $ghHelp.Contains('--blocked-by')) {
    Write-Output "gh`ttoo-old`tupgrade gh; issue --parent and --blocked-by are required"
} else {
    $login = gh api user --jq .login 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $login) {
        Write-Output "gh`tnot-logged-in`trun: gh auth login"
    } else {
        Write-Output "gh`tok`t$login"
        $ghOk = $true
    }
}

$top = git rev-parse --show-toplevel 2>$null
if ($LASTEXITCODE -ne 0 -or -not $top) {
    Write-Output "git`tnot-a-repo"
    exit 0
}
Write-Output "git`tok`t$top"

$url = git remote get-url origin 2>$null
$default = git symbolic-ref --short -q refs/remotes/origin/HEAD 2>$null
if ($default) { $default = $default -replace '^origin/', '' }
if (-not $default -and $ghOk) {
    $default = gh repo view --json defaultBranchRef --jq .defaultBranchRef.name 2>$null
}
if (-not $url) {
    Write-Output "repo`tnone`tno origin remote"
} elseif ($url -match 'github\.com[:/](.+)$') {
    $slug = $Matches[1] -replace '\.git$', ''
    $d = '-'
    if ($default) { $d = $default }
    Write-Output "repo`t$slug`t$d"
} else {
    Write-Output "repo`tnot-github`t$url"
}

$branch = git branch --show-current
if (-not $branch) { $branch = 'detached' }
$spec = '-'
if ($branch -match '^(\d+)-') { $spec = $Matches[1] }
$ahead = '-'
if ($default) {
    git rev-parse -q --verify "origin/$default" 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) { $ahead = git rev-list --count "origin/$default..HEAD" }
}
Write-Output "branch`t$branch`t$spec`t$ahead"

$status = @(git status --porcelain -uall)
Write-Output "changes`t$($status.Count)"
foreach ($line in $status) {
    $p = $line.Substring(3) -replace '^.* -> ', ''
    if ($p -match '^(GLOSSARY\.md|docs/adr/)') { Write-Output "domain`t$p" }
}

$path = $null
$br = '-'
foreach ($line in @(git worktree list --porcelain) + @('')) {
    if ($line.StartsWith('worktree ')) { $path = $line.Substring(9); $br = '-' }
    elseif ($line.StartsWith('branch ')) { $br = $line.Substring(7) -replace '^refs/heads/', '' }
    elseif ($line -eq '') {
        if ($path -and $path -ne $top) { Write-Output "worktree`t$path`t$br" }
        $path = $null
    }
}
exit 0
