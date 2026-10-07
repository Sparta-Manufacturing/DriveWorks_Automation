<#
Pass when an error anywhere in the Conveyor Options height chain can no longer collapse the left panel: with
LogoWarning.Height or SpartaLogoPosition.Height forced into error, CommonSpecsFrame.Height and MotorAndGBFrame.Top
still evaluate. (Recommended 2026-10-02 as fix 3: IfError around CommonSpecsExtend.Height.)
#>
param([Parameter(Mandatory)][string]$Project, [string]$Group)
Import-Module (Join-Path $PSScriptRoot '..\..\tools\DwTools\DwFormEngine.psm1')
$bad = @()
foreach ($slot in 'LogoWarning.Height', 'SpartaLogoPosition.Height') {
    $s = New-DwFormSession $Project -Group $Group -Inputs @{ CommonSpecsCheckExtend = $true } -OverrideRule @{ $slot = 'Indirect("DWVariableForcedError")' }
    if (@(Get-DwFormValue $s 'CommonSpecsFrame.Height', 'MotorAndGBFrame.Top' | Where-Object IsError).Count) { $bad += $slot }
}
[pscustomobject]@{ Pass = ($bad.Count -eq 0); Detail = $(if ($bad.Count) { "an error in $($bad -join ' or ') still collapses the panel" } else { 'forced errors in the chain no longer collapse the panel' }) }
