<#
Pass when the largest shipping-assembly count SectionLayout can produce (both elbows, longest runs, widest apron)
fits in the SA component sets of the main assembly. (2026-10-05: up to 10 SAs, but only SA1-SA7 exist.)
#>
param([Parameter(Mandatory)][string]$Project, [string]$Group)
Import-Module (Join-Path $PSScriptRoot '..\..\tools\DwTools\DwFormEngine.psm1')
$x = Get-DwProjectXml $Project project
$sets = @(Select-DwXml $x "//*[local-name()='ComponentSet']" | Where-Object { $_.GetAttribute('Name') -match '^SA\d+ \(Apron Conveyor Assembly\)$' }).Count
$probe = New-DwFormSession $Project
if (-not $probe.CalcTables.ContainsKey('SectionLayout')) { return [pscustomobject]@{ Pass = $false; Detail = 'no SectionLayout calculation table' } }
$elbow = if ($probe.Controls.ContainsKey('TopElbow')) { 'TopElbow' } else { 'Elbow' }
$max = 0; $worst = ''
foreach ($w in '36', '84') {
    $in = @{ BottomElbow = $true; BottomHorizontalLength1 = $true; TopHorizontalLength = $true; ApronWidth = $w }
    $in[$elbow] = $true
    $s = New-DwFormSession $Project -Group $Group -Inputs $in
    foreach ($b in 10, 30, 67) { foreach ($l in 20, 60, 108) { foreach ($t in 7, 30, 60) {
                Set-DwFormInput $s @{ Slider_ConveyorBottomHorizontalLength = $b; ConveyorBottomHorizontalLength = $b; SLD_ConveyorLength = $l; ConveyorLength = $l; Slider_ConveyorTopHorizontalLength = $t; ConveyorTopHorizontalLength = $t }
                $n = [int](@(Get-DwCalcTable $s SectionLayout)[-1].ShippingAssembly)
                if ($n -gt $max) { $max = $n; $worst = "width $w, bottom $b / incline $l / top $t ft" }
            } } }
}
[pscustomobject]@{ Pass = ($max -le $sets); Detail = "up to $max SAs ($worst); $sets SA component sets in the main assembly" }
