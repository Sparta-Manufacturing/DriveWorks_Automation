#Requires -Version 5.1
<#
DwSpa: reads Sparta .spa files (what SOLIDWORKS actually built) and checks them against what the DriveWorks rules asked for.

A .spa is a ZIP of manifest.json + data.json (one record per component occurrence: name, configuration, quantities,
class, sheet-metal blank and bends, mass) + model.step, written by the DataExtractionMacro. The format and its reference
reader live in the Solidworks_Automation repo (modules/spa_format); this module imports that reader instead of copying it.
It does NOT record instance numbers (Dummy-8), suppression states, rebuild errors or dimensions.

  Find-DwSpa           path of a bundle by name ('CAI03'), in the inbox (SPA files\), SPA files\Specs or \Masters
  Move-DwSpa           files a checked bundle (.spa + .xlsx) from the inbox into Specs or Masters
  Read-DwSpa           records + parsed Sparta names (WO, A##, K##, colour, part suffix, Key without WO/colour)
  Get-DwSpaKit         one row per built kit: qty, its parts, the main panel's blank size, thickness, bends
  Compare-DwSpa        two builds side by side (added / removed / qty / blank size)
  Test-DwHopperV2Build a Hopper V2 build against its spec: expected kits (V2's own rules, evaluated with the spec's
                       inputs) vs the .spa; leftover dummies; panel family (Panels shape) per drop-zone panel
  Get-DwGenerationIssue DriveWorks' generation log (group DB, read-only): rebuild failures, missing dimensions, ...

Every -Path/-Spa parameter takes a path or a name Find-DwSpa resolves to one bundle.
#>

Set-StrictMode -Off
$script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
# The SOLIDWORKS macro saves into the root (the inbox); checked bundles live in Specs and Masters.
$script:SpaRoot = Join-Path $script:RepoRoot 'SPA files'

function Import-DwSpaReader {
    <# Loads SpaFile.psm1 from $env:DW_SPA_LIB, else the sibling Solidworks_Automation checkout. #>
    if (Get-Command Read-SpaFile -ErrorAction SilentlyContinue) { return }
    $candidates = @($env:DW_SPA_LIB, (Join-Path $script:RepoRoot '..\Solidworks_Automation\modules\spa_format\lib\powershell\SpaFile.psm1')) | Where-Object { $_ }
    foreach ($c in $candidates) { if (Test-Path -LiteralPath $c) { Import-Module $c -Global -Force; return } }
    throw "SPA reader not found. Clone Solidworks_Automation next to this repo, or set `$env:DW_SPA_LIB to ...\modules\spa_format\lib\powershell\SpaFile.psm1."
}

function ConvertTo-DwSpaName([string]$Name) {
    <# Parses a Sparta component name: <WO>-A<n>-K<n>[A-D]-<rest>. Colour '-XX-YD' is pulled out so two builds compare. #>
    $o = [ordered]@{ WO = ''; Assembly = ''; Kit = ''; Colour = ''; Suffix = ''; Key = $Name; IsDummy = ($Name -match 'Dummy') }
    if ($Name -match '^(?<wo>.+?)-A(?<a>\d+)-K(?<k>\d+[A-D]?)(?:-(?<rest>.*))?$') {
        $o.WO = $matches.wo; $o.Assembly = "A$($matches.a)"; $o.Kit = "K$($matches.k)"
        $rest = [string]$matches.rest
        if ($rest -match '^(?<c>[A-Z]{2})-YD(?<t>.*)$') { $o.Colour = $matches.c; $rest = "YD$($matches.t)" }
        elseif ($rest -match '^BL(?<t>.*)$') { $rest = "YD$($matches.t)" }   # DW09B masters use BL as the colour slot
        $o.Suffix = ($rest -replace '\s+', ' ').Trim()
        $o.Key = "$($o.Assembly)-$($o.Kit)$(if ($o.Suffix) { '-' + $o.Suffix })"
    } elseif ($Name -match '^(?<wo>[^-]+)-(?<rest>Onsite Bolt.*)$') {
        $o.WO = $matches.wo; $o.Suffix = $matches.rest; $o.Key = $matches.rest
    }
    [pscustomobject]$o
}

function Find-DwSpa {
    <#
    .SYNOPSIS  Paths of the .spa bundles matching -Name, in the inbox (SPA files root), then Specs, then Masters.
               -Name is a file name, a WO prefix ('CAI03' finds '00- CAI03-Hopper.spa'), part of a name, or a wildcard.
    .EXAMPLE   Find-DwSpa CAI03
    #>
    param([Parameter(Position = 0)][string]$Name = '*', [string]$Root = $script:SpaRoot, [switch]$InboxOnly)
    $dirs = @($Root); if (-not $InboxOnly) { $dirs += (Join-Path $Root 'Specs'), (Join-Path $Root 'Masters') }
    $n = $Name -replace '\.spa$', ''
    $patterns = if ($n -match '[\*\?]') { @("$n.spa") } else { @("$n.spa", "* $n-*.spa", "*$n*.spa") }
    foreach ($p in $patterns) {
        $hit = @(foreach ($d in $dirs) { Get-ChildItem -LiteralPath $d -Filter $p -File -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName } })
        if ($hit.Count) { return $hit }
    }
}

