<#
Pass when a leg position typed to 0.01 in (105.37) survives every leg position slider (LegA40-A44PositionSlider).
The text box's DefaultValue follows its slider, and DriveWorks snaps a slider's value to its Increment
(Slider.EffectiveValue: Round(value / Increment, 0) * Increment, DriveWorks.Engine 24.0.1.4), so an Increment
of 1 turns 105.37 into 105. Kit Conveyor uses 0.01.
#>
param([Parameter(Mandatory)][string]$Project, [string]$Group)
Import-Module (Join-Path $PSScriptRoot '..\..\tools\DwTools\DwTools.psm1')
$typed = 105.37
$problems = New-Object System.Collections.Generic.List[string]
foreach ($i in 40..44) {
    $ctrl = "LegA${i}PositionSlider"
    $inc = @(Get-DwControlProperty $Project -Form "LegA$i" -Control $ctrl | Where-Object Property -eq 'Increment')
    if ($inc.Count -eq 0 -or "$($inc[0].Text)" -eq '') { $problems.Add("$ctrl has no Increment"); continue }
    $step = [double]$inc[0].Text
    $snapped = [Math]::Round($typed / $step, 0) * $step
    if ([Math]::Abs($snapped - $typed) -gt 1e-9) { $problems.Add("$ctrl Increment $step turns $typed into $snapped") }
}
[pscustomobject]@{ Pass = ($problems.Count -eq 0); Detail = $(if ($problems.Count) { $problems -join '; ' } else { "all five leg position sliders keep $typed (0.01 in steps)" }) }
