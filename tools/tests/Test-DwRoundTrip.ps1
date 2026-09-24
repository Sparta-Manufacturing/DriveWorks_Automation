#Requires -Version 5.1
<#
.SYNOPSIS
    Fidelity test for DwTools: loads every XML part of every project, writes it back unchanged
    (Edit-DwProject -ForceWrite) into a temp copy, and compares the parts byte-for-byte.

    If every part comes back identical, DwTools' reader/writer is lossless for these files, so
    any difference after a real edit is the edit itself.
.EXAMPLE
    .\tools\tests\Test-DwRoundTrip.ps1 -Path '.\DriveWorks Files'
#>
param([string]$Path = (Join-Path $PSScriptRoot '..\..\DriveWorks Files'))

Import-Module (Join-Path $PSScriptRoot '..\DwTools\DwTools.psm1') -Force

$outDir = Join-Path $env:TEMP 'DwTools-roundtrip'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$results = foreach ($file in Get-ChildItem -LiteralPath $Path -Recurse -File -Filter *.driveprojx) {
    $out = Join-Path $outDir ([guid]::NewGuid().ToString() + '.driveprojx')   # names repeat (e.g. 'Restored Files' copies)
    $edit = Edit-DwProject -Path $file.FullName -OutPath $out -ForceWrite -ScriptBlock {
        param($p)
        foreach ($name in $p.GetPartNames()) { [void]$p.GetXml($name) }
    }
    $diff = @(Compare-DwProject $file.FullName $out | Where-Object Status -ne 'Same')
    [pscustomobject]@{
        Project      = $file.FullName.Substring((Resolve-Path -LiteralPath $Path).Path.Length).TrimStart('\')
        PartsWritten = $edit.ChangedParts.Count
        Identical    = ($diff.Count -eq 0)
        Differences  = ($diff | ForEach-Object { "$($_.Part) [$($_.Status) @ byte $($_.FirstDifferenceAt)]" }) -join '; '
    }
    Remove-Item -LiteralPath $out -Force
}

$results | Format-Table -AutoSize -Wrap
$failed = @($results | Where-Object { -not $_.Identical })
if ($failed.Count) { Write-Warning "$($failed.Count) project(s) did not round-trip byte-identically."; exit 1 }
Write-Host "All $(@($results).Count) projects round-tripped byte-identically." -ForegroundColor Green
