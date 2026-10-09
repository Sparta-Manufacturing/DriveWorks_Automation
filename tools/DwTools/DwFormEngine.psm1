#Requires -Version 5.1
<#
DwFormEngine: evaluates a DriveWorks project's forms with DriveWorks' own rule engine (Titan.Rules.dll),
without a group login, a license or SOLIDWORKS. Use it to see what a form does for given inputs:
property values, which rule is in error and why, and an HTML rendering of the form.

How DriveWorks maps a project into the engine (read from DriveWorks.Engine.dll, TitanControlDataProvider.LoadCore):
  - variables DWVariable<Name>, constants DWConstant<Name>, special variables (DWSpecification...), and
    tables DWLookup<Name> / DWGroupTable<Name> are global slots;
  - each control gets a scope named after it, holding its non-store properties: Ctrl.Top, Ctrl.Height, Ctrl.DefaultValue...
  - store properties are global slots: Ctrl (Source = the raw input), CtrlReturn (Value/SelectedItem/Checked/Text),
    CtrlListData (Items), CtrlMin, CtrlMax, CtrlDefault (Increment), CtrlEnabled, CtrlVisible, CtrlError;
  - a leading '=' is stripped from control rules; a missing Value rule becomes IF(Ctrl="","",Ctrl).
List controls are re-validated like ListControlBase.Validate: keep a selectable value, restore a remembered one,
else SelectFirst (or clear when the list is empty).

What is NOT modelled: macros, specification flow, documents, model rules, calculation tables, database queries
(QueryData returns ""), and Pro Server functions (SppGetTeamsDataForUser returns -Teams).
#>

Set-StrictMode -Off
if (-not (Get-Command Get-DwProjectXml -ErrorAction SilentlyContinue)) {
    Import-Module (Join-Path $PSScriptRoot 'DwTools.psm1')
}

# Stub functions for DriveWorks/Pro Server functions that need a live group. Static methods are registered by name.
class DwFormStubs {
    static [string[]] $Teams = @('Engineering')
    static [string] $GroupName = 'Sparta DW Group for Claude'
    static [Type] $ArrayType
    static [object] GetGroupName() { return [DwFormStubs]::GroupName }
    static [object] SppGetTeamsDataForUser([object] $user) {
        $t = [DwFormStubs]::Teams
        $a = [object[,]]::new($t.Count + 1, 1)
        $a[0, 0] = 'Team'
        for ($i = 0; $i -lt $t.Count; $i++) { $a[($i + 1), 0] = $t[$i] }
        $ctorArgs = [object[]]::new(1)
        $ctorArgs[0] = $a
        return [DwFormStubs]::ArrayType.GetConstructor([Type[]]@([object[,]])).Invoke($ctorArgs)
    }
    static [object] SppGetMachineInfo([object] $a) { return '' }
    static [object] QueryData([object] $a, [object] $b, [object] $c, [object] $d) { return '' }
    static [object] QueryDataValues([object] $a, [object] $b, [object] $c, [object] $d, [object] $e) { return '' }
}

$script:Asm = $null

function Initialize-DwFormEngine {
    if ($script:Asm) { return }
    $dir = Get-DwInstallPath
    $script:DllByName = @{}
    Get-ChildItem -LiteralPath $dir -Filter '*.dll' | ForEach-Object { $script:DllByName[$_.BaseName] = $_.FullName }
    [AppDomain]::CurrentDomain.add_AssemblyResolve({
        param($s, $e)
        $n = $e.Name.Split(',')[0]
        if ($n.EndsWith('.resources')) { return $null }
        $p = $script:DllByName[$n]
        if ($p) { return [System.Reflection.Assembly]::LoadFrom($p) }
        return $null
    })
    $titan = [Reflection.Assembly]::LoadFrom((Join-Path $dir 'Titan.Rules.dll'))
    $dw = [Reflection.Assembly]::LoadFrom((Join-Path $dir 'DriveWorks.Engine.dll'))
    try { $dwTypes = $dw.GetTypes() } catch [System.Reflection.ReflectionTypeLoadException] { $dwTypes = $_.Exception.Types | Where-Object { $_ } }
    try { $tTypes = $titan.GetTypes() } catch [System.Reflection.ReflectionTypeLoadException] { $tTypes = $_.Exception.Types | Where-Object { $_ } }
    [DwFormStubs]::ArrayType = $titan.GetType('Titan.Rules.Execution.StandardArrayValue')

    # Property metadata per control type, from DynamicProperty.GetProperties(type).
    $controlBase = $dwTypes | Where-Object { $_.FullName -eq 'DriveWorks.Forms.ControlBase' }
    $listBase = $dwTypes | Where-Object { $_.FullName -eq 'DriveWorks.Forms.ListControlBase' }
    $dynProp = $dwTypes | Where-Object { $_.FullName -eq 'DriveWorks.Forms.DataModel.DynamicProperty' }
    $getProps = $dynProp.GetMethods([Reflection.BindingFlags]'Public,NonPublic,Static') | Where-Object { $_.Name -eq 'GetProperties' -and $_.GetParameters().Count -eq 1 }
    $meta = @{}
    foreach ($t in ($dwTypes | Where-Object { $_.IsSubclassOf($controlBase) -and -not $_.IsAbstract })) {
        $arg = [object[]]::new(1); $arg[0] = [Type]$t.PSObject.BaseObject
        $props = foreach ($p in $getProps.Invoke($null, $arg)) {
            $store = $null
            if ($null -ne $p.StandardStoreOption) { $store = [int]$p.StandardStoreOption }
            [pscustomobject]@{ Name = $p.SerializeAs; Store = $store; Default = $p.DefaultValue }
        }
        $meta[$t.Name] = [pscustomobject]@{ Props = @($props | Where-Object { $_.Name }); IsList = $t.IsSubclassOf($listBase) }
    }
    $script:ControlMeta = $meta
    $script:FunctionTypes = @($tTypes | Where-Object { $_.Namespace -eq 'Titan.Rules.Common' -and $_.Name -like '*Functions' })
    $script:EngineType = $titan.GetType('Titan.Rules.Execution.ExecutionEngine')
    $script:IgnoreAndApply = [Enum]::Parse($titan.GetType('Titan.Rules.Execution.InvalidRuleBehavior'), 'IgnoreAndApply')
    $script:ErrorTypeType = $titan.GetType('Titan.Rules.Execution.ErrorType')
    $script:ArrayInterface = $titan.GetType('Titan.Rules.Execution.IArrayValue')
    $script:SlotTableType = $titan.GetType('Titan.Rules.ObjectModel.SlotTable')
    # MyName()/MyNumber(): the engine's default provider throws NotSupported, which stops ResumeUpdate and leaves every
    # slot of the project blank. DriveWorks reads the owner's name (DWVariableA12Length -> A12Length); numbers are runs
    # of adjacent digits, index 1 = first from the left, negative = from the right. The class is compiled here because
    # it implements a Titan interface, which must be loaded first.
    $script:NameNumberProvider = Invoke-Expression @'
class DwNameNumberProvider : Titan.Rules.Execution.IMyNameNumberProvider {
    static [string] OwnerName([Titan.Rules.Execution.Slot] $slot) {
        return ($slot.Name -replace '^(DWVariable|DWConstant|DWCalc)', '')
    }
    static [string] Pick([string[]] $parts, [int] $index) {
        if ($index -gt 0 -and $index -le $parts.Count) { return $parts[$index - 1] }
        if ($index -lt 0 -and -$index -le $parts.Count) { return $parts[$parts.Count + $index] }
        return $null
    }
    [void] GetMyName([Titan.Rules.Execution.Slot] $slot, [Titan.Rules.Execution.Value] $output) {
        $output.Assign([string][DwNameNumberProvider]::OwnerName($slot))
    }
    [void] GetMyName([Titan.Rules.Execution.Slot] $slot, [int] $index, [Titan.Rules.Execution.Value] $output) {
        $parts = @([regex]::Matches([DwNameNumberProvider]::OwnerName($slot), '\D+') | ForEach-Object { $_.Value })
        $p = [DwNameNumberProvider]::Pick($parts, $index)
        if ($null -eq $p) { $output.Assign([string]'') } else { $output.Assign([string]$p) }
    }
    [void] GetMyNumber([Titan.Rules.Execution.Slot] $slot, [int] $index, [Titan.Rules.Execution.Value] $output) {
        $parts = @([regex]::Matches([DwNameNumberProvider]::OwnerName($slot), '\d+') | ForEach-Object { $_.Value })
        $p = [DwNameNumberProvider]::Pick($parts, $index)
        if ($null -eq $p) { $output.Assign([double]0) } else { $output.Assign([double]$p) }
    }
}
[DwNameNumberProvider]::new()
'@
    $script:Asm = $titan
}

