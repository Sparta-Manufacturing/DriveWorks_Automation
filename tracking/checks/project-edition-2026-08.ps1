<#
Pass when every project registered in the dev group is on project edition 2026-08 (Project Settings > Project edition),
stored as Edition="260800" on the <Project> root of project.xml. No attribute means 2025-09, the pre-24.0 default.
The edition changes how dates without a time become text (invariant instead of regional), which shows in the
Today() drawing properties and the Order Project date texts. Decision 2026-10-06: accepted, switch all projects.
Runs on all projects; -Project only locates the export root.
#>
param([Parameter(Mandatory)][string]$Project, [string]$Group)
Import-Module (Join-Path $PSScriptRoot '..\..\tools\DwTools\DwTools.psm1')
$root = Join-Path $PSScriptRoot '..\..\DriveWorks Files'
if (-not $Group) { $Group = Join-Path $root 'Sparta DW Group for Claude.drivegroup' }
$old = foreach ($p in @(Get-DwGroupProject $Group)) {
    $f = Join-Path $p.Directory "$($p.Name).driveprojx"
    if (-not (Test-Path -LiteralPath $f)) { continue }
    $ed = (Get-DwProjectXml $f).DocumentElement.GetAttribute('Edition')
    if ($ed -ne '260800') { "$($p.Name -replace '^DW ', '') ($(if ($ed) { $ed } else { '2025-09' }))" }
}
$old = @($old)
[pscustomobject]@{ Pass = ($old.Count -eq 0); Detail = $(if ($old.Count) { "$($old.Count) project(s) not on 2026-08: $(($old | Select-Object -First 8) -join ', ')" } else { 'all projects on edition 2026-08' }) }