function Resolve-DwSpaPath([string]$Path) {
    <# A path, or a name Find-DwSpa resolves to exactly one bundle. #>
    if (Test-Path -LiteralPath $Path) { return (Resolve-Path -LiteralPath $Path).Path }
    $hit = @(Find-DwSpa $Path)
    if ($hit.Count -eq 1) { return $hit[0] }
    if (-not $hit.Count) { throw "No .spa matches '$Path' in $script:SpaRoot (inbox, Specs, Masters)." }
    throw "'$Path' matches $($hit.Count) .spa files ($(@($hit | ForEach-Object { Split-Path $_ -Leaf }) -join ', ')); give a path or a longer name."
}

function Move-DwSpa {
    <#
    .SYNOPSIS  Files checked bundles out of the inbox (the SPA files root, where the SOLIDWORKS macro saves): each .spa
               and the files sharing its base name (.xlsx) go to Masters (master models, DW<n>-...) or Specs (spec builds).
               A bundle of the same name already there is an older build: it moves to <folder>\Previous with its date,
               so before/after builds can still be compared.
    .EXAMPLE   Move-DwSpa CAI05        # once its build is checked
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param([Parameter(Mandatory, Position = 0)][string]$Name, [string]$Root = $script:SpaRoot)
    $spas = @(Find-DwSpa $Name -Root $Root -InboxOnly)
    if (-not $spas.Count) { throw "No .spa matches '$Name' in the inbox $Root." }
    foreach ($spa in $spas) {
        $base = [IO.Path]::GetFileNameWithoutExtension($spa)
        $dest = Join-Path $Root $(if ($base -match '^DW\d') { 'Masters' } else { 'Specs' })
        foreach ($file in @(Get-ChildItem -LiteralPath $Root -File | Where-Object { $_.BaseName -eq $base })) {
            $target = Join-Path $dest $file.Name
            if (-not $PSCmdlet.ShouldProcess($file.Name, "Move to $(Split-Path $dest -Leaf)")) { continue }
            New-Item -ItemType Directory -Force $dest | Out-Null
            if (Test-Path -LiteralPath $target) {
                $old = Get-Item -LiteralPath $target; $prev = Join-Path $dest 'Previous'
                New-Item -ItemType Directory -Force $prev | Out-Null
                Move-Item -LiteralPath $old.FullName (Join-Path $prev "$($old.BaseName) $($old.LastWriteTime.ToString('yyyyMMdd-HHmm'))$($old.Extension)")
            }
            Move-Item -LiteralPath $file.FullName $target
            Get-Item -LiteralPath $target
        }
    }
}

