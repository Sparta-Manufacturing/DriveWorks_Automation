<#
Pass when Hopper V2's drop-zone side never drops below the minimum panel height (constant PanelMinHeight) before
the drop zone ends, whatever the top-cut angle: side height at the drop-zone end =
DZHeight - tan(cut) * (DZLength*12 - K13OriginZDiff) >= PanelMinHeight.
(Spec 46203 rev 7: a 20 deg cut on a 24 in side reached 0 at 59.1 in while the drop zone ran to 70.3 in, leaving an
11 in gap before the 12 in transition. User decision 2026-10-08: no limit on the angle; the drop zone stops where
the cut comes down to PanelMinHeight.)
Cases: 20 deg cut on a 6 ft drop zone; the same with the rev 7 back angle (60 deg backward, ending at 16 in);
the rev 6 input of 69 ft.
#>
param([Parameter(Mandatory)][string]$Project, [string]$Group)
Import-Module (Join-Path $PSScriptRoot '..\..\tools\DwTools\DwFormEngine.psm1')
$base = @{
    SameLeftSideAsRightSide = $true; ConveyorType = 'Light Duty Conveyor'; BeltWidth = 36
    DropZoneOffSetRight = $true; OffSetBottomBendRight = $true; DropZoneBottomBendHeightRight = 2.5
    DropZoneOffSetWidthRight = 16; DropZoneAngleRight = 45; DropZoneHeightRight = 24; DropZoneLengthRight = 6
    DropZoneBackHeight = 39.5; BackAngleOnOff = $false; BeforeElbowLength = 18; MidHopperPanelHeight = 12; TransitionPieceHeightRight = 12
    AngledTopCutRightSide = $true; AngledTopCutRightSideDeg = 20
}
$cases = [ordered]@{
    '20 deg, 6 ft'                = @{}
    '20 deg, 6 ft, back angle 60' = @{ BackAngleOnOff = $true; BackAngleDeg = 60; BackAngleDirection = 'Backward'; EndOfBackAngleOnOff = $true; DimforEndofBackAngleVerticalDim = 16; OffSetBottomBendBack = $true; DimForStartofBackAngleVerticalDim = 2.5; ConveyorAngle = 7 }
    '20 deg, 69 ft'               = @{ DropZoneLengthRight = 69 }
}
$problems = New-Object System.Collections.Generic.List[string]; $ends = @()
foreach ($name in $cases.Keys) {
    $in = @{} + $base; foreach ($k in $cases[$name].Keys) { $in[$k] = $cases[$name][$k] }
    $s = New-DwFormSession $Project -Group $Group -StartValues Saved -Inputs $in
    $g = { param($n) $v = Get-DwFormValue $s $n; if ($v.IsError) { throw "$n is in error ($($v.Value))" }; [double]"$($v.Value)" }
    try {
        $min = & $g 'DWConstantPanelMinHeight'
        foreach ($side in 'Right', 'Left') {
            $end = (& $g "DWVariableDZHeight$side") - [Math]::Tan((& $g "DWVariableAngledTopCut$(if ($side -eq 'Right') { 'RightSideDeg' } else { 'LeftSideDeg' })") * [Math]::PI / 180) * ((& $g "DWVariableDZLength$side") * 12 - (& $g "DWVariableK13OriginZDiff$side"))
            $ends += "$name $side $([Math]::Round($end, 2))"
            if ($end -lt $min - 0.01) { $problems.Add("${name}, ${side}: side is $([Math]::Round($end, 2)) in at the drop-zone end (< $min)") }
        }
        # The design keeps the sections after the drop zone on the conveyors' 12 in bolt grid: the drop zone is whole
        # typed feet plus the conveyor adjustment (absorbed by the first column), so section starts minus the
        # adjustment are multiples of 12 in.
        $adj = & $g 'DWVariableK1XLengthModificationByTypeOfConveyor'
        $dz = (& $g 'DWVariableDZLengthRight') * 12
        foreach ($p in @(@('transition', $dz), @('mid panels', $dz + 12 * (& $g 'DWVariableTransitionPannelLengthRight') + 12 * (& $g 'DWVariableDoubleTransitionPannelLengthRight')))) {
            $c = ($p[1] - $adj) / 12
            if ([Math]::Abs($c - [Math]::Round($c)) -gt 0.0005) { $problems.Add("${name}: $($p[0]) starts at $([Math]::Round($p[1], 3)) in, off the 12 in grid") }
        }
    } catch { $problems.Add("${name}: $($_.Exception.Message)") }
}
[pscustomobject]@{ Pass = ($problems.Count -eq 0); Detail = $(if ($problems.Count) { "$($problems.Count) problem(s): $(($problems | Select-Object -First 3) -join '; ')" } else { "side stays at or above PanelMinHeight to the drop-zone end, and the sections after it stay on the 12 in grid, in all 3 cases" }) }