# Store option -> global slot suffix (DynamicProperty.GetStandardStoreName). -1 Source is the bare control name.
$script:StoreSuffix = @{ -1 = ''; 0 = 'Return'; 1 = 'Min'; 2 = 'Max'; 3 = 'Default'; 4 = 'Enabled'; 5 = 'Visible'; 6 = 'Error'; 7 = 'ListData' }

function ConvertTo-DwEngineValue($Value) {
    <# XML/static text -> number, boolean or string, like DriveWorks' ValueHelper.GetValueWithRealType. #>
    if ($null -eq $Value) { return '' }
    if ($Value -is [bool] -or $Value -is [double]) { return $Value }
    if ($Value -is [int] -or $Value -is [long] -or $Value -is [decimal] -or $Value -is [single]) { return [double]$Value }
    $s = [string]$Value
    $d = 0.0
    if ($s -match '^\s*-?(\d+\.?\d*|\.\d+)([eE][-+]?\d+)?\s*$' -and [double]::TryParse($s, [Globalization.NumberStyles]::Float, [Globalization.CultureInfo]::InvariantCulture, [ref]$d)) { return $d }
    if ($s -eq 'True') { return $true }
    if ($s -eq 'False') { return $false }
    return $s
}

function Format-DwEngineValue($Value) {
    <# Engine value -> display text. Errors become '#Error:<type>'. #>
    if ($null -eq $Value) { return '' }
    if ($Value.GetType() -eq $script:ErrorTypeType) { return "#Error:$Value" }
    if ($script:ArrayInterface.IsInstanceOfType($Value)) { return "<table $($Value.Rows)x$($Value.Columns)>" }
    if ($Value -is [double]) { return $Value.ToString([Globalization.CultureInfo]::InvariantCulture) }
    if ($Value -is [bool]) { if ($Value) { return 'TRUE' } else { return 'FALSE' } }
    return [string]$Value
}

function Test-DwEngineError($Value) { ($null -ne $Value) -and ($Value.GetType() -eq $script:ErrorTypeType) }

function ConvertFrom-DwTableText([string]$Text, [char]$Sep) {
    <# Delimited text (header row first) -> object[,]. Quoted cells are supported for comma tables. #>
    $lines = @($Text -replace "`r", '' -split "`n")
    if ($lines.Count -gt 1 -and $lines[-1] -eq '') { $lines = $lines[0..($lines.Count - 2)] }
    $rows = foreach ($l in $lines) {
        if ($Sep -eq ',') {
            $cells = New-Object System.Collections.Generic.List[string]
            $sb = New-Object System.Text.StringBuilder; $q = $false
            for ($i = 0; $i -lt $l.Length; $i++) {
                $ch = $l[$i]
                if ($q) { if ($ch -eq '"') { if ($i + 1 -lt $l.Length -and $l[$i + 1] -eq '"') { [void]$sb.Append('"'); $i++ } else { $q = $false } } else { [void]$sb.Append($ch) } }
                elseif ($ch -eq '"') { $q = $true }
                elseif ($ch -eq ',') { $cells.Add($sb.ToString()); [void]$sb.Clear() }
                else { [void]$sb.Append($ch) }
            }
            $cells.Add($sb.ToString())
            , $cells.ToArray()
        } else { , ($l -split [regex]::Escape([string]$Sep)) }
    }
    $rows = @($rows)
    $cols = ($rows | ForEach-Object { $_.Count } | Measure-Object -Maximum).Maximum
    $a = New-Object 'object[,]' $rows.Count, ([Math]::Max(1, $cols))
    for ($r = 0; $r -lt $rows.Count; $r++) {
        for ($c = 0; $c -lt $cols; $c++) { $a[$r, $c] = if ($c -lt $rows[$r].Count) { ConvertTo-DwEngineValue $rows[$r][$c] } else { '' } }
    }
    , $a
}

function Get-DwSessionSlot($Session, [string]$Name) {
    <# 'Ctrl.Prop' -> scoped slot; anything else -> global slot. Case-insensitive. #>
    $i = $Name.IndexOf('.')
    if ($i -gt 0) {
        $scope = $Session.Scopes[$Name.Substring(0, $i)]
        if ($scope) { return $scope.Slots[$Name.Substring($i + 1)] }
        return $null
    }
    $Session.Globals[$Name]
}

function Add-DwSlot($Session, $Scope, [string]$Name, [string]$Rule, $Value, [bool]$HasRule, [string]$Owner) {
    $slot = $Scope.Slots.Add($Name)
    if ($HasRule) {
        try { $slot.SetRule($Rule, $script:IgnoreAndApply) } catch { $Session.InvalidRules.Add([pscustomobject]@{ Slot = $Name; Owner = $Owner; Rule = $Rule; Error = $_.Exception.InnerException.Message }) }
    } else {
        try { $slot.Value = ConvertTo-DwEngineValue $Value } catch { }
    }
    $slot
}