function Read-DwSpa {
    <#
    .SYNOPSIS  Reads a .spa (Qty_Total guaranteed) and adds the parsed Sparta name to every record.
    .EXAMPLE   (Read-DwSpa ARD1653).Data | Where-Object IsDummy
    #>
    param([Parameter(Mandatory, Position = 0)][string]$Path)
    Import-DwSpaReader
    $spa = Read-SpaFile -Path (Resolve-DwSpaPath $Path) -BackfillQtyTotal
    foreach ($r in @($spa.Data)) {
        $n = ConvertTo-DwSpaName ([string]$r.Name)
        foreach ($p in $n.PSObject.Properties) { $r | Add-Member -NotePropertyName $p.Name -NotePropertyValue $p.Value -Force }
    }
    $spa
}

function Get-DwSpaKit {
    <#
    .SYNOPSIS  One row per kit assembly in a build (or per Key for loose parts): quantity, parts inside, and the main
               panel part's sheet metal (thickness, blank length x width, bends). -Spa takes a Read-DwSpa result.
    .EXAMPLE   Get-DwSpaKit CAI03 | Format-Table
    #>
    param([Parameter(Position = 0)][string]$Path, $Spa)
    if (-not $Spa) { $Spa = Read-DwSpa $Path }
    $data = @($Spa.Data)
    $byId = @{}; foreach ($r in $data) { $byId[[string]$r.ID] = $r }
    $children = @{}; foreach ($r in $data) { $k = [string]$r.Parent_ID; if (-not $children.ContainsKey($k)) { $children[$k] = New-Object System.Collections.Generic.List[object] }; $children[$k].Add($r) }
    $desc = { param($id) $out = New-Object System.Collections.Generic.List[object]; $stack = New-Object System.Collections.Stack; $stack.Push([string]$id)
        while ($stack.Count) { $i = $stack.Pop(); if ($children.ContainsKey($i)) { foreach ($c in $children[$i]) { $out.Add($c); $stack.Push([string]$c.ID) } } }; $out }
    # Kits: assemblies with a K number whose parent has none (the outermost kit assembly), plus dummies.
    $kits = @($data | Where-Object { $_.SW_Type -eq 'Assembly' -and (($_.Kit -and -not ($byId[[string]$_.Parent_ID].Kit)) -or $_.IsDummy) })
    foreach ($g in ($kits | Group-Object Key)) {
        $first = $g.Group[0]
        $sub = @(& $desc $first.ID)
        $parts = @($sub | Where-Object { $_.SW_Type -eq 'Part' -and $_.Kit })
        $main = $parts | Where-Object { $_.Suffix -like 'YD*' } | Select-Object -First 1
        $bolts = ($sub | Where-Object { $_.Name -eq 'Sparta Multi Bolt' } | Measure-Object Qty_Local -Sum).Sum
        [pscustomobject]@{
            Key = $g.Name; Assembly = $first.Assembly; Kit = $first.Kit; Name = $first.Name; IsDummy = $first.IsDummy
            Qty = ($g.Group | Measure-Object Qty_Total -Sum).Sum
            Parts = (@($parts | ForEach-Object { if ($_.Suffix -like 'YD*') { 'main' } else { $_.Suffix } } | Sort-Object -Unique) -join ',')
            Thickness = $(if ($main) { $main.Thickness }); BlankLength = $(if ($main) { $main.blank_length_in }); BlankWidth = $(if ($main) { $main.blank_width_in })
            Bends = $(if ($main) { $main.number_of_bends }); BoltsInside = [int]$bolts; Configuration = $first.Configuration
        }
    }
    # Loose top-level items that aren't kits (on-site bolts placed by the main assembly).
    foreach ($g in ($data | Where-Object { $_.SW_Level -eq 1 -and -not $_.Kit -and -not $_.IsDummy } | Group-Object Key)) {
        [pscustomobject]@{ Key = $g.Name; Assembly = ''; Kit = ''; Name = $g.Group[0].Name; IsDummy = $false; Qty = ($g.Group | Measure-Object Qty_Total -Sum).Sum; Parts = ''; Thickness = $null; BlankLength = $null; BlankWidth = $null; Bends = $null; BoltsInside = 0; Configuration = $g.Group[0].Configuration }
    }
}

