<#
.SYNOPSIS
    Apron: points the file-name rule of all 19 mid-section copies at the SectionLayout calc table's Enable column.
    Each rule becomes  If(Enable of that section, DWVariablePrefixMidSection<n>, "Delete").

    Bottom run  DW10-A02-1 ... -6   -> A02 ... A07, PrefixMidSection1 ... 6
    Incline     DW10-A02-11 ... -19 -> A11 ... A19, PrefixMidSection11 ... 19
    Top run     DW10-A02-21 ... -24 -> A21 ... A24, PrefixMidSection21 ... 24

    The old rules also tested BottomElbowReturn (incline) and ElbowReturn (top). After this change, Enable
    must carry those tests. The sub-assembly file-name rules inside each section are not touched.
.EXAMPLE
    .\tools\scripts\Set-ApronMidSectionFileNameRule.ps1 -Path '.\DriveWorks Files\Apron\DW Apron Project.driveprojx' -WhatIf
.EXAMPLE
    .\tools\scripts\Set-ApronMidSectionFileNameRule.ps1 -Path $src -OutPath '.\work\DW Apron Project.driveprojx'
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][string]$Path,
    [string]$OutPath
)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot '..\DwTools\DwTools.psm1') -Force

$target = $Path
if ($OutPath) {
    Copy-Item -LiteralPath $Path -Destination $OutPath -Force
    (Get-Item -LiteralPath $OutPath).IsReadOnly = $false
    $target = $OutPath
}

$sets = @()
foreach ($n in 1..6)   { $sets += [pscustomobject]@{ Set = $(if ($n -eq 1) { 'DW10-A02-1' } else { "DW10-A02-$n (DW10-A02)" }); Section = ('A{0:00}' -f ($n + 1)); N = $n } }
foreach ($n in 11..19) { $sets += [pscustomobject]@{ Set = "DW10-A02-$n (DW10-A02)"; Section = "A$n"; N = $n } }
foreach ($n in 21..24) { $sets += [pscustomobject]@{ Set = "DW10-A02-$n (DW10-A02)"; Section = "A$n"; N = $n } }

foreach ($s in $sets) {
    $rule = "=If( DWVLookup( ""$($s.Section)"" , DWCalcSectionLayout , 1 , TableGetColumnIndexByName( DWCalcSectionLayout , ""Enable"" ) , FALSE )`r`n" +
            "`t,DWVariablePrefixMidSection$($s.N)`r`n" +
            "`t,""Delete"" )"
    # one backup of the original is enough; -OutPath targets are fresh copies
    $noBackup = [bool]$OutPath -or ($s -ne $sets[0])
    $r = Set-DwComponentSetRule $target $s.Set $rule -NoBackup:$noBackup -WhatIf:$WhatIfPreference
    [pscustomobject]@{ ComponentSet = $s.Set; Section = $s.Section; ChangedParts = ($r.ChangedParts -join ', '); Backup = $r.Backup }
}
