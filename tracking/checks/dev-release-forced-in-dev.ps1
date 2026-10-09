<#
Pass when, in every project that has a Dev Release check box, Dev Release is TRUE outside production (the dev group
has no Autopilot), even for an Engineering user who left the box unchecked; and in production it is never forced on
(an Engineering user with the box unchecked gets FALSE).
Decision 2026-10-09 (user): Claude's ClaudeAI user stays a plain Engineering user, to see what other engineering
users see; Dev Release reads DWVariableIsProductionEnvironment and is overwritten to TRUE when it is FALSE.
Runs on all projects; -Project only locates the export root.
#>
param([Parameter(Mandatory)][string]$Project, [string]$Group)
Import-Module (Join-Path $PSScriptRoot '..\..\tools\DwTools\DwTools.psm1')
Import-Module (Join-Path $PSScriptRoot '..\..\tools\DwTools\DwFormEngine.psm1')
$root = Join-Path $PSScriptRoot '..\..\DriveWorks Files'
if (-not $Group) { $Group = Join-Path $root 'Sparta DW Group for Claude.drivegroup' }
$problems = New-Object System.Collections.Generic.List[string]; $n = 0
foreach ($f in (Get-ChildItem -LiteralPath $root -Recurse -Filter *.driveprojx | Where-Object { $_.FullName -notmatch '\\(Restored Files|Specifications)\\' })) {
    if (-not @(Get-DwControl $f.FullName | Where-Object Name -eq 'DevRelease').Count) { continue }
    $n++
    $dev = New-DwFormSession $f.FullName -Group $Group -Teams 'Engineering' -GroupName 'Sparta DW Group for Claude' -Inputs @{ DevRelease = $false }
    if ("$((Get-DwFormValue $dev 'DevReleaseReturn').Value)" -ne 'TRUE') { $problems.Add("$($f.BaseName): not TRUE in dev") }
    $prod = New-DwFormSession $f.FullName -Group $Group -Teams 'Engineering' -GroupName 'Sparta Manufacturing Group' -Inputs @{ DevRelease = $false }
    if ("$((Get-DwFormValue $prod 'DevReleaseReturn').Value)" -eq 'TRUE') { $problems.Add("$($f.BaseName): forced TRUE in prod") }
}
[pscustomobject]@{ Pass = ($problems.Count -eq 0 -and $n -gt 0); Detail = $(if ($problems.Count) { "$($problems.Count) of $n project(s): $(($problems | Select-Object -First 5) -join '; ')" } else { "Dev Release forced on in dev and left as-is in prod, in all $n projects that have it" }) }
