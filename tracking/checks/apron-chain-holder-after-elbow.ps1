<#
Pass when the first section after each elbow (A11 after A10, A21 after A20) always keeps "Chain holder for shipping".
The elbows have no chain holder, and they always start their SA, so without this an SA that starts with an
elbow has no holder at its start. (2026-10-07: holder 1 was kept only when the section was First, or Last and <= 48 in.)
#>
param([Parameter(Mandatory)][string]$Project, [string]$Group)
Import-Module (Join-Path $PSScriptRoot '..\..\tools\DwTools\DwTools.psm1')
$r = @(Get-DwModelRule $Project -Group $Group -Kind FeatureSuppressionState | Where-Object { $_.ComponentSet -match '^DW10-A02-(11|21) \(' -and $_.Parameter -eq 'Chain holder for shipping' })
$bad = @($r | Where-Object { ($_.Rule -replace '\s', '') -ne '=TRUE' } | ForEach-Object ComponentSet)
[pscustomobject]@{ Pass = ($r.Count -eq 2 -and $bad.Count -eq 0); Detail = $(if ($r.Count -ne 2) { "found $($r.Count) of 2 rules" } elseif ($bad.Count) { "conditional in: $($bad -join ', ')" } else { 'A11 and A21 always keep chain holder 1' }) }
