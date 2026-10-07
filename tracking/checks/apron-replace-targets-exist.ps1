<#
Pass when every "<Replace><component set>" in the project's model rules names a component set that exists.
(2026-10-06: the SA4-SA7 belt/chain slots, V1 and V2, insert DW10-A50/A51/A52-SA4..SA7, but only -SA1..-SA3 exist.)
#>
param([Parameter(Mandatory)][string]$Project, [string]$Group)
Import-Module (Join-Path $PSScriptRoot '..\..\tools\DwTools\DwTools.psm1')
$x = Get-DwProjectXml $Project project
$sets = @{}; foreach ($cs in Select-DwXml $x "//*[local-name()='ComponentSet']") { $sets[$cs.GetAttribute('Name')] = $true }
$missing = @{}
foreach ($r in Get-DwModelRule $Project -Group $Group -Kind Instance) {
    foreach ($m in [regex]::Matches($r.Rule, '<Replace>([^"]+)"(?!\s*&)')) {
        $t = $m.Groups[1].Value
        if (-not $sets.ContainsKey($t)) { $missing[$t] = 1 + [int]$missing[$t] }
    }
}
[pscustomobject]@{ Pass = ($missing.Count -eq 0); Detail = $(if ($missing.Count) { "$($missing.Count) missing set(s): $((@($missing.Keys | Sort-Object) | ForEach-Object { "$_ ($($missing[$_]))" }) -join ', ')" } else { 'every <Replace> target exists' }) }
