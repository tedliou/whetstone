# Usage: land.ps1 <ticket-branch>
# Run in the main worktree, on the spec branch. Rebases the ticket branch
# (which must be checked out in its own worktree) onto the spec branch,
# fast-forwards the spec branch, then removes the worktree and the branch.
# No merge commits. Exits 1 with an "error" line when it stops.
param([string]$Ticket = '')
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Exit-Land([string]$msg) {
    Write-Output "error`t$msg"
    exit 1
}

if (-not $Ticket) { Exit-Land 'usage: land <ticket-branch>' }
$spec = git branch --show-current
if (-not $spec -or $spec -eq $Ticket) {
    Exit-Land 'run land from the main worktree with the spec branch checked out'
}

$wt = $null
$path = $null
foreach ($line in @(git worktree list --porcelain)) {
    if ($line.StartsWith('worktree ')) { $path = $line.Substring(9) }
    elseif ($line -eq "branch refs/heads/$Ticket") { $wt = $path; break }
}
if (-not $wt) { Exit-Land "no worktree has branch $Ticket checked out" }
if (@(git -C $wt status --porcelain).Count -gt 0) {
    Exit-Land "uncommitted changes in $wt; commit or discard them first"
}

git -C $wt rebase -q $spec 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    foreach ($f in @(git -C $wt diff --name-only --diff-filter=U)) { Write-Output "conflict`t$f" }
    Exit-Land "resolve the conflicts in $wt, run: git -C `"$wt`" rebase --continue, then run land again"
}
git merge -q --ff-only $Ticket 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) { Exit-Land "fast-forward of $spec to $Ticket failed; check git status in this worktree" }
git worktree remove $wt 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) { Exit-Land "landed, but could not remove worktree $wt" }
git branch -q -d $Ticket 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) { Exit-Land "landed, but could not delete branch $Ticket" }
Write-Output ("landed`t{0}`t{1}`t{2}" -f $Ticket, $spec, (git rev-parse --short HEAD))
Write-Output "removed`t$wt"
