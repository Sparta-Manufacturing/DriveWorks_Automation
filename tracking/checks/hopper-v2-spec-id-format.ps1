<#
Pass when DW Hopper V2 - Panels writes its models into the same folder Hopper V2 replaces its dummies from, for a
spec id below 1000. V2: FilePath = ServerOutputFileLocation & DWSpecification, with DWSpecification =
prefix & "-Hopper " & Text(DWSpecificationID,"0000"). Panels: SWFileLocation built from the HostedSpecificationId V2
sends (the raw id). Found 2026-10-09 on test specs CAI01-Hopper 0008 / CAI02-Hopper 0009: the panels went to
"CAI01-Hopper 8", so every dummy that should be replaced stayed a dummy. Spec ids of 1000 and up (production) match.
-Project is V2; Panels is found next to it.
#>
param([Parameter(Mandatory)][string]$Project, [string]$Group)
Import-Module (Join-Path $PSScriptRoot '..\..\tools\DwTools\DwFormEngine.psm1')
$panels = Join-Path (Split-Path -Parent $Project) 'DW Hopper V2 - Panels.driveprojx'
$problems = New-Object System.Collections.Generic.List[string]
foreach ($id in 8, 123, 46203) {
    $v2 = New-DwFormSession $Project -Group $Group -StartValues Saved -Inputs @{ WOPrefix = 'CAI99' } -Override @{ DWSpecificationId = $id }
    $want = [string](Get-DwFormValue $v2 'DWVariableFilePath').Value
    $p = New-DwFormSession $panels -Group $Group -StartValues Saved -Inputs @{ WOPrefix = 'CAI99' } -Override @{ DWConstantHostedSpecificationId = $id; DWConstantOpennedFromHost = $true }
    $got = [string](Get-DwFormValue $p 'DWVariableSWFileLocation').Value
    if ($got.TrimEnd('\') -ne $want.TrimEnd('\')) { $problems.Add("id ${id}: Panels models '$(Split-Path $got -Leaf)' vs V2 '$(Split-Path $want -Leaf)'") }
    # Consistency: Panels' spec record folder uses the same formatted name.
    $rec = [string](Get-DwFormValue $p 'DWSpecificationPath').Value
    if ((Split-Path $rec.TrimEnd('\') -Leaf) -ne (Split-Path $want.TrimEnd('\') -Leaf)) { $problems.Add("id ${id}: Panels spec record '$(Split-Path $rec -Leaf)' vs V2 '$(Split-Path $want -Leaf)'") }
}
[pscustomobject]@{ Pass = ($problems.Count -eq 0); Detail = $(if ($problems.Count) { $problems -join '; ' } else { 'Panels models go to the folder V2 replaces from (ids 8, 123, 46203)' }) }
