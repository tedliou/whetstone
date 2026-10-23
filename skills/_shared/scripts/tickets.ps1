# Usage: tickets.ps1 <issue-number>
# Lists a spec and its tickets with a derived status. Given a ticket, lists
# its parent spec. Output format is documented in skills/_shared/github.md.
# Test hook: WHETSTONE_FIXTURES=<dir> reads <dir>/<n>.json instead of calling gh.
param([string]$Number = '')
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$n = $Number -replace '^#', ''
if ($n -notmatch '^\d+$') {
    Write-Output "error`tusage: tickets <issue-number>"
    exit 1
}

function Get-Issue([string]$num) {
    if ($env:WHETSTONE_FIXTURES) {
        $raw = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $env:WHETSTONE_FIXTURES "$num.json")
        return ($raw | ConvertFrom-Json)
    }
    $query = Join-Path $PSScriptRoot 'tickets.graphql'
    $out = & gh api graphql -F "query=@$query" -F 'owner={owner}' -F 'repo={repo}' -F "n=$num" 2>&1
    $code = $LASTEXITCODE
    $errors = @($out | Where-Object { $_ -is [System.Management.Automation.ErrorRecord] } | ForEach-Object { $_.ToString() })
    if ($code -ne 0) {
        $msg = ''
        if ($errors.Count -gt 0) { $msg = $errors[-1] -replace '^gh: ', '' }
        Write-Output "error`tcould not read issue #${num}: $msg"
        exit 1
    }
    $json = ($out | Where-Object { $_ -isnot [System.Management.Automation.ErrorRecord] }) -join "`n"
    return ($json | ConvertFrom-Json)
}

$data = (Get-Issue $n).data
$issue = $data.repository.issue
if (@($issue.subIssues.nodes).Count -eq 0 -and $null -ne $issue.parent) {
    $data = (Get-Issue ([string]$issue.parent.number)).data
    $issue = $data.repository.issue
}
$me = $data.viewer.login

# Tickets committed on this branch but not merged yet ("Refs #n" trailers).
$refs = @{}
$base = git symbolic-ref --short -q refs/remotes/origin/HEAD 2>$null
if ($base) {
    $log = (git log --format=%B "$base..HEAD" 2>$null) -join "`n"
    foreach ($m in [regex]::Matches($log, '(?i)refs:? +#(\d+)')) { $refs[$m.Groups[1].Value] = $true }
}

if (@($issue.subIssues.nodes).Count -gt 0) {
    Write-Output ("spec`t{0}`t{1}`t{2}" -f $issue.number, $issue.state.ToLower(), $issue.title)
    $tickets = @($issue.subIssues.nodes)
} else {
    Write-Output "spec`t-`t-`t-"
    $tickets = @($issue)
}

$frontier = @()
foreach ($t in $tickets) {
    $num = [string]$t.number
    $cp = '-'
    if ($t.body -match '<!--\s*whetstone:checkpoint\s*-->') { $cp = 'checkpoint' }
    $open = @($t.blockedBy.nodes | Where-Object { $_.state -eq 'OPEN' -and -not $refs.ContainsKey([string]$_.number) } | ForEach-Object { [string]$_.number })
    $logins = @($t.assignees.nodes | ForEach-Object { $_.login })
    $hasPr = @($t.closedByPullRequestsReferences.nodes | Where-Object { $_.state -eq 'OPEN' }).Count -gt 0

    if ($t.state -eq 'CLOSED') {
        if ($t.stateReason -eq 'COMPLETED') { $s = 'closed' } else { $s = 'not-planned' }
    } elseif ($hasPr) { $s = 'in-review' }
    elseif ($refs.ContainsKey($num)) { $s = 'done' }
    elseif ($logins -contains $me) { $s = 'mine' }
    elseif ($logins.Count -gt 0) { $s = 'taken' }
    elseif ($open.Count -gt 0) { $s = 'blocked' }
    else {
        $s = 'ready'
        $frontier += $num
    }
    $blk = '-'
    if ($open.Count -gt 0) { $blk = $open -join ',' }
    Write-Output ("ticket`t{0}`t{1}`t{2}`t{3}`t{4}" -f $num, $s, $cp, $blk, $t.title)
}
$f = '-'
if ($frontier.Count -gt 0) { $f = $frontier -join ',' }
Write-Output "frontier`t$f"
