<#
Pass when Hopper V2 never builds a drop-zone side panel thinner than the minimum panel height
(constant PanelMinHeight, 4 in, user decision 2026-10-08), or when the form stops the input with an Error instead.
A panel's height is LambdaPanelHeight's: PointTopTailY - OriginY (the height at its tail, under the top cut).
Case 1: a 5 deg top cut leaves K21 1.45 in under the cut line (a sliver).
Case 2: no top cut, a 20 in side over an 18.5 in offset top leaves a 1.5 in second row.
(Spec 46203 had 5.5 in rows and triangle panels; see docs/projects/hopper-v2/learnings.md.)
#>
param([Parameter(Mandatory)][string]$Project, [string]$Group)
Import-Module (Join-Path $PSScriptRoot '..\..\tools\DwTools\DwFormEngine.psm1')
$base = @{
    SameLeftSideAsRightSide = $true; ConveyorType = 'Light Duty Conveyor'; BeltWidth = 36; HopperThickness = '0.125'
    DropZoneOffSetRight = $true; OffSetBottomBendRight = $true; DropZoneBottomBendHeightRight = 2.5
    DropZoneOffSetWidthRight = 16; DropZoneAngleRight = 45; DropZoneHeightRight = 24; DropZoneLengthRight = 6
    DropZoneBackHeight = 39.5; BackAngleOnOff = $false; BeforeElbowLength = 18; MidHopperPanelHeight = 12; TransitionPieceHeightRight = 12
}
$cases = [ordered]@{
    '5 deg cut'           = @{ AngledTopCutRightSide = $true; AngledTopCutRightSideDeg = 5 }
    'no cut, 20 in side'  = @{ AngledTopCutRightSide = $false; DropZoneHeightRight = 20 }
}
$problems = New-Object System.Collections.Generic.List[string]
foreach ($name in $cases.Keys) {
    $in = @{} + $base; foreach ($k in $cases[$name].Keys) { $in[$k] = $cases[$name][$k] }
    $s = New-DwFormSession $Project -Group $Group -StartValues Saved -Inputs $in
    $min = (Get-DwFormValue $s 'DWConstantPanelMinHeight').Value
    if ("$min" -eq '' -or (Get-DwFormValue $s 'DWConstantPanelMinHeight').IsError) { $problems.Add('constant PanelMinHeight missing'); break }
    $stopped = @('DropZoneHeightRightError', 'AngledTopCutRightSideDegError') | Where-Object { "$((Get-DwFormValue $s $_).Value)" -notin '', '0', 'FALSE' }
    if ($stopped) { continue }
    foreach ($row in @(Get-DwCalcTable $s DropZonePanelList | Where-Object { $_.Side -ne 'Back' -and "$($_.Enable)" -eq 'True' })) {
        $k = "$($row.Side)K$($row.PanelKitNumber)"
        $h = [double](Get-DwFormValue $s "DWVariable${k}PointTopTailY").Value - [double](Get-DwFormValue $s "DWVariable${k}OriginY").Value
        if ($h -lt [double]$min) { $problems.Add("${name}: $k built at $([Math]::Round($h, 2)) in (< $min)") }
    }
}
[pscustomobject]@{ Pass = ($problems.Count -eq 0); Detail = $(if ($problems.Count) { "$($problems.Count) thin panel(s): $(($problems | Select-Object -First 4) -join '; ')" } else { 'no side panel under the minimum height is built (or the form stops the input)' }) }
