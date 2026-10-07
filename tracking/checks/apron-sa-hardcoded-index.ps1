<#
Pass when no component-set rule reads SectionLayout by hard-coded position (TableGetValue(DWCalcSectionLayout, 7, 29)).
Positions break silently when a column or row is inserted; TableGetColumnIndexByName / DWVLookup on "A29" do not.
#>
param([Parameter(Mandatory)][string]$Project, [string]$Group)
Import-Module (Join-Path $PSScriptRoot '..\..\tools\DwTools\DwTools.psm1')
$hits = @(Find-DwRule 'TableGetValue\(\s*DWCalcSectionLayout\s*,\s*\d+\s*,\s*\d+' $Project)
$forms = @($hits | ForEach-Object { [regex]::Match($_.Rule, 'TableGetValue\(\s*DWCalcSectionLayout\s*,\s*\d+\s*,\s*\d+\s*\)').Value -replace '\s+', '' } | Sort-Object -Unique)
[pscustomobject]@{ Pass = ($hits.Count -eq 0); Detail = $(if ($hits.Count) { "$($hits.Count) rule(s) (project and component parts) use $($forms -join ', ')" } else { 'no positional SectionLayout reads' }) }
