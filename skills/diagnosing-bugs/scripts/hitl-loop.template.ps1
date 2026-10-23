# Human-in-the-loop reproduction script.
# Copy this file outside the repo, edit the steps between the markers,
# and ask the user to run it in their own terminal:
#   powershell -NoProfile -ExecutionPolicy Bypass -File hitl-loop.template.ps1
#
# Helpers:
#   Step "<instruction>"          show the instruction, wait for Enter
#   Capture NAME "<question>"     show the question, store the answer as NAME
#
# The script ends by printing every captured value as KEY=VALUE.
# Captured values are shown on screen, so never capture a credential;
# put sign-in in a Step instead.

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = 'Stop'

$script:Captured = New-Object System.Collections.Specialized.OrderedDictionary

function Step([string]$Instruction) {
  Write-Host ''
  Write-Host ">>> $Instruction"
  [void](Read-Host '    [Enter when done]')
}

function Capture([string]$Name, [string]$Question) {
  Write-Host ''
  Write-Host ">>> $Question"
  $answer = Read-Host '    >'
  $script:Captured[$Name] = $answer
}

# --- edit below ---------------------------------------------------------

Step 'Open the app at http://localhost:3000 and sign in.'

Capture 'ERRORED' 'Click the Export button. Did it show an error? (y/n)'

Capture 'ERROR_MSG' 'Paste the error message, or type none:'

# --- edit above ---------------------------------------------------------

Write-Host ''
Write-Host '--- Captured ---'
foreach ($key in $script:Captured.Keys) {
  Write-Host ("{0}={1}" -f $key, $script:Captured[$key])
}
