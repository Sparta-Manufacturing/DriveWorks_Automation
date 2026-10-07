<#
Pass when no project rule hard-codes a production location or a personal folder: the production server
(\\192.168.0.19 shares and its SQL Server) or someone's OneDrive. Those values belong in the Environments group
table, read through each project's environment variable (decision 2026-10-05, docs/analysis/dev-prod-workflow.md).
Runs on all live projects; -Project only locates the export root. "Restored Files" (old copies, same project names)
and Specifications are skipped by folder, since Find-DwRule reports project names, not paths.
#>
param([Parameter(Mandatory)][string]$Project, [string]$Group)
Import-Module (Join-Path $PSScriptRoot '..\..\tools\DwTools\DwTools.psm1')
$root = Join-Path $PSScriptRoot '..\..\DriveWorks Files'
$targets = @(Get-ChildItem -LiteralPath $root -Filter *.driveprojx -File) +
    @(Get-ChildItem -LiteralPath $root -Directory | Where-Object Name -notin 'Restored Files', 'Specifications')
$hits = @(@(foreach ($t in $targets) { foreach ($pat in '192.168.0.19', 'OneDrive - ', '\Users\') { Find-DwRule $pat $t.FullName -SimpleMatch } }) |
    Where-Object { $_.Project -notmatch 'Web Kit' } | Sort-Object Project, Location -Unique)
$by = $hits | Group-Object Project | Sort-Object Count -Descending | ForEach-Object { "$($_.Name -replace '^DW ', '') $($_.Count)" }
[pscustomobject]@{ Pass = ($hits.Count -eq 0); Detail = $(if ($hits.Count) { "$($hits.Count) rule(s) in $(@($by).Count) projects: $(($by | Select-Object -First 8) -join ', '); first: $($hits[0].Project -replace '^DW ', '') $($hits[0].Location)" } else { 'no hard-coded production or personal locations' }) }
