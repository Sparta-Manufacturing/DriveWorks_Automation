<#
Pass when the shipping assemblies of the no-top-elbow assembly (Apron Conveyor Assembly V2) are driven by SectionLayout
like the main assembly's:
- every V2 SA set places its sections (DummyASMA -2..-19, -29) from SectionLayout;
- the V2 top level inserts SA2 and up only when SectionLayout needs them, and has a slot for every V2 SA set.
(2026-10-05: SA1-SA3 (V2) are always built, whatever the weight. 2026-10-06: SA4-SA7 (V2) added and their
section placeholders rewritten; the top level still always inserts SA1-SA3 only.)
#>
param([Parameter(Mandatory)][string]$Project, [string]$Group)
Import-Module (Join-Path $PSScriptRoot '..\..\tools\DwTools\DwTools.psm1')
$rules = @(Get-DwModelRule $Project -Group $Group -Kind Instance | Where-Object { $_.ComponentSet -match 'Apron Conveyor Assembly V2' -and $_.Parameter -match '^DummyASMA -\d+$' })
$sets = @($rules | Where-Object { $_.ComponentSet -match '^SA\d+ \(' } | ForEach-Object ComponentSet | Select-Object -Unique)
$problems = New-Object System.Collections.Generic.List[string]
foreach ($set in $sets) {
    $static = @($rules | Where-Object { $_.ComponentSet -eq $set -and [int]($_.Parameter -replace '\D', '') -in (@(2..19) + 29) -and $_.Rule -notmatch 'DWCalcSectionLayout' })
    if ($static.Count) { $problems.Add("$set`: $($static.Count) section slot(s) not from SectionLayout") }
}
$top = @($rules | Where-Object { $_.ComponentSet -eq 'Apron Conveyor Assembly V2' -and $_.Rule -match '<Replace>SA(\d+) \(' })
foreach ($set in $sets) {
    $k = [int]($set -replace '^SA(\d+).*', '$1')
    $slot = @($top | Where-Object { $_.Rule -match "<Replace>SA$k \(" })
    if (-not $slot.Count) { $problems.Add("top level has no slot for SA$k") }
    elseif ($k -gt 1 -and $slot[0].Rule -notmatch 'DWCalcSectionLayout') { $problems.Add("top level always inserts SA$k") }
}
[pscustomobject]@{ Pass = ($sets.Count -gt 0 -and $problems.Count -eq 0); Detail = $(if ($problems.Count) { $problems -join '; ' } else { "$($sets.Count) V2 SA sets driven by SectionLayout, all inserted by the top level" }) }
