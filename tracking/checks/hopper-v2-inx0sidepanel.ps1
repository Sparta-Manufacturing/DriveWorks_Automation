<#
Pass when BoltZoneTable's InX0SidePanel gives each bolt zone only its share of the side's bottom row
(0 -> 1RowHeight): a zone that starts at or above the top of that row gets FALSE/0, so the shares add up to the row.
(2026-10-08: the last branch returned the zone's end height, [5L] - 0, so zone 3C got 39.5 in on an 18.5 in row.
On family R531 that turned on a 3-hole Forward C bolt pattern in a 2.5 in section: likely the rev 7 K10 red X.)
Cases: back taller than the side (spec 46203), side taller than the back, and both the same height.
#>
param([Parameter(Mandatory)][string]$Project, [string]$Group)
Import-Module (Join-Path $PSScriptRoot '..\..\tools\DwTools\DwFormEngine.psm1')
$base = @{
    SameLeftSideAsRightSide = $true; ConveyorType = 'Light Duty Conveyor'; BeltWidth = 36
    DropZoneOffSetRight = $true; OffSetBottomBendRight = $true; DropZoneBottomBendHeightRight = 2.5
    DropZoneOffSetWidthRight = 16; DropZoneAngleRight = 45; DropZoneLengthRight = 6; BeforeElbowLength = 18
    AngledTopCutRightSide = $false; BackAngleOnOff = $false
}
$cases = [ordered]@{ 'back taller' = @{ DropZoneHeightRight = 24; DropZoneBackHeight = 39.5 }; 'side taller' = @{ DropZoneHeightRight = 40; DropZoneBackHeight = 24 }; 'same height' = @{ DropZoneHeightRight = 24; DropZoneBackHeight = 24 } }
$problems = New-Object System.Collections.Generic.List[string]
foreach ($name in $cases.Keys) {
    $in = @{} + $base; foreach ($k in $cases[$name].Keys) { $in[$k] = $cases[$name][$k] }
    $s = New-DwFormSession $Project -Group $Group -StartValues Saved -Inputs $in
    foreach ($side in 'Right', 'Left') {
        $row = [double](Get-DwFormValue $s "DWVariable1RowHeight$side").Value
        $sum = 0.0
        foreach ($z in @(Get-DwCalcTable $s BoltZoneTable | Where-Object { $_.Side -eq $side -and "$($_.Enable)" -eq 'True' })) {
            $v = 0.0; [void][double]::TryParse("$($z.InX0SidePanel)", [ref]$v); $sum += $v
            if ([double]$z.StartYDim -ge $row -and $v -ne 0) { $problems.Add("${name}, $side $($z.Zone) (starts at $($z.StartYDim), row ends at $row): InX0SidePanel = $v") }
        }
        if ([Math]::Abs($sum - $row) -gt 0.001) { $problems.Add("${name}, ${side}: bottom-row shares add up to $sum, row is $row") }
    }
}
[pscustomobject]@{ Pass = ($problems.Count -eq 0); Detail = $(if ($problems.Count) { "$($problems.Count) problem(s): $(($problems | Select-Object -First 3) -join '; ')" } else { 'bottom-row bolt-zone shares add up to the row in all 3 cases' }) }
