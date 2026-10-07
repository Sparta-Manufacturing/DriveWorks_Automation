<#
Pass when SectionLayout marks every shipping assembly correctly: the first enabled section of each SA is "First" and,
when the SA has more than one enabled section, the last enabled one is "Last" - also when disabled rows follow it.
(2026-10-05: FirstLastInShippingAssy compared with the next row only, so A02/A04, A14, A22... were never "Last",
and the lifting braces / chain holders that depend on it were deleted.)
#>
param([Parameter(Mandatory)][string]$Project, [string]$Group)
Import-Module (Join-Path $PSScriptRoot '..\..\tools\DwTools\DwFormEngine.psm1')
$probe = New-DwFormSession $Project
if (-not $probe.CalcTables.ContainsKey('SectionLayout')) { return [pscustomobject]@{ Pass = $false; Detail = 'no SectionLayout calculation table' } }
$elbow = if ($probe.Controls.ContainsKey('TopElbow')) { 'TopElbow' } else { 'Elbow' }
$problems = New-Object System.Collections.Generic.List[string]
foreach ($c in @(@{ B = 10; L = 40; T = 20; W = '60' }, @{ B = 30; L = 40; T = 20; W = '60' }, @{ B = 67; L = 108; T = 60; W = '84' })) {
    $in = @{ BottomElbow = $true; BottomHorizontalLength1 = $true; Slider_ConveyorBottomHorizontalLength = $c.B; ConveyorBottomHorizontalLength = $c.B; SLD_ConveyorLength = $c.L; ConveyorLength = $c.L; TopHorizontalLength = $true; Slider_ConveyorTopHorizontalLength = $c.T; ConveyorTopHorizontalLength = $c.T; ApronWidth = $c.W }
    $in[$elbow] = $true
    $s = New-DwFormSession $Project -Group $Group -Inputs $in
    $t = @(Get-DwCalcTable $s SectionLayout | Where-Object Enable -eq 'TRUE')
    foreach ($sa in ($t | Group-Object ShippingAssembly)) {
        $rows = @($sa.Group)
        if ($rows[0].FirstLastInShippingAssy -ne 'First') { $problems.Add("$($c.B)/$($c.L)/$($c.T) ft SA$($sa.Name): $($rows[0].SectionNumber) not First") }
        if ($rows.Count -gt 1 -and $rows[-1].FirstLastInShippingAssy -ne 'Last') { $problems.Add("$($c.B)/$($c.L)/$($c.T) ft SA$($sa.Name): $($rows[-1].SectionNumber) not Last") }
    }
}
[pscustomobject]@{ Pass = ($problems.Count -eq 0); Detail = $(if ($problems.Count) { "$($problems.Count) problem(s): $(($problems | Select-Object -First 5) -join '; ')" } else { 'every SA has its First and Last section marked (3 both-elbow layouts)' }) }