function Compare-DwSpa {
    <#
    .SYNOPSIS  Compares two builds kit by kit (Key ignores WO prefix and colour): Added, Removed, Qty, Size (main panel
               blank differs by more than -Tolerance), Parts (different part set). Same rows are hidden unless -IncludeSame.
    .EXAMPLE   Compare-DwSpa ARD1652 ARD1653 | Format-Table
    #>
    param([Parameter(Mandatory, Position = 0)][string]$Reference, [Parameter(Mandatory, Position = 1)][string]$Difference, [double]$Tolerance = 0.01, [switch]$IncludeSame)
    $a = @{}; foreach ($k in (Get-DwSpaKit $Reference)) { $a[$k.Key] = $k }
    $b = @{}; foreach ($k in (Get-DwSpaKit $Difference)) { $b[$k.Key] = $k }
    foreach ($key in (@($a.Keys) + @($b.Keys) | Sort-Object -Unique)) {
        $x = $a[$key]; $y = $b[$key]; $why = @()
        if (-not $x) { $why += 'Added' } elseif (-not $y) { $why += 'Removed' } else {
            if ($x.Qty -ne $y.Qty) { $why += 'Qty' }
            if ($x.Parts -ne $y.Parts) { $why += 'Parts' }
            foreach ($p in 'BlankLength', 'BlankWidth') { if ($null -ne $x.$p -and $null -ne $y.$p -and [Math]::Abs([double]$x.$p - [double]$y.$p) -gt $Tolerance) { $why += 'Size'; break } }
        }
        if (-not $why.Count -and -not $IncludeSame) { continue }
        [pscustomobject]@{
            Key = $key; Change = $(if ($why.Count) { $why -join ',' } else { 'Same' })
            QtyRef = $(if ($x) { $x.Qty }); QtyDiff = $(if ($y) { $y.Qty })
            BlankRef = $(if ($x -and $null -ne $x.BlankLength) { "$($x.BlankLength) x $($x.BlankWidth)" }); BlankDiff = $(if ($y -and $null -ne $y.BlankLength) { "$($y.BlankLength) x $($y.BlankWidth)" })
            PartsRef = $(if ($x) { $x.Parts }); PartsDiff = $(if ($y) { $y.Parts })
        }
    }
}

function Get-DwSpaFamilyCatalog {
    <# From the Panels master ('DW09B-General Assembly All Panels'): family (R531...) -> its part suffixes ('2LF,3LBF,main'). #>
    param([Parameter(Mandatory)][string]$Path)
    $cat = @{}
    foreach ($r in @((Read-DwSpa $Path).Data)) {
        if ($r.SW_Type -ne 'Part' -or $r.Name -notmatch '^DW09B-(?<f>[RLB]\d{3})-(?<s>\w+)$') { continue }
        $f = $matches.f; $s = if ($matches.s -eq '1LBF') { 'main' } else { $matches.s }
        if (-not $cat.ContainsKey($f)) { $cat[$f] = New-Object System.Collections.Generic.SortedSet[string] }
        [void]$cat[$f].Add($s)
    }
    $out = @{}; foreach ($k in $cat.Keys) { $out[$k] = (@($cat[$k]) -join ',') }; $out
}

