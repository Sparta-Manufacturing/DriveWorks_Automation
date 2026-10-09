#Requires -Version 5.1
<#
DwSimulate: the DriveWorks side of a model generation, offline. For a set of inputs it evaluates every model rule the
way DriveWorks would before driving SOLIDWORKS: each captured dimension's value, each feature's and instance's state,
each component's new file name (or Delete), custom properties and configurations. Two runs can be compared, and the
values that cannot build (negative or zero sizes, rule errors, patterns under 1) are flagged.

What it cannot tell: what SOLIDWORKS does with those values (sketch solving, mates, rebuild errors). That needs the
models themselves; see docs/formats/simulation.md.

Owner names (what MyName()/MyNumber() read in a model rule):
  Instance rules          <component set>\<instance name>    confirmed (Administrator drill-down, Hopper V2 build)
  Component file names    <component set>\<model name>       confirmed (Hopper V2 build, 2026-10-08)
  Everything else         <component set>\<model name>\<SOLIDWORKS name>   assumed; MyNumber(i) from the left is safe
#>

Set-StrictMode -Off

function Get-DwComponentTree {
    <#
    .SYNOPSIS  The driven component tree of a project: each model file and its parent model (from the nesting of
               pcomp:PC in components/*.xml, resolved to files through the group's captures).
    .EXAMPLE   Get-DwComponentTree $proj | Where-Object Parent -like '*K80*'
    #>
    param([Parameter(Mandatory, Position = 0)][string]$Project, [string]$Group = $env:DW_GROUP_FILE)
    Import-Module (Join-Path $PSScriptRoot 'DwTools.psm1') -Global
    $paths = @{}
    foreach ($row in (Invoke-DwGroupQuery (Resolve-Path -LiteralPath $Group).Path 'SELECT hex(Id) AS H, Path FROM CapturedComponents')) {
        $h = [string]$row.H; $b = New-Object byte[] 16
        for ($i = 0; $i -lt 16; $i++) { $b[$i] = [Convert]::ToByte($h.Substring(2 * $i, 2), 16) }
        $paths[(New-Object Guid (, $b)).ToString('N')] = [IO.Path]::GetFileName([string]$row.Path)
    }
    foreach ($part in (Get-DwProjectPart $Project | Where-Object { $_.Uri -like '/driveProj/components/*.xml' })) {
        $x = Get-DwProjectXml $Project ($part.Uri -replace '^/driveProj/', '' -replace '\.xml$', '')
        foreach ($pc in $x.SelectNodes("//*[local-name()='PC']")) {
            $parent = $pc.ParentNode
            [pscustomobject]@{
                Model = $paths[$pc.GetAttribute('CCRef')]
                Parent = $(if ($parent.LocalName -eq 'PC') { $paths[$parent.GetAttribute('CCRef')] })
                CCRef = $pc.GetAttribute('CCRef'); Part = $part.Uri
            }
        }
    }
}

function Get-DwModelOutput {
    <#
    .SYNOPSIS  Evaluates every model rule of a project for a set of inputs. One row per rule: component set, model,
               kind, SOLIDWORKS name, the value DriveWorks would send, and an Action for instances and components
               (Keep, Delete, Suppress, Unsuppress, Replace -> file). Pass -Session to reuse a DwFormEngine session.
    .EXAMPLE   $o = Get-DwModelOutput '.\Test specification to check\ARD1653\DW Hopper V2.driveprojx' -StartValues Saved
    .EXAMPLE   $o = Get-DwModelOutput $proj -Inputs @{ DropZoneLengthRight = 6 } -Kind Dimension -Model 'DW09B-A32*'
    #>
    param(
        [Parameter(Mandatory, Position = 0)][string]$Project,
        [hashtable]$Inputs = @{}, [hashtable]$OverrideRule = @{}, [hashtable]$Override = @{},
        [ValidateSet('Default', 'Saved')][string]$StartValues = 'Saved',
        [string]$Group = $env:DW_GROUP_FILE, $Session, [string[]]$Kind, [string]$Model = '*'
    )
    Import-Module (Join-Path $PSScriptRoot 'DwTools.psm1') -Global
    Import-Module (Join-Path $PSScriptRoot 'DwFormEngine.psm1') -Global
    if (-not $Session) { $Session = New-DwFormSession $Project -Group $Group -StartValues $StartValues -Inputs $Inputs -OverrideRule $OverrideRule -Override $Override }
    $rules = @(Get-DwModelRule $Project -Group $Group | Where-Object { $_.Rule -and $_.Model -like $Model -and (-not $Kind -or $Kind -contains $_.Kind) })
    foreach ($r in $rules) {
        $base = [IO.Path]::GetFileNameWithoutExtension([string]$r.Model)
        $owner = switch ($r.Kind) {
            'Instance' { "$($r.ComponentSet)\$($r.SolidWorksName)" }
            'Component' { "$($r.ComponentSet)\$base" }
            default { "$($r.ComponentSet)\$base\$($r.SolidWorksName)" }
        }
        $e = Invoke-DwFormRule $Session $r.Rule -Owner $owner
        $name = $(if ($r.SolidWorksName) { $r.SolidWorksName } else { $r.Parameter })
        # Only a component's file-name rule decides Keep/Delete; its path and tags rules don't.
        $action = if ($r.Kind -ne 'Component' -or $name -eq '(File name)') { Get-DwModelAction $r.Kind $e.Value } else { '' }
        [pscustomobject]@{
            ComponentSet = $r.ComponentSet; Model = $r.Model; Kind = $r.Kind; Name = $name
            Value = $e.Value; IsError = $e.IsError; Action = $action
            Key = "$($r.ComponentSet)|$($r.Model)|$($r.Kind)|$($r.SolidWorksName)$($r.Parameter)"
        }
    }
}

function Get-DwModelAction([string]$Kind, [string]$Value) {
    <# What DriveWorks does with an instance, suppression or component value (instance grammar: docs/formats/captured-models.md). #>
    $v = $Value.Trim()
    switch ($Kind) {
        'Component' { if ($v -match '^delete$') { 'Delete' } elseif ($v) { 'Keep as ' + ($v -replace '^\*', '') } else { 'Keep' } }
        'Instance' {
            $parts = @($v -split '\|' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
            $state = $null; $replace = $null
            foreach ($p in $parts) {
                if ($p -match '^<replace(file)?>(?<t>.+)$') { $replace = [IO.Path]::GetFileName($matches.t) }
                elseif ($p -match '^(delete)$') { $state = 'Delete' }
                elseif ($p -match '^(s|suppress|suppressed|false)$') { $state = 'Suppress' }
                elseif ($p -match '^(u|unsuppress|unsuppressed|true)$') { $state = 'Unsuppress' }
            }
            (@($state, $(if ($replace) { "Replace -> $replace" })) | Where-Object { $_ }) -join ', '
        }
        'FeatureSuppressionState' { if ($v -match '^delete$') { 'Delete' } elseif ($v -match '^(s|suppress|suppressed|false)$') { 'Suppress' } elseif ($v -match '^(u|unsuppress|unsuppressed|true)$') { 'Unsuppress' } elseif ($v -eq '') { 'As saved' } else { "? $v" } }
        default { '' }
    }
}

function Compare-DwModelOutput {
    <#
    .SYNOPSIS  What changes in the model between two runs of Get-DwModelOutput (another input, another revision, a rule
               fix): one row per rule whose value differs, plus rules only one side has.
    .EXAMPLE   Compare-DwModelOutput $before $after | Format-Table Kind, Model, Name, Before, After
    #>
    param([Parameter(Mandatory, Position = 0)][object[]]$Reference, [Parameter(Mandatory, Position = 1)][object[]]$Difference, [double]$Tolerance = 0.0005)
    $a = @{}; foreach ($r in $Reference) { $a[$r.Key] = $r }
    $b = @{}; foreach ($r in $Difference) { $b[$r.Key] = $r }
    foreach ($k in (@($a.Keys) + @($b.Keys) | Sort-Object -Unique)) {
        $x = $a[$k]; $y = $b[$k]
        $vx = if ($x) { $x.Value } else { '<no rule>' }; $vy = if ($y) { $y.Value } else { '<no rule>' }
        $dx = 0.0; $dy = 0.0
        $same = if ([double]::TryParse($vx, [ref]$dx) -and [double]::TryParse($vy, [ref]$dy)) { [Math]::Abs($dx - $dy) -le $Tolerance } else { $vx -eq $vy }
        if ($same) { continue }
        $r = if ($y) { $y } else { $x }
        [pscustomobject]@{ Kind = $r.Kind; ComponentSet = $r.ComponentSet; Model = $r.Model; Name = $r.Name; Before = $vx; After = $vy; ActionBefore = $(if ($x) { $x.Action }); ActionAfter = $(if ($y) { $y.Action }) }
    }
}

function Test-DwModelOutput {
    <#
    .SYNOPSIS  Flags model-rule values that cannot build, on parts and features that are actually used:
               RuleError (the rule fails), NotNumber (a dimension that isn't a number), Negative / Zero (a length,
               width, height or quantity), PatternCount (a pattern quantity under 1). Rules of components that are
               deleted, or of features that are deleted or suppressed, are skipped.
    .EXAMPLE   Test-DwModelOutput (Get-DwModelOutput $proj -StartValues Saved)
    #>
    param([Parameter(Mandatory, Position = 0)][object[]]$Output, [string]$Project, [string]$Group = $env:DW_GROUP_FILE, [switch]$IncludeZero, [double]$Tolerance = 1e-6)
    # A model is gone when its own file-name rule or any ancestor's says Delete (-Project gives the tree).
    $deletedModels = @{}; foreach ($o in $Output) { if ($o.Kind -eq 'Component' -and $o.Action -eq 'Delete') { $deletedModels[$o.Model] = $true } }
    if ($Project) {
        $parent = @{}; foreach ($t in (Get-DwComponentTree $Project -Group $Group)) { if ($t.Model -and -not $parent.ContainsKey($t.Model)) { $parent[$t.Model] = $t.Parent } }
        foreach ($m in @($parent.Keys)) {
            $p = $parent[$m]; $guard = 0
            while ($p -and $guard++ -lt 20) { if ($deletedModels.ContainsKey($p)) { $deletedModels[$m] = $true; break }; $p = $parent[$p] }
        }
    }
    $offFeatures = @{}; foreach ($o in $Output) { if ($o.Kind -eq 'FeatureSuppressionState' -and $o.Action -in 'Delete', 'Suppress') { $offFeatures["$($o.Model)|$($o.Name)"] = $true } }
    foreach ($o in $Output) {
        if ($deletedModels.ContainsKey($o.Model)) { continue }
        if ($o.Kind -eq 'Dimension') {
            $feature = ($o.Name -split '@')[-1]
            if ($offFeatures.ContainsKey("$($o.Model)|$feature")) { continue }
        }
        $issue = $null
        if ($o.IsError) { $issue = 'RuleError' }
        elseif ($o.Kind -eq 'Dimension') {
            $d = 0.0
            if (-not [double]::TryParse($o.Value, [ref]$d)) { $issue = 'NotNumber' }
            elseif ($o.Name -match '(?i)qty|count|number') { if ($d -lt 1) { $issue = 'PatternCount' } }
            elseif ($d -lt -$Tolerance) { $issue = 'Negative' }
            elseif ([Math]::Abs($d) -le $Tolerance -and $IncludeZero) { $issue = 'Zero' }
        }
        if ($issue) { [pscustomobject]@{ Issue = $issue; Kind = $o.Kind; Model = $o.Model; Name = $o.Name; Value = $o.Value } }
    }
}

Export-ModuleMember -Function Get-DwComponentTree, Get-DwModelOutput, Compare-DwModelOutput, Test-DwModelOutput
