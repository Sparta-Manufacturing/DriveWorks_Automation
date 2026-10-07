<#
Pass when the "Change Ski Position" warning takes no room unless it applies: with Ski maintenance Position = None,
SkiPositionWarning.Height is 0. (The 2026-10-05 export wraps it in Max( 100, ... ), so it is always 100 px tall.)
#>
param([Parameter(Mandatory)][string]$Project, [string]$Group)
Import-Module (Join-Path $PSScriptRoot '..\..\tools\DwTools\DwFormEngine.psm1')
$s = New-DwFormSession $Project -Group $Group -Inputs @{ CommonSpecsCheckExtend = $true; BottomElbow = $false; SLD_ConveyorLength = 30; ConveyorLength = 30; skimaintenance = 'None' }
$h = Get-DwFormValue $s 'SkiPositionWarning.Height'
$v = Get-DwFormValue $s 'SkiPositionWarningVisible'
$shows = (-not $h.IsError) -and ([double]$h.Value -gt 0) -and ($v.Value -ne 'FALSE')
[pscustomobject]@{ Pass = (-not $shows) -and -not $h.IsError; Detail = "Ski = None: SkiPositionWarning.Height = $($h.Value), Visible = $($v.Value)" }
