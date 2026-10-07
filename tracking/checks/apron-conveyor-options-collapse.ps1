<#
Pass when the Apron left panel never loses its layout without a bottom elbow: for every incline length of a straight,
Top Elbow only and Top Elbow + top run build, CommonSpecsFrame.Height and MotorAndGBFrame.Top evaluate without error.
(The 2026-10-02 bug: the logo position list came out empty at straight 20-21 ft / Top Elbow 16-17 ft.)
#>
param([Parameter(Mandatory)][string]$Project, [string]$Group)
Import-Module (Join-Path $PSScriptRoot '..\..\tools\DwTools\DwFormEngine.psm1')
$probe = New-DwFormSession $Project
$elbow = if ($probe.Controls.ContainsKey('TopElbow')) { 'TopElbow' } else { 'Elbow' }
$ui = @{ CustomerInfoCheckExtend = $false; ConveyorSizeCheckExtend = $false; CommonSpecsCheckExtend = $true; MotorAndGBCheckExtend = $false; SettingsCheckExtend = $false; BottomElbow = $false }
$fails = New-Object System.Collections.Generic.List[string]
$n = 0
foreach ($case in @(@{ Name = 'straight'; E = $false; T = $false; Lo = 14; Hi = 71 }, @{ Name = 'top elbow'; E = $true; T = $false; Lo = 10; Hi = 108 }, @{ Name = 'top elbow + top run'; E = $true; T = $true; Lo = 10; Hi = 108 })) {
    $in = $ui.Clone(); $in[$elbow] = $case.E; $in.TopHorizontalLength = $case.T
    if ($case.T) { $in.Slider_ConveyorTopHorizontalLength = 20; $in.ConveyorTopHorizontalLength = 20 }
    $s = New-DwFormSession $Project -Group $Group -Inputs $in
    foreach ($L in $case.Lo..$case.Hi) {
        Set-DwFormInput $s @{ SLD_ConveyorLength = $L; ConveyorLength = $L }
        $n++
        if (@(Get-DwFormValue $s 'CommonSpecsFrame.Height', 'MotorAndGBFrame.Top' | Where-Object IsError).Count) { $fails.Add("$($case.Name) $L ft") }
    }
}
[pscustomobject]@{ Pass = ($fails.Count -eq 0); Detail = $(if ($fails.Count) { "$($fails.Count) of $n states break the panel: $(($fails | Select-Object -First 6) -join ', ')" } else { "$n states, none break the panel" }) }
