<#
Pass when every mid-section copy (DW10-A02-n component sets) takes its "keep or delete" from the SectionLayout
Enable column, so section existence is decided in one table. (Proposed 2026-09-28 with a DWVLookup on the section
name; production did it 2026-10-05 with a lookup on MidSectionNumber - any SectionLayout/Enable lookup passes.)
#>
param([Parameter(Mandatory)][string]$Project, [string]$Group)
Import-Module (Join-Path $PSScriptRoot '..\..\tools\DwTools\DwTools.psm1')
$x = Get-DwProjectXml $Project project
$sets = @(Select-DwXml $x "//*[local-name()='ComponentSet']" | Where-Object { $_.GetAttribute('Name') -match '^DW10-A02-\d+' })
$not = @($sets | Where-Object { $r = $_.SelectSingleNode("*[local-name()='Rule']").InnerText; -not ($r -match 'DWCalcSectionLayout' -and $r -match '"Enable"') } | ForEach-Object { $_.GetAttribute('Name') })
[pscustomobject]@{ Pass = ($sets.Count -gt 0 -and $not.Count -eq 0); Detail = "$($sets.Count) mid-section sets; not using SectionLayout Enable: $(if ($not.Count) { $not -join ', ' } else { 'none' })" }
