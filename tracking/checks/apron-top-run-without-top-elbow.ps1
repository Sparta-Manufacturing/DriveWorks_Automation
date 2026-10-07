<#
Pass when no top-run mid-section (A21-A28) is enabled without a top elbow, even when the hidden top horizontal
slider still holds a value from when Top Elbow was on.
(2026-10-06: MidSectionA21toA28Length = top slider - head, with no TopElbow test, so turning Top Elbow off after
setting 25 ft kept A21-A23 enabled in SectionLayout.)
#>
param([Parameter(Mandatory)][string]$Project, [string]$Group)
Import-Module (Join-Path $PSScriptRoot '..\..\tools\DwTools\DwFormEngine.psm1')
$probe = New-DwFormSession $Project
if (-not $probe.CalcTables.ContainsKey('SectionLayout')) { return [pscustomobject]@{ Pass = $false; Detail = 'no SectionLayout calculation table' } }
$elbow = if ($probe.Controls.ContainsKey('TopElbow')) { 'TopElbow' } else { 'Elbow' }
$problems = New-Object System.Collections.Generic.List[string]
foreach ($be in $true, $false) {
    $in = @{ BottomElbow = $be; SLD_ConveyorLength = 30; TopHorizontalLength = $true; Slider_ConveyorTopHorizontalLength = 25 }
    $in[$elbow] = $true
    $s = New-DwFormSession $Project -Group $Group -Inputs $in
    Set-DwFormInput $s @{ $elbow = $false }
    $on = @(Get-DwCalcTable $s SectionLayout | Where-Object { $_.SectionNumber -match '^A2[1-8]$' -and $_.Enable -eq 'TRUE' })
    if ($on.Count) { $problems.Add("BottomElbow=$be, top slider 25 then $elbow off: $(($on.SectionNumber) -join ',') enabled") }
}
[pscustomobject]@{ Pass = ($problems.Count -eq 0); Detail = $(if ($problems.Count) { $problems -join '; ' } else { 'A21-A28 all off without a top elbow (top slider left at 25 ft)' }) }