function New-DwFormSession {
    <#
    .SYNOPSIS
      Loads a project into DriveWorks' rule engine, applies inputs and returns a session for
      Get-DwFormValue, Trace-DwFormValue, Get-DwFormError and Export-DwFormHtml.
    .PARAMETER Inputs
      Control name -> value, as if typed by the user (sets the control's Source slot). Example:
      @{ BottomElbow = $false; Elbow = $true; SLD_ConveyorLength = 20; CommonSpecsCheckExtend = $true }
    .PARAMETER Override
      Slot -> fixed value, replacing its rule. Slots: DWVariableX, CtrlReturn, Ctrl.Height...
    .PARAMETER OverrideRule
      Slot -> new rule text, to test a fix without editing the file. Example:
      @{ 'DWVariablenone' = 'If(DWVariableNumberOfBottomSection>0,"None|","None")' }
    .PARAMETER Teams
      Teams returned for the current user by SppGetTeamsDataForUser (default Engineering).
    .PARAMETER StartValues
      Default (new specification: each control starts at its evaluated DefaultValue, else its saved value)
      or Saved (the values saved in the project file).
    .EXAMPLE
      $s = New-DwFormSession '.\DriveWorks Files\Apron\DW Apron Project.driveprojx' -Inputs @{ BottomElbow = $false }
    #>
    param(
        [Parameter(Mandatory, Position = 0)][string]$Path,
        [string]$Group = $env:DW_GROUP_FILE,
        [hashtable]$Inputs = @{},
        [hashtable]$Override = @{},
        [hashtable]$OverrideRule = @{},
        [string[]]$Teams = @('Engineering'),
        [ValidateSet('Default', 'Saved')][string]$StartValues = 'Default',
        [string]$GroupName = 'Sparta DW Group for Claude',     # what GetGroupName() returns (a Pro Server function)
        [hashtable]$ExtraTables = @{}                          # slot name -> object[,] (header row first), e.g. a group table that doesn't exist yet
    )
    Initialize-DwFormEngine
    [DwFormStubs]::Teams = $Teams
    [DwFormStubs]::GroupName = $GroupName
    $Path = (Resolve-Path -LiteralPath $Path).Path
    $dm = Get-DwProjectXml $Path designMaster
    $px = Get-DwProjectXml $Path project

    $eng = [Activator]::CreateInstance($script:EngineType, @([Globalization.CultureInfo]::GetCultureInfo('en-US'), $script:NameNumberProvider))
    $addType = $script:EngineType.GetMethod('AddFunctions', [Type[]]@([Type]))
    foreach ($ft in $script:FunctionTypes) { $arg = [object[]]::new(1); $arg[0] = [Type]$ft.PSObject.BaseObject; [void]$addType.Invoke($eng, $arg) }
    $addFn = $script:EngineType.GetMethod('AddFunction', [Type[]]@([object], [Reflection.MethodInfo]))
    foreach ($m in [DwFormStubs].GetMethods([Reflection.BindingFlags]'Public,Static,DeclaredOnly')) {
        if ($m.IsSpecialName) { continue }
        try { [void]$addFn.Invoke($eng, @($null, $m)) } catch { }
    }

    $cmp = [StringComparer]::OrdinalIgnoreCase
    $session = [pscustomobject]@{
        Path         = $Path
        Engine       = $eng
        Globals      = New-Object 'System.Collections.Generic.Dictionary[string,object]' $cmp
        Scopes       = New-Object 'System.Collections.Generic.Dictionary[string,object]' $cmp
        Controls     = New-Object 'System.Collections.Generic.Dictionary[string,object]' $cmp
        Forms        = New-Object 'System.Collections.Generic.Dictionary[string,object]' $cmp
        Rules        = New-Object 'System.Collections.Generic.Dictionary[string,string]' $cmp
        InvalidRules = New-Object System.Collections.Generic.List[object]
        Restore      = New-Object 'System.Collections.Generic.Dictionary[string,object]' $cmp
        CalcTables   = New-Object 'System.Collections.Generic.Dictionary[string,object]' $cmp
        Inputs       = @{}
        Override     = $Override
        OverrideRule = $OverrideRule
        Log          = New-Object System.Collections.Generic.List[string]
    }
    $g = $eng.GlobalScope
    [void]$eng.SuppressUpdate()
    try {
        $addGlobal = {
            param($name, $rule, $value, $hasRule, $owner)
            if ($session.Globals.ContainsKey($name)) { return }
            $session.Globals[$name] = Add-DwSlot $session $g $name $rule $value $hasRule $owner
            if ($hasRule) { $session.Rules[$name] = $rule }
        }
        foreach ($c in (Select-DwXml $dm '/TDM/Constants/Constant')) { & $addGlobal $c.GetAttribute('StoreName') $null $c.GetAttribute('Value') $false 'Constant' }
        foreach ($c in (Select-DwXml $dm '/TDM/SpecialVariables/SpecialVariable')) {
            $r = $c.GetAttribute('Rule')
            if ($r) { & $addGlobal $c.GetAttribute('StoreName') ($r -replace '^\s*=', '') $null $true 'Special' }
            else { & $addGlobal $c.GetAttribute('StoreName') $null $c.GetAttribute('Value') $false 'Special' }
        }
        foreach ($v in (Select-DwXml $dm '/TDM/Variables/Variable')) { & $addGlobal $v.GetAttribute('StoreName') ($v.GetAttribute('Rule') -replace '^\s*=', '') $null $true 'Variable' }
        foreach ($t in (Select-DwXml $dm '/TDM/Tables/Table')) {
            $slot = $g.Slots.Add($t.GetAttribute('Name'))
            $slot.Value = ConvertFrom-DwTableText $t.InnerText ','
            $session.Globals[$t.GetAttribute('Name')] = $slot
        }
        if ($Group -and (Test-Path -LiteralPath $Group)) {
            foreach ($row in (Invoke-DwGroupQuery $Group 'SELECT Name, hex(TableData) AS Hex FROM GroupDataTables')) {
                if (-not $row.Hex) { continue }
                $hex = [string]$row.Hex
                $bytes = New-Object byte[] ($hex.Length / 2)
                for ($i = 0; $i -lt $bytes.Length; $i++) { $bytes[$i] = [Convert]::ToByte($hex.Substring(2 * $i, 2), 16) }
                $ds = New-Object System.IO.Compression.DeflateStream((New-Object System.IO.MemoryStream(, $bytes)), [System.IO.Compression.CompressionMode]::Decompress)
                $text = (New-Object System.IO.StreamReader($ds, [Text.Encoding]::UTF8)).ReadToEnd()
                $slot = $g.Slots.Add("DWGroupTable$($row.Name)")
                $slot.Value = ConvertFrom-DwTableText $text "`t"
                $session.Globals["DWGroupTable$($row.Name)"] = $slot
            }
        } else { $session.Log.Add('No group file: DWGroupTable* tables are missing. Pass -Group or set $env:DW_GROUP_FILE.') }
        foreach ($k in $ExtraTables.Keys) {
            if ($session.Globals.ContainsKey($k)) { $session.Globals[$k].Value = $ExtraTables[$k]; continue }
            $slot = $g.Slots.Add($k); $slot.Value = $ExtraTables[$k]; $session.Globals[$k] = $slot
        }

        # Calculation tables (ProjectCalculationTableSlotTable): a Titan SlotTable named DWCalc<Name>, row 0 = column
        # names, data row r = that row's rule or the column's common rule. Relative refs ([1U], [2L]) work natively.
        foreach ($ct in (Select-DwXml $px "//*[local-name()='CalculationTable']")) {
            $ctName = $ct.GetAttribute('Name')
            $refName = 'DWCalc' + ($ctName -replace '[^A-Za-z0-9_]', '')
            $rowCount = [int]$ct.GetAttribute('RowCount')
            $cols = @($ct.SelectNodes("*[local-name()='Columns']/*[local-name()='Column']"))
            $st = [Activator]::CreateInstance($script:SlotTableType, @($g, $refName))
            foreach ($c in $cols) { $st.AddColumn() }
            $st.SetRowCount($rowCount + 1)
            for ($ci = 0; $ci -lt $cols.Count; $ci++) {
                $c = $cols[$ci]
                $st.GetSlot($ci, 0).Value = $c.GetAttribute('Name')
                $common = $c.SelectSingleNode("*[local-name()='CommonRule']/*[local-name()='Formula']")
                $common = if ($common) { $common.InnerText } else { '' }
                $byRow = @{}
                foreach ($r in $c.SelectNodes("*[local-name()='Rules']/*[local-name()='Rule']")) { $byRow[[int]$r.GetAttribute('RowIndex')] = $r.SelectSingleNode("*[local-name()='Formula']").InnerText }
                for ($ri = 0; $ri -lt $rowCount; $ri++) {
                    $rule = if ($byRow.ContainsKey($ri)) { $byRow[$ri] } else { $common }
                    $rule = ([string]$rule) -replace '^\s*=', ''
                    if ($rule.Trim()) {
                        try { $st.GetSlot($ci, $ri + 1).SetRule($rule, $script:IgnoreAndApply) } catch { $session.InvalidRules.Add([pscustomobject]@{ Slot = "$refName[$($c.GetAttribute('Name')),$ri]"; Owner = 'CalculationTable'; Rule = $rule; Error = $_.Exception.InnerException.Message }) }
                    }
                }
            }
            $session.Globals[$refName] = $st.TableSlot
            $session.CalcTables[$ctName] = [pscustomobject]@{ Name = $ctName; RefName = $refName; Table = $st; Columns = @($cols | ForEach-Object { $_.GetAttribute('Name') }); RowCount = $rowCount }
        }

        # Forms and controls. A form is itself a control (type Form) with store slots.
        foreach ($form in (Select-DwXml $px '//f:Form')) {
            $formName = $form.GetAttribute('Name')
            $ctls = New-Object System.Collections.Generic.List[object]
            $nodes = @($form) + @(Select-DwXml $form './f:Controls/*')
            foreach ($node in $nodes) {
                $name = $node.GetAttribute('Name')
                $type = $node.LocalName
                if (-not $name -or $session.Controls.ContainsKey($name)) { continue }
                $meta = $script:ControlMeta[$type]
                $scope = $g.Scopes.Add($name)
                $info = [pscustomobject]@{
                    Name = $name; Type = $type; Form = $formName; Xml = $node
                    IsList = [bool]($meta -and $meta.IsList)
                    Slots = New-Object 'System.Collections.Generic.Dictionary[string,object]' $cmp
                }
                $scopeSlots = New-Object 'System.Collections.Generic.Dictionary[string,object]' $cmp
                $xmlProps = @{}
                foreach ($e in $node.ChildNodes) { if ($e.NodeType -eq 'Element' -and $e.LocalName -ne 'Controls') { $xmlProps[$e.LocalName] = $e } }
                $propList = if ($meta) { $meta.Props } else { @($xmlProps.Keys | ForEach-Object { [pscustomobject]@{ Name = $_; Store = $null; Default = '' } }) }
                foreach ($p in $propList) {
                    $e = $xmlProps[$p.Name]
                    $rule = $null; $value = $p.Default; $hasRule = $false
                    if ($e) {
                        $r = @($e.ChildNodes | Where-Object { $_.LocalName -eq 'Rule' })
                        $vv = @($e.ChildNodes | Where-Object { $_.LocalName -eq 'Value' })
                        if ($r.Count) { $rule = $r[0].InnerText -replace '^\s*=', ''; $hasRule = $true }
                        elseif ($vv.Count) { $value = $vv[0].InnerText }
                    } elseif ($p.Store -eq 0) { $rule = "IF($name=`"`",`"`",$name)"; $hasRule = $true }
                    if ($null -ne $p.Store) {
                        $slotName = $name + $script:StoreSuffix[[int]$p.Store]
                        if ($session.Globals.ContainsKey($slotName)) { continue }
                        $slot = Add-DwSlot $session $g $slotName $rule $value $hasRule "$formName/$name.$($p.Name)"
                        $session.Globals[$slotName] = $slot
                        if ($hasRule) { $session.Rules[$slotName] = $rule }
                    } else {
                        $slot = Add-DwSlot $session $scope $p.Name $rule $value $hasRule "$formName/$name.$($p.Name)"
                        $scopeSlots[$p.Name] = $slot
                        if ($hasRule) { $session.Rules["$name.$($p.Name)"] = $rule }
                    }
                    $info.Slots[$p.Name] = $slot
                }
                $session.Scopes[$name] = [pscustomobject]@{ Scope = $scope; Slots = $scopeSlots }
                $session.Controls[$name] = $info
                if ($node -ne $form) { $ctls.Add($info) }
            }
            $session.Forms[$formName] = $ctls
        }
    } catch {
        $loadError = $_
    } finally {
        # A failure here leaves the engine suspended and every slot blank: report it instead of hiding it.
        try { [void]$eng.ResumeUpdate() } catch { $e = $_.Exception; while ($e.InnerException) { $e = $e.InnerException }; $resumeError = "$($e.GetType().Name): $($e.Message)" }
    }
    if ($resumeError -and -not $loadError) { throw "Loading '$Path' failed: the rule engine stopped while calculating ($resumeError). Every value would be blank." }
    if ($loadError) { throw "Loading '$Path' failed: $($loadError.Exception.Message) (at $($loadError.InvocationInfo.ScriptLineNumber): $($loadError.InvocationInfo.Line.Trim()))" }

    foreach ($k in $OverrideRule.Keys) {
        $slot = Get-DwSessionSlot $session $k
        if (-not $slot) { throw "OverrideRule: no slot '$k'." }
        $slot.SetRule(($OverrideRule[$k] -replace '^\s*=', ''), $script:IgnoreAndApply)
        $session.Rules[$k] = $OverrideRule[$k]
    }
    foreach ($k in $Override.Keys) {
        $slot = Get-DwSessionSlot $session $k
        if (-not $slot) { throw "Override: no slot '$k'." }
        $slot.Value = ConvertTo-DwEngineValue $Override[$k]
        [void]$session.Rules.Remove($k)
    }

    # New specification: each control follows its DefaultValue (when it evaluates), else keeps its saved value, until
    # the user types in it. DriveWorks keeps a default live: confirmed 2026-10-09 through the API (TextBox_ColorCode
    # followed PaintColor to GR), so defaults are re-applied after every input change (Set-DwFormInput).
    $session | Add-Member -NotePropertyName LiveDefaults -NotePropertyValue ($StartValues -eq 'Default')
    Set-DwFormInput $session $Inputs
    $session
}

function Update-DwFormDefaults {
    <# Re-applies DefaultValue to every control the user hasn't typed in (new specifications only). #>
    param([Parameter(Mandatory)]$Session)
    if (-not $Session.LiveDefaults) { return }
    for ($pass = 0; $pass -lt 3; $pass++) {
        $changed = $false
        foreach ($c in $Session.Controls.Values) {
            if ($Session.Inputs.ContainsKey($c.Name)) { continue }
            $src = $Session.Globals[$c.Name]
            $def = $Session.Scopes[$c.Name].Slots['DefaultValue']
            if (-not $src -or -not $def) { continue }
            $v = $def.Value
            if ((Test-DwEngineError $v) -or $null -eq $v) { continue }
            if ((Format-DwEngineValue $src.Value) -ceq (Format-DwEngineValue $v)) { continue }
            [void]$src.SetValue($v, $false); $changed = $true
        }
        if (-not $changed) { return }
    }
}

function Set-DwFormInput {
    <#
    .SYNOPSIS  Sets control values as the user would (the control's Source slot), then re-validates list controls.
    .EXAMPLE   Set-DwFormInput $s @{ Elbow = $true; SLD_ConveyorLength = 20 }
    #>
    param([Parameter(Mandatory, Position = 0)]$Session, [Parameter(Position = 1)][hashtable]$Inputs = @{})
    foreach ($k in @($Inputs.Keys)) {
        $src = $Session.Globals[$k]
        if (-not $src -or -not $Session.Controls.ContainsKey($k)) { throw "Input: no control '$k'." }
        [void]$src.SetValue((ConvertTo-DwEngineValue $Inputs[$k]), $true)
        [void]$Session.Restore.Remove($k)
        $Session.Inputs[$k] = $Inputs[$k]
    }
    Update-DwFormDefaults $Session
    Update-DwFormLists $Session
    Update-DwFormDefaults $Session
}

function Update-DwFormLists {
    <# Re-validates list controls until stable, like DriveWorks' ListControlBase.Validate. #>
    param([Parameter(Mandatory)]$Session, [int]$MaxPasses = 30)
    $lists = @($Session.Controls.Values | Where-Object { $_.IsList })
    for ($pass = 0; $pass -lt $MaxPasses; $pass++) {
        $changed = $false
        foreach ($c in $lists) {
            $ret = $Session.Globals["$($c.Name)Return"]; $src = $Session.Globals[$c.Name]; $ld = $Session.Globals["$($c.Name)ListData"]
            if (-not $ret -or -not $src -or -not $ld) { continue }
            $listVal = $ld.Value
            if (Test-DwEngineError $listVal) { continue }
            $items = @(([string](Format-DwEngineValue $listVal)) -split '\|', -1)
            if ($items.Count -eq 1 -and $items[0] -eq '') { $items = @() }
            $sel = Format-DwEngineValue $ret.Value
            $allowClear = $false
            $ac = $c.Slots['AllowClearSelectedItem']; if ($ac) { $allowClear = ($ac.Value -eq $true) }
            $selectable = { param($v) if ($v -eq '') { $allowClear } else { $items -ccontains $v } }
            if (& $selectable $sel) { continue }
            $rule = $Session.Rules["$($c.Name)Return"]
            if ($rule -and (($rule -replace '\s', '') -ne "IF($($c.Name)=`"`",`"`",$($c.Name))")) { continue }
            $new = $null
            $remembered = $null
            if ($Session.Restore.TryGetValue($c.Name, [ref]$remembered)) {
                if (& $selectable $remembered) { $new = $remembered; [void]$Session.Restore.Remove($c.Name) }
            } else { $Session.Restore[$c.Name] = $sel }
            if ($null -eq $new) {
                $behavior = 'SelectFirst'
                $b = $c.Slots['SelectedItemRemovedBehavior']; if ($b) { $behavior = [string]$b.Value }
                if ($items.Count -gt 0 -and $behavior -eq 'SelectFirst') { $new = $items[0] } else { $new = '' }
            }
            if ($new -cne $sel) {
                [void]$src.SetValue((ConvertTo-DwEngineValue $new), $true)
                $Session.Log.Add("List '$($c.Name)': '$sel' not in [$($items -join '|')] -> '$new'")
                $changed = $true
            }
        }
        if (-not $changed) { return }
    }
    $Session.Log.Add("List validation did not settle after $MaxPasses passes.")
}

function Get-DwFormValue {
    <#
    .SYNOPSIS  Value of one or more slots: 'Ctrl.Height', 'CtrlReturn', 'CtrlListData', 'DWVariableX'. Errors read '#Error:<type>'.
    .EXAMPLE   Get-DwFormValue $s 'CommonSpecsFrame.Height', 'SpartaLogoPositionReturn'
    #>
    param([Parameter(Mandatory, Position = 0)]$Session, [Parameter(Mandatory, Position = 1)][string[]]$Name)
    foreach ($n in $Name) {
        $slot = Get-DwSessionSlot $Session $n
        if (-not $slot) { [pscustomobject]@{ Name = $n; Value = '<no such slot>'; IsError = $true; Rule = $null }; continue }
        $v = $slot.Value
        [pscustomobject]@{ Name = $n; Value = (Format-DwEngineValue $v); IsError = (Test-DwEngineError $v); Rule = $Session.Rules[$n] }
    }
}

function Invoke-DwFormRule {
    <#
    .SYNOPSIS  Evaluates rule text that isn't in the session (a model rule, a proposed fix) against the session's state.
               -Owner is the name MyName()/MyNumber() read: for a model rule, '<component set>\<instance>'
               (e.g. 'DW09B-Hopper Main Assembly\DW09B-Right Side Drop Zone Assy Dummy-8'). A leading '=' is ignored.
               Each call adds a temporary global slot, named after the owner, so evaluate many rules in one session.
    .EXAMPLE   Invoke-DwFormRule $s '=DWVariableReplaceDropZoneRightFormula(MyNumber(3))' -Owner 'DW09B-Hopper Main Assembly\DW09B-Right Side Drop Zone Assy Dummy-8'
    #>
    param([Parameter(Mandatory, Position = 0)]$Session, [Parameter(Mandatory, Position = 1)][string[]]$Rule, [string]$Owner = 'DwRule')
    foreach ($r in $Rule) {
        $script:DwRuleCounter++
        $name = if ($Owner -eq 'DwRule') { "DwRule$($script:DwRuleCounter)" } else { $Owner }
        # A slot name must be unique in its scope: give each evaluation its own child scope, so the owner name stays exact.
        $scope = $Session.Engine.GlobalScope.Scopes.Add("DwRuleScope$($script:DwRuleCounter)")
        $slot = $scope.Slots.Add($name)
        $err = $null
        try { $slot.SetRule(($r -replace '^\s*=', ''), $script:IgnoreAndApply) } catch { $e = $_.Exception; while ($e.InnerException) { $e = $e.InnerException }; $err = $e.Message }
        $v = if ($err) { "#Invalid: $err" } else { Format-DwEngineValue $slot.Value }
        [pscustomobject]@{ Owner = $name; Rule = $r; Value = $v; IsError = [bool]($err -or (Test-DwEngineError $slot.Value)) }
    }
}

function Get-DwCalcTable {
    <#
    .SYNOPSIS  A calculation table's evaluated cells, one object per row (Row = 1-based data row, as TableGetValue counts).
    .EXAMPLE   Get-DwCalcTable $s SectionLayout | Format-Table
    #>
    param([Parameter(Mandatory, Position = 0)]$Session, [Parameter(Mandatory, Position = 1)][string]$Name)
    $ct = $Session.CalcTables[$Name]
    if (-not $ct) { throw "No calculation table '$Name'. Tables: $(@($Session.CalcTables.Keys) -join ', ')" }
    for ($r = 1; $r -le $ct.RowCount; $r++) {
        $o = [ordered]@{ Row = $r }
        for ($c = 0; $c -lt $ct.Columns.Count; $c++) { $o[$ct.Columns[$c]] = Format-DwEngineValue $ct.Table.GetSlot($c, $r).Value }
        [pscustomobject]$o
    }
}

function Get-DwRuleReference($Session, [string]$Rule) {
    <# Names a rule refers to, resolved against the session's slots (string literals and function names skipped). #>
    if (-not $Rule) { return @() }
    $text = [regex]::Replace($Rule, '"(?:[^"]|"")*"', '""')
    $seen = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    foreach ($m in [regex]::Matches($text, '(?<![\w.])([A-Za-z_][A-Za-z0-9_]*)(?:\.([A-Za-z_][A-Za-z0-9_]*))?(?!\s*\()')) {
        $a = $m.Groups[1].Value; $b = $m.Groups[2].Value
        $name = $null
        if ($b -and $Session.Scopes.ContainsKey($a) -and $Session.Scopes[$a].Slots.ContainsKey($b)) { $name = "$a.$b" }
        elseif ($Session.Globals.ContainsKey($a)) { $name = $a }
        if ($name -and $seen.Add($name)) { $name }
    }
}

function Trace-DwFormValue {
    <#
    .SYNOPSIS  Shows how a value is computed: the slot, its value and rule, then what the rule refers to, recursively.
               -ErrorsOnly follows only references that are in error, down to the first rule that fails on its own.
    .EXAMPLE   Trace-DwFormValue $s 'CommonSpecsFrame.Height' -ErrorsOnly
    #>
    param(
        [Parameter(Mandatory, Position = 0)]$Session,
        [Parameter(Mandatory, Position = 1)][string]$Name,
        [int]$Depth = 12,
        [switch]$ErrorsOnly
    )
    $visited = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    $walk = {
        param($n, $level)
        $slot = Get-DwSessionSlot $Session $n
        $v = if ($slot) { $slot.Value } else { $null }
        $isErr = Test-DwEngineError $v
        $rule = $Session.Rules[$n]
        $refs = @(Get-DwRuleReference $Session $rule)
        $errRefs = @($refs | Where-Object { Test-DwEngineError (Get-DwSessionSlot $Session $_).Value })
        $mark = if ($isErr -and $errRefs.Count -eq 0) { '  <== fails here' } elseif ($isErr) { '' } else { '' }
        $r = if ($rule) { ($rule -replace '\s+', ' ').Trim() } else { '(value)' }
        if ($r.Length -gt 160) { $r = $r.Substring(0, 157) + '...' }
        ('{0}{1} = {2}{3}' -f ('  ' * $level), $n, (Format-DwEngineValue $v), $mark)
        if ($rule) { ('{0}    := {1}' -f ('  ' * $level), $r) }
        if ($level -ge $Depth -or -not $visited.Add($n)) { return }
        $next = if ($ErrorsOnly) { $errRefs } else { $refs }
        foreach ($c in $next) { & $walk $c ($level + 1) }
    }
    & $walk $Name 0
}

function Get-DwFormError {
    <#
    .SYNOPSIS  Every slot whose value is an error: control properties (optionally one form) and variables.
               RootCause is $true when none of the slot's own references is in error (the rule itself fails).
    .EXAMPLE   Get-DwFormError $s -Form CommonSpecs | Format-Table
    #>
    param([Parameter(Mandatory, Position = 0)]$Session, [string]$Form, [switch]$IncludeVariables)
    $names = New-Object System.Collections.Generic.List[string]
    foreach ($c in $Session.Controls.Values) {
        if ($Form -and $c.Form -ne $Form -and $c.Name -ne $Form) { continue }
        foreach ($p in $c.Slots.Keys) {
            $slot = $c.Slots[$p]
            $n = if ($Session.Scopes[$c.Name].Slots.ContainsKey($p)) { "$($c.Name).$p" } else { $slot.Name }
            $names.Add($n)
        }
    }
    if ($IncludeVariables) { foreach ($k in $Session.Globals.Keys) { if ($k -like 'DWVariable*') { $names.Add($k) } } }
    foreach ($n in $names) {
        $v = (Get-DwSessionSlot $Session $n).Value
        if (-not (Test-DwEngineError $v)) { continue }
        $refs = @(Get-DwRuleReference $Session $Session.Rules[$n])
        $errRefs = @($refs | Where-Object { Test-DwEngineError (Get-DwSessionSlot $Session $_).Value })
        [pscustomobject]@{ Name = $n; Error = "$v"; RootCause = ($errRefs.Count -eq 0); Rule = ($Session.Rules[$n] -replace '\s+', ' ') }
    }
}

function ConvertTo-DwCssColor([string]$c) {
    if (-not $c) { return '' }
    $c = $c.Trim()
    switch -Regex ($c) {
        '^#[0-9A-Fa-f]{6,8}$' { return $c }
        '^\d+\s*,\s*\d+\s*,\s*\d+$' { return "rgb($c)" }
        '^\d+\s*,\s*\d+\s*,\s*\d+\s*,\s*\d+$' { $p = $c -split '\s*,\s*'; return "rgba($($p[1]),$($p[2]),$($p[3]),$([double]$p[0] / 255))" }
        '^(ControlText|WindowText)$' { return '#000000' }
        '^(Control|ButtonFace)$' { return '#F0F0F0' }
        '^Window$' { return '#FFFFFF' }
        '^Transparent$' { return 'transparent' }
        '^[A-Za-z]+$' { return $c.ToLower() }
    }
    ''
}

function Export-DwFormHtml {
    <#
    .SYNOPSIS  Renders a form (and the forms its frames show) to an HTML file, using the evaluated
               Left/Top/Width/Height/Visible of every control. Controls with a property in error get a red
               outline; the error list and the inputs are printed under the form.
    .PARAMETER ShowHidden  Draws invisible controls too, faded and dashed.
    .PARAMETER Screenshot  Also saves a PNG next to the HTML (headless Edge).
    .EXAMPLE   Export-DwFormHtml $s -Form Details -Path .\work\apron-form.html -Screenshot
    #>
    param(
        [Parameter(Mandatory, Position = 0)]$Session,
        [string]$Form,
        [Parameter(Mandatory)][string]$Path,
        [int]$Width = 0,
        [int]$Height = 0,
        [string]$Title,
        [switch]$ShowHidden,
        [switch]$Screenshot
    )
    if (-not $Form) {
        $step = @(Select-DwXml (Get-DwProjectXml $Session.Path designMaster) "/TDM/Navigation/Step[@Type='Start']")
        $Form = if ($step.Count) { $step[0].GetAttribute('NextStepValue') } else { @($Session.Forms.Keys)[0] }
    }
    $num = {
        param($c, $p, $fallback)
        $slot = $c.Slots[$p]
        if (-not $slot) { return $fallback }
        $v = $slot.Value
        if ($v -is [double]) { return $v }
        if ($v -is [bool]) { return [double][int]$v }
        $fallback
    }
    $str = { param($c, $p) $slot = $c.Slots[$p]; if ($slot) { Format-DwEngineValue $slot.Value } else { '' } }
    $enc = { param($s) [System.Net.WebUtility]::HtmlEncode([string]$s) }
    $errors = New-Object System.Collections.Generic.List[object]
    $sb = New-Object System.Text.StringBuilder
    $projDir = Split-Path -Parent $Session.Path

    $renderForm = $null
    $renderForm = {
        param($formName, $depth)
        if ($depth -gt 8 -or -not $Session.Forms.ContainsKey($formName)) { return }
        foreach ($c in $Session.Forms[$formName]) {
            $errProps = @(foreach ($p in $c.Slots.Keys) { if (Test-DwEngineError $c.Slots[$p].Value) { $p } })
            foreach ($p in $errProps) {
                $n = if ($Session.Scopes[$c.Name].Slots.ContainsKey($p)) { "$($c.Name).$p" } else { $c.Slots[$p].Name }
                $errors.Add([pscustomobject]@{ Form = $formName; Control = $c.Name; Property = $p; Slot = $n; Error = "$($c.Slots[$p].Value)" })
            }
            $vis = $c.Slots['Visible']
            $isVisible = $true
            if ($vis) { $vv = $vis.Value; if ($vv -is [bool]) { $isVisible = $vv } elseif ($vv -is [double]) { $isVisible = $vv -ne 0 } }
            if (-not $isVisible -and -not $ShowHidden) { continue }
            $l = & $num $c 'Left' 0; $t = & $num $c 'Top' 0; $w = & $num $c 'Width' 100; $h = & $num $c 'Height' 24
            $bg = ConvertTo-DwCssColor (& $str $c 'BackgroundColor')
            $style = "left:${l}px;top:${t}px;width:${w}px;height:${h}px;"
            if ($bg) { $style += "background:$bg;" }
            $cls = 'c ' + $c.Type
            if ($errProps.Count) { $cls += ' err' }
            if (-not $isVisible) { $cls += ' hidden' }
            $tip = "$($c.Name) [$($c.Type)] L=$l T=$t W=$w H=$h"
            if ($errProps.Count) { $tip += "`nERROR in: " + ($errProps -join ', ') }
            $capFont = & $str $c 'EffectiveCaptionFont'; $txtFont = & $str $c 'EffectiveTextFont'
            $capColor = ConvertTo-DwCssColor (& $str $c 'CaptionColor'); $txtColor = ConvertTo-DwCssColor (& $str $c 'TextColor')
            $value = Format-DwEngineValue $Session.Globals["$($c.Name)Return"].Value
            $tip += "`nValue: $value"
            [void]$sb.Append("<div class=`"$cls`" style=`"$style`" title=`"$(& $enc $tip)`">")
            $capW = & $num $c 'CaptionWidth' 0
            $caption = & $str $c 'Caption'
            $capHtml = "<span class=cap style=`"$capFont;color:$capColor;width:${capW}px`">$(& $enc $caption)</span>"
            switch ($c.Type) {
                'Label' { [void]$sb.Append("<span class=txt style=`"$txtFont;color:$txtColor`">$(& $enc $value)</span>") }
                'CheckBox' { $chk = if ($value -eq 'TRUE') { 'checked' } else { '' }; [void]$sb.Append("<label style=`"$capFont;color:$capColor`"><input type=checkbox $chk disabled> $(& $enc $caption)</label>") }
                'ComboBox' {
                    $items = @((Format-DwEngineValue $Session.Globals["$($c.Name)ListData"].Value) -split '\|', -1)
                    $opts = ($items | ForEach-Object { $s = if ($_ -ceq $value) { ' selected' } else { '' }; "<option$s>$(& $enc $_)</option>" }) -join ''
                    if (-not ($items -ccontains $value)) { $opts = "<option selected>$(& $enc $value)</option>" + $opts }
                    [void]$sb.Append("$capHtml<select disabled style=`"left:${capW}px`">$opts</select>")
                }
                { $_ -in 'TextBox', 'NumericTextBox' } { [void]$sb.Append("$capHtml<span class=box style=`"left:${capW}px;$txtFont;color:$txtColor`">$(& $enc $value)</span>") }
                'Slider' { [void]$sb.Append("<span class=sl>$(& $enc (& $str $c 'Text')) [$(& $enc $value)] ($(& $enc (Format-DwEngineValue $Session.Globals["$($c.Name)Min"].Value))&ndash;$(& $enc (Format-DwEngineValue $Session.Globals["$($c.Name)Max"].Value)))</span>") }
                'MacroButton' { [void]$sb.Append("<button disabled style=`"$txtFont`">$(& $enc (& $str $c 'Text'))</button>") }
                'PictureBox' {
                    $file = $value
                    $full = if ($file) { Join-Path $projDir $file } else { $null }
                    if ($full -and (Test-Path -LiteralPath $full)) { [void]$sb.Append("<img src=`"$(& $enc ([Uri]$full).AbsoluteUri)`">") }
                    elseif ($file) { [void]$sb.Append("<span class=pic>$(& $enc (Split-Path -Leaf $file))</span>") }
                }
                'FrameControl' {
                    $inner = & $str $c 'FormName'
                    $scroll = & $str $c 'VerticalScrollVisibility'
                    $ov = if ($scroll -in 'Auto', 'Visible', 'Default') { 'auto' } else { 'hidden' }
                    [void]$sb.Append("<div class=frame style=`"overflow:$ov`"><div class=form>")
                    & $renderForm $inner ($depth + 1)
                    [void]$sb.Append('</div></div>')
                }
                default { [void]$sb.Append("<span class=other>$(& $enc $c.Type)</span>") }
            }
            if ($errProps.Count) { [void]$sb.Append("<span class=badge>!</span>") }
            [void]$sb.Append('</div>')
        }
    }

    if (-not $Width) { $Width = [int](Format-DwEngineValue $Session.Globals['DWFormContainerWidth'].Value) }
    if (-not $Height) { $Height = [int](Format-DwEngineValue $Session.Globals['DWFormContainerHeight'].Value) }
    if (-not $Width) { $Width = 1200 }; if (-not $Height) { $Height = 875 }
    [void]$sb.Append("<div class=root style=`"width:${Width}px;height:${Height}px`"><div class=form>")
    & $renderForm $Form 0
    [void]$sb.Append('</div></div>')
    $body = $sb.ToString()

    $inputs = ($Session.Inputs.Keys | Sort-Object | ForEach-Object { "<code>$(& $enc $_) = $(& $enc $Session.Inputs[$_])</code>" }) -join ' '
    $over = (@($Session.Override.Keys) + @($Session.OverrideRule.Keys) | Sort-Object | ForEach-Object { $v = if ($Session.OverrideRule.ContainsKey($_)) { $Session.OverrideRule[$_] } else { $Session.Override[$_] }; "<code>$(& $enc $_) := $(& $enc $v)</code>" }) -join ' '
    $errRows = ($errors | ForEach-Object { "<tr><td>$(& $enc $_.Form)</td><td>$(& $enc $_.Slot)</td><td>$(& $enc $_.Error)</td><td><code>$(& $enc (($Session.Rules[$_.Slot]) -replace '\s+', ' '))</code></td></tr>" }) -join "`n"
    if (-not $errRows) { $errRows = '<tr><td colspan=4>No property in error in the rendered forms.</td></tr>' }
    $logRows = ($Session.Log | ForEach-Object { "<li>$(& $enc $_)</li>" }) -join ''
    if (-not $Title) { $Title = "$(Split-Path -Leaf $Session.Path) - $Form" }
    $html = @"
<!doctype html>
<html lang="en"><head><meta charset="utf-8"><title>$(& $enc $Title)</title>
<style>
body{font-family:Segoe UI,Arial,sans-serif;margin:16px;background:#fafafa;color:#222}
.root{position:relative;border:1px solid #999;background:#fff;overflow:hidden}
.form{position:relative;width:100%;height:100%}
.frame{position:absolute;inset:0}
.c{position:absolute;box-sizing:border-box;font-size:12px;overflow:hidden}
.c.err{outline:2px solid #d00;outline-offset:-2px}
.c.hidden{opacity:.3;outline:1px dashed #888}
.badge{position:absolute;right:1px;top:1px;background:#d00;color:#fff;font:bold 10px Arial;padding:0 3px;border-radius:2px}
.cap{position:absolute;left:0;top:2px;white-space:nowrap;overflow:hidden}
select,.box{position:absolute;top:0;right:0;height:100%;box-sizing:border-box;font-size:12px}
.box{border:1px solid #aaa;background:#f5f5f5;padding:2px 4px;white-space:nowrap;overflow:hidden}
.c img{width:100%;height:100%;object-fit:contain}
.pic,.other,.sl{font-size:10px;color:#777;padding:2px}
button{width:100%;height:100%}
table{border-collapse:collapse;margin-top:12px;font-size:12px}td,th{border:1px solid #ccc;padding:3px 6px;text-align:left;vertical-align:top}
code{font-size:11px;background:#eee;padding:1px 3px;margin-right:4px;display:inline-block}
</style></head><body>
<h3>$(& $enc $Title)</h3>
<p>Inputs: $inputs</p>
<p>Overrides: $over</p>
$body
<h4>Properties in error ($($errors.Count))</h4>
<table><tr><th>Form</th><th>Slot</th><th>Error</th><th>Rule</th></tr>
$errRows
</table>
<h4>Engine log</h4><ul>$logRows</ul>
<p style="color:#777;font-size:11px">Rendered by DwFormEngine with DriveWorks' Titan.Rules engine. Layout only: fonts, images and styling are approximate.</p>
</body></html>
"@
    $out = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
    [IO.File]::WriteAllText($out, $html, (New-Object Text.UTF8Encoding($false)))
    $png = $null
    if ($Screenshot) { $png = Save-DwFormScreenshot $out -Width ($Width + 60) -Height ($Height + 260 + 22 * [Math]::Min($errors.Count, 20)) }
    [pscustomobject]@{ Path = $out; Png = $png; Errors = $errors.Count }
}

function Save-DwFormScreenshot {
    <#
    .SYNOPSIS  Saves a PNG of an HTML file with headless Microsoft Edge (next to it, same name, .png).
    .EXAMPLE   Save-DwFormScreenshot .\work\apron-form\straight.html
    #>
    param([Parameter(Mandatory, Position = 0)][string]$Html, [string]$Png, [int]$Width = 1280, [int]$Height = 1100)
    $edge = @("${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe", "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe") | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
    if (-not $edge) { throw 'Microsoft Edge not found; open the HTML file in a browser instead.' }
    $Html = (Resolve-Path -LiteralPath $Html).Path
    if (-not $Png) { $Png = [IO.Path]::ChangeExtension($Html, '.png') }
    $profileDir = Join-Path $env:TEMP ('dwform-edge-' + [guid]::NewGuid().ToString('N'))
    try {
        Start-Process -FilePath $edge -ArgumentList @('--headless=new', '--disable-gpu', '--hide-scrollbars', "--user-data-dir=`"$profileDir`"", "--screenshot=`"$Png`"", "--window-size=$Width,$Height", ([Uri]$Html).AbsoluteUri) -WindowStyle Hidden -Wait
    } finally { Remove-Item -LiteralPath $profileDir -Recurse -Force -ErrorAction SilentlyContinue }
    if (-not (Test-Path -LiteralPath $Png)) { throw "Edge did not write '$Png'." }
    $Png
}

Export-ModuleMember -Function Format-DwEngineValue, New-DwFormSession, Set-DwFormInput, Update-DwFormLists, Get-DwFormValue, Invoke-DwFormRule, Trace-DwFormValue, Get-DwFormError, Get-DwCalcTable, Export-DwFormHtml, Save-DwFormScreenshot