function Get-DwGenerationIssue {
    <#
    .SYNOPSIS  DriveWorks' own model-generation log, read (read-only) from the sandbox group: every warning and error
               logged while generating the files whose name matches -Name (a WO prefix such as 'CAI03', or '*').
               Kind classifies the entry:
                 Rebuild          SOLIDWORKS failed to rebuild the file within 3 attempts (also logged on files that
                                  look fine in SOLIDWORKS: compare with a baseline before blaming a change)
                 NotFound         a captured dimension, feature or instance the rules drive doesn't exist in the model
                 InvalidValue     SOLIDWORKS refused the value (e.g. a pattern count of 0); the old value stays
                 RuleError        the rule itself failed (#VALUE! reached SOLIDWORKS, e.g. a colour or state)
                 Property         a custom property couldn't be written (e.g. 'Date' in configuration '')
                 Reference        a reference update didn't apply
                 Replace          a <ReplaceFile> failed (Item = the dummy, Value = the file that should replace it)
                 SavedWithError   the file was saved with a rebuild error
    .EXAMPLE   Get-DwGenerationIssue CAI03 | Where-Object Kind -ne Property | Format-Table File, Kind, Item, Value
    #>
    param([Parameter(Position = 0)][string]$Name = '*', [string]$Group = $env:DW_GROUP_FILE, [datetime]$Since = [datetime]::MinValue)
    Import-Module (Join-Path $PSScriptRoot 'DwTools.psm1') -Global
    $like = ($Name -replace '\*', '%') -replace "'", "''"
    $sql = "SELECT r.Title, r.DateStarted, e.Type, e.Description, e.Detail FROM ReportEntries e JOIN Reports r ON r.Id = e.ReportId " +
           "WHERE e.Type IN (1,2) AND r.Title LIKE '% Generation %' AND (r.Title LIKE '$like%' OR r.Title LIKE '00- $like%') " +
           "AND e.Description NOT LIKE 'The previous % attempts%' ORDER BY r.DateStarted"
    foreach ($e in (Invoke-DwGroupQuery (Resolve-Path -LiteralPath $Group).Path $sql)) {
        if ([datetime]$e.DateStarted -lt $Since) { continue }
        $d = [string]$e.Description; $det = [string]$e.Detail
        $kind = 'Other'; $item = ''; $value = ''
        if ($d -match "^Drive dimension '(?<i>[^']+)' to value '(?<v>[^']*)'") {
            $item = $matches.i; $value = $matches.v
            $kind = if ($det -match 'was not found') { 'NotFound' } elseif ($det -match 'invalid') { 'InvalidValue' } else { 'Dimension' }
            if ($det -match "address '(?<a>[^']+)'") { $item = $matches.a }
        } elseif ($d -eq 'Rebuild model') { $kind = 'Rebuild' }
        elseif ($d -match "^Drive custom property '(?<i>[^']+)' to '(?<v>[^']*)'") { $kind = 'Property'; $item = $matches.i; $value = $matches.v }
        elseif ($d -match "^Drive (?<what>\w+) of (?<i>.+?) to '(?<v>[^']*)'") { $item = "$($matches.i) ($($matches.what))"; $value = $matches.v; $kind = if ($value -match '^#') { 'RuleError' } else { 'Other' } }
        elseif ($d -match '^Update references') { $kind = 'Reference'; $item = $d }
        elseif ($d -match "^Replace the component '(?<f>[^']+)' with '(?<w>[^']+)'") { $kind = 'Replace'; $item = Split-Path $matches.f -Leaf; $value = Split-Path $matches.w -Leaf }
        elseif ($d -match 'swFileSaveWarning_RebuildError') { $kind = 'SavedWithError' }
        elseif ($d -match "^Select (the instance )?'?(?<i>[^']+?)'?$" -and $det -match 'not found|Failed to select') { $kind = 'NotFound'; $item = $matches.i }
        [pscustomobject]@{
            File = ($e.Title -replace ' Generation \d{8}-\d{4}$', ''); Severity = $(if ($e.Type -eq 2) { 'Error' } else { 'Warning' })
            Kind = $kind; Item = $item; Value = $value; Detail = $det; Started = $e.DateStarted
        }
    }
}

function Get-DwHopperV2Expected {
    <#
    .SYNOPSIS  What a Hopper V2 spec should build, from its rules alone (no .spa needed): one row per top-level kit
               file with its quantity and the rule or dummy that places it. Use before generation, as the prediction.
    .EXAMPLE   Get-DwHopperV2Expected '.\DriveWorks Files\Specifications\DriveWorks Files\CAI01-Hopper 0008\DriveWorksFiles\DW Hopper V2.driveprojx'
    #>
    param([Parameter(Mandatory, Position = 0)][string]$Spec, [string]$Group = $env:DW_GROUP_FILE, [hashtable]$OverrideRule = @{}, $Session)
    Import-Module (Join-Path $PSScriptRoot 'DwTools.psm1') -Global
    Import-Module (Join-Path $PSScriptRoot 'DwFormEngine.psm1') -Global
    if (-not $Session) {
        $ov = @{ 'DWVariableBoltZoneTableCurrentSide' = 'TableFilter(DWCalcBoltZoneTable,2,TableGetValue(DWCalcBoltZoneTable,14,1))' }
        foreach ($k in $OverrideRule.Keys) { $ov[$k] = $OverrideRule[$k] }
        $Session = New-DwFormSession $Spec -Group $Group -StartValues Saved -OverrideRule $ov
    }
    $val = { param($n) "$((Get-DwFormValue $Session $n).Value)" }
    $all = @(Get-DwModelRule $Spec -Group $Group)
    # Kits placed by the main assembly: the outermost kit models' file-name rules. A kit wrapped in a
    # "-with Onsite Bolts" assembly is placed through the wrapper, so its inner -BL is not top level.
    $kitModels = @($all | Where-Object { $_.Kind -eq 'Component' -and $_.Parameter -eq '(File name)' -and $_.Model -match '^DW09B-A3\d-K\d+[A-D]?-BL( -with Onsite Bolts)?\.SLDASM$' })
    $wrapped = @{}; foreach ($m in $kitModels) { if ($m.Model -match '^(?<b>.+-BL) -with Onsite Bolts\.SLDASM$') { $wrapped["$($matches.b).SLDASM".ToLower()] = $true } }
    $patternQty = @{ 'A32-K70' = 'DWVariableBeforeElbowPatternQtyRight'; 'A31-K70' = 'DWVariableBeforeElbowPatternQtyLeft'; 'A32-K110' = 'DWVariableAfterElbowPatternQty'; 'A31-K110' = 'DWVariableAfterElbowPatternQty' }
    foreach ($m in $kitModels) {
        if ($wrapped.ContainsKey($m.Model.ToLower())) { continue }
        $base = [IO.Path]::GetFileNameWithoutExtension($m.Model)
        $r = Invoke-DwFormRule $Session $m.Rule -Owner "$($m.ComponentSet)\$base"
        # V2's prefix variables start with '*' (PrefixFileNameRightSide = "*ARD1653-A32"); the built file has no '*'.
        $name = $r.Value -replace '^\*', ''
        if ($r.IsError) { [pscustomobject]@{ File = "$base (rule error: $name)"; Qty = $null; Source = $base; Kind = 'Kit'; IsError = $true }; continue }
        if ($name -match '^\s*delete\s*$') { continue }
        $n = ConvertTo-DwSpaName $base
        $qty = 1; $pq = $patternQty["$($n.Assembly)-$($n.Kit)"]
        if ($pq) { $qty = [Math]::Max(1, [int][double](& $val $pq)) }
        [pscustomobject]@{ File = $name; Qty = $qty; Source = "rule on $base$(if ($pq) { ", pattern $($pq -replace 'DWVariable','')" })"; Kind = 'Kit'; IsError = $false }
    }
    # Drop-zone dummies: instance rules evaluated with their real owner name (MyNumber(3) = dummy number).
    foreach ($i in ($all | Where-Object { $_.Kind -eq 'Instance' -and $_.SolidWorksName -match 'Drop Zone Assy Dummy-\d+$' })) {
        $r = Invoke-DwFormRule $Session $i.Rule -Owner "$($i.ComponentSet)\$($i.SolidWorksName)"
        if ($r.Value -match '<ReplaceFile>(?<p>.+)$') { [pscustomobject]@{ File = [IO.Path]::GetFileNameWithoutExtension($matches.p); Qty = 1; Source = "replaces $($i.SolidWorksName)"; Kind = 'Panel'; IsError = $false } }
        elseif ($r.IsError) { [pscustomobject]@{ File = "$($i.SolidWorksName) (rule error)"; Qty = $null; Source = $i.SolidWorksName; Kind = 'Panel'; IsError = $true } }
    }
}

function Test-DwHopperV2Build {
    <#
    .SYNOPSIS  Checks a Hopper V2 build (.spa) against its specification (the .driveprojx copy in the spec folder):
               - every kit V2's own component-set rules keep (file names evaluated with the spec's inputs) is built,
                 with the expected quantity (K70/K110 = their pattern quantity) and nothing else;
               - every drop-zone dummy was replaced or deleted (none may remain);
               - each drop-zone panel was built with the Panels shape V2 asked for (-PanelCatalog: the Panels master
                 bundle, found in SPA files\Masters by default), with V2's PanelHeight/PanelLength beside the built blank.
               Status: OK, Missing, Unexpected, Qty, Shape, Leftover, Info.
    .EXAMPLE   Test-DwHopperV2Build -Spec '.\Test specification to check\ARD1653\DW Hopper V2.driveprojx' -Spa ARD1653 | Format-Table
    #>
    param(
        [Parameter(Mandatory)][string]$Spec, [Parameter(Mandatory)][string]$Spa, [string]$PanelCatalog = 'DW09B-General Assembly All Panels',
        [string]$Group = $env:DW_GROUP_FILE, [hashtable]$OverrideRule = @{}, [switch]$SkipPanels
    )
    Import-Module (Join-Path $PSScriptRoot 'DwTools.psm1') -Global
    Import-Module (Join-Path $PSScriptRoot 'DwFormEngine.psm1') -Global
    # Bolt zones use a Pro Server function; stand in for it so PanelListInput evaluates (see docs/learnings.md 2026-10-08).
    $bz = @{ 'DWVariableBoltZoneTableCurrentSide' = 'TableFilter(DWCalcBoltZoneTable,2,TableGetValue(DWCalcBoltZoneTable,14,1))' }
    $ov = @{} + $bz; foreach ($k in $OverrideRule.Keys) { $ov[$k] = $OverrideRule[$k] }
    $s = New-DwFormSession $Spec -Group $Group -StartValues Saved -OverrideRule $ov
    $val = { param($n) "$((Get-DwFormValue $s $n).Value)" }
    $kits = @(Get-DwSpaKit $Spa)
    $built = @{}; foreach ($k in $kits) { $built[$k.Name.ToLower()] = $k }
    $seen = @{}

    # 1-2. What the rules say to build (kits with quantities, drop-zone panels replacing dummies), against the build.
    foreach ($e in (Get-DwHopperV2Expected $Spec -Group $Group -Session $s)) {
        if ($e.IsError) { [pscustomobject]@{ Item = $e.File; Status = 'Info'; Expected = 'rule error'; Actual = ''; Detail = $e.Source }; continue }
        $k = $built[$e.File.ToLower()]; $seen[$e.File.ToLower()] = $true
        if (-not $k) { [pscustomobject]@{ Item = $e.File; Status = 'Missing'; Expected = "x$($e.Qty)"; Actual = 'not built'; Detail = $e.Source } }
        elseif ($k.Qty -ne $e.Qty) { [pscustomobject]@{ Item = $e.File; Status = 'Qty'; Expected = "x$($e.Qty)"; Actual = "x$($k.Qty)"; Detail = $e.Source } }
        else { [pscustomobject]@{ Item = $e.File; Status = 'OK'; Expected = "x$($e.Qty)"; Actual = "x$($k.Qty)"; Detail = $e.Source } }
    }
    foreach ($k in ($kits | Where-Object IsDummy)) {
        [pscustomobject]@{ Item = $k.Name; Status = 'Leftover'; Expected = 'x0 (every dummy is replaced or deleted)'; Actual = "x$($k.Qty)"; Detail = 'the build did not apply the instance rules' }
    }
    foreach ($k in ($kits | Where-Object { -not $_.IsDummy -and $_.Kit })) {
        if (-not $seen.ContainsKey($k.Name.ToLower())) { [pscustomobject]@{ Item = $k.Name; Status = 'Unexpected'; Expected = 'x0'; Actual = "x$($k.Qty)"; Detail = 'no rule keeps this file' } }
    }
    $bolts = $kits | Where-Object { $_.Key -like 'Onsite Bolt*' }
    if ($bolts) { [pscustomobject]@{ Item = $bolts.Name; Status = 'Info'; Expected = ''; Actual = "x$($bolts.Qty) at top level"; Detail = 'not checked' } }

    # 3. Drop-zone panels: the Panels shape V2 asked for, against the parts actually built.
    if ($SkipPanels) { return }
    $catalog = $null
    if ($PanelCatalog) { try { $catalog = Get-DwSpaFamilyCatalog $PanelCatalog } catch { Write-Warning "No panel catalog, shapes not checked: $($_.Exception.Message)" } }
    $n = [int][double](& $val 'DWVariableNumberOfLoopPanels')
    for ($p = 1; $p -le $n; $p++) {
        $ps = New-DwFormSession $Spec -Group $Group -StartValues Saved -OverrideRule $ov -Inputs @{ PanelSelectorSpinButton = $p }
        $t = @{}; foreach ($row in (Get-DwCalcTable $ps PanelListInput)) { if (-not $t.ContainsKey($row.Name)) { $t[$row.Name] = "$($row.Value)" } }
        $side = $t['PanelSideLocation']
        $bl = [int][double]$t['BackLineProfile']; $fl = [int][double]$t['FrontLineProfile']; $sp = [int][double]$t['SideProfile']
        $fam = if ($side -eq 'B') { "B$($bl * 100 + 10 + $fl)" } else { "$side$($bl * 100 + $fl * 10 + $sp)" }
        $file = "$(& $val 'DWVariablePrefixWOClient')-A$($t['AssemblyNumber'])-K$($t['KitNumber'])-$(& $val 'DWVariableColorCode')-YD-with Onsite Bolts"
        $k = $built[$file.ToLower()]
        $size = "V2 sends H $($t['PanelHeight']) x L $($t['PanelLength']), C-side $($t['CSideCutLength'])"
        if (-not $k) { continue }   # already reported as Missing above
        $blank = "built blank $($k.BlankLength) x $($k.BlankWidth), $($k.Bends) bends"
        if ($catalog) {
            # The .spa drops suppressed components, so the catalog holds only the parts the master saves unsuppressed
            # (back families save 2LF/3LF suppressed; TopProfile turns them on). Every catalog part must be built;
            # extra built parts are listed, not failed.
            $want = $catalog[$fam]
            $have = @($k.Parts -split ','); $need = @(if ($want) { $want -split ',' })
            $lack = @($need | Where-Object { $have -notcontains $_ }); $extra = @($have | Where-Object { $need -notcontains $_ -and $_ })
            $note = $(if ($extra.Count) { " (+$($extra -join ',') not in the master as saved)" })
            if (-not $want) { [pscustomobject]@{ Item = $file; Status = 'Shape'; Expected = "family $fam"; Actual = "parts $($k.Parts)"; Detail = "no family $fam in the Panels master; $size; $blank" } }
            elseif ($lack.Count) { [pscustomobject]@{ Item = $file; Status = 'Shape'; Expected = "family $fam ($want)"; Actual = "parts $($k.Parts)"; Detail = "missing $($lack -join ','): another shape was built; $size; $blank" } }
            else { [pscustomobject]@{ Item = $file; Status = 'OK'; Expected = "family $fam ($want)"; Actual = "parts $($k.Parts)$note"; Detail = "$size; $blank" } }
        } else {
            [pscustomobject]@{ Item = $file; Status = 'Info'; Expected = "family $fam"; Actual = "parts $($k.Parts)"; Detail = "$size; $blank" }
        }
    }
}

Export-ModuleMember -Function Find-DwSpa, Move-DwSpa, Read-DwSpa, Get-DwSpaKit, Compare-DwSpa, Get-DwSpaFamilyCatalog, Get-DwGenerationIssue, Get-DwHopperV2Expected, Test-DwHopperV2Build
