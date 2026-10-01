#Requires -Version 5.1
<#
    DwTools - inspect and safely modify DriveWorks files.

      .drivepkg    ZIP archive of a group snapshot       -> Expand-DwPackage
      .driveprojx  OPC package of XML parts (a project)   -> Get-/Edit-/Test-DwProject ...
      .drivegroup  SQLite database (group registry)       -> Invoke-DwGroupQuery (read-only)

    Format notes live in docs/formats/. Usage lives in tools/README.md.
    Written for Windows PowerShell 5.1 (the DriveWorks API and System.IO.Packaging
    are .NET Framework), so no PS7-only syntax.
#>

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName WindowsBase                        # System.IO.Packaging
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path

$script:CadExtensions = @('.sldprt', '.sldasm', '.slddrw', '.drive3d', '.swj', '.easm', '.eprt', '.edrw')

# Short XPath prefixes for Select-DwXml. Forms/controls sit in a *default* namespace, so plain XPath like
# "//Form" silently matches nothing - use f:Form.
$script:XmlNamespaces = [ordered]@{
    p     = 'http://schemas.driveworks.co.uk/project/'
    f     = 'pa-namespace:DriveWorks.Forms,DriveWorks.Engine'
    sf    = 'http://schemas.driveworks.co.uk/specification-flow/'
    ef    = 'http://schemas.driveworks.co.uk/event-flow/'
    pcomp = 'http://schemas.driveworks.co.uk/p-component/'
    ct    = 'http://schemas.driveworks.co.uk/p-component-task/'
    meta  = 'http://schemas.driveworks.co.uk/project-metadata/'
}

# Captured-parameter / element type ids -> DriveWorks constant names
# (DriveWorks.SolidWorks.Components.Constants, read from the DriveWorks 24.0.1.4 IL). See docs/formats/captured-models.md.
$script:CaptureTypes = @{
    '4ee71b52374c40f6a28fe97326eb46a4' = 'Dimension'                    # ID_PARAM_TYPE_DIMENSION / ID_EL_TYPE_DIMENSION
    '8c59824a2c03477e800a1f1a60bc5c01' = 'DimensionValue'
    '6bd70a086ba0404cb365076f17a06dd9' = 'DimensionTolerance'           # element
    '40045e6bce484a57a15f234d89236ab9' = 'DimensionToleranceType'
    '615c8532353c4abaa7439ba7c6d7b630' = 'DimensionToleranceLower'
    'a9ccb4a2e160423e87aff77e7ca372aa' = 'DimensionToleranceUpper'
    'c0a701eca33f43cd8fc30900650eae7d' = 'Feature'                      # element
    'd1d950c05a6a44e1b316a9a6ed3470d4' = 'FeatureSuppressionState'
    '1a11269b24d646fcbbe723ba02021004' = 'FeatureAdditionalState'
    'ee14582e29fc4b44b670d98a910463f5' = 'FeatureExtra'                 # e.g. pattern spacing / skipped instances
    'ccf239a84e644c9283ce945c547b84bb' = 'CustomProperty'
    '16512885644f463fb548b53e6df9ba67' = 'Configuration'
    '7849e9c8e07146938b2636da17112d5c' = 'Instance'                     # assembly component instance (suppress/delete)
    'f2c4e8f5ae0a4ca1bf0d4e36d3aceb2f' = 'ComponentReference'           # component replacement
    'ade7b1ae60fd4803b62e6e8ea64d8b31' = 'FileFormats'                  # element
    '63a61a18ba31407ab6ce85faf28aebec' = 'FileFormat'
    '338ac69ce248468c84fd0cb7399abb1e' = 'Tasks'                        # element
    '0d0b0484b6e14f998142d6eef750f83f' = 'Sheet'                        # element
    '19b0f6795a42483189cfb9084a3eaa9a' = 'SheetState'
    '6c67d93e002a4ae28e72f0623c58f0bb' = 'View'                         # element
    'e8396e0f2b7a4b9f86642e3f7b3c267f' = 'ViewState'
    'f0ddd55552a94772bd3ef9c7ee1ebfcb' = 'ViewTop'
    '90cdcd060e784ff09879ca33880101c0' = 'ViewLeft'
    '27d5a997d29c4aa3a09f36170020b2af' = 'ViewScaleNumerator'
    '8124f8d069ae403bbaa616d15cf4e565' = 'ViewScaleDenominator'
    '9aecf1efce3c456fa132abd05c221a83' = 'ViewDimension'                # element
    '2cdf831ab27c498a83e0ee4f998aca99' = 'ViewBreakLine'                # element
    '42c4c1fcd2944890aa39ac010e491080' = 'ViewBreakLineD1'
    'e8454e6d898e4179a400b14bf3d79a86' = 'ViewBreakLineD2'
    'ff592ccd06f64bca98416d223ab7ebd6' = 'ViewBreakLineDelete'
    '007b06319ec144f180a263d6902799e0' = 'Layer'                        # element
    '8ae4cfd224754b588595f11e3d9a53bb' = 'LayerVisibility'
    'c5fc7bc294334769a5a2de8ca171b9da' = 'DrawingAnnotation'
}

# Component-level rule slots in components/<n>.xml (meanings inferred from the rules they hold).
$script:ComponentSlots = [ordered]@{ CN = '(File name)'; CP = '(Path)'; CT = '(Tags)'; LC = '(Loop)' }
$script:CaptureCache = @{}

$script:PartAliases = @{
    'project'        = '/driveProj/project.xml'
    'designMaster'   = '/driveProj/designMaster.xml'
    'componentTasks' = '/driveProj/componentTasks.xml'
    'customSections' = '/driveProj/customSections.xml'
}

# =============================================================================
#  Internal helpers
# =============================================================================

function Get-DwInstallPath {
    <# Newest DriveWorks install folder, or $env:DW_INSTALL_DIR if set. #>
    if ($env:DW_INSTALL_DIR) { return $env:DW_INSTALL_DIR }
    $root = 'C:\Program Files\DriveWorks'
    $latest = Get-ChildItem -LiteralPath $root -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match '^\d+(\.\d+)+$' } |
        Sort-Object { [version]$_.Name } -Descending |
        Select-Object -First 1
    if (-not $latest) { throw "DriveWorks not found under '$root'. Set `$env:DW_INSTALL_DIR." }
    $latest.FullName
}

function Resolve-DwPartUri([string]$Part) {
    if ($Part.StartsWith('/')) { $uri = $Part }
    elseif ($script:PartAliases.ContainsKey($Part)) { $uri = $script:PartAliases[$Part] }
    elseif ($Part -match '^components/(\d+)(\.xml)?$') { $uri = "/driveProj/components/$($Matches[1]).xml" }
    else { throw "Unknown part '$Part'. Use project, designMaster, componentTasks, customSections, components/<n>, or an absolute part URI." }
    New-Object System.Uri($uri, [System.UriKind]::Relative)
}

function Resolve-DwOutputPath([string]$Path) {
    $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
}

function Get-DwProjectFile([string[]]$Path) {
    <# Expands files and folders (recursively) into .driveprojx paths. #>
    foreach ($p in $Path) {
        $item = Get-Item -LiteralPath $p
        if ($item.PSIsContainer) {
            Get-ChildItem -LiteralPath $item.FullName -Recurse -File -Filter *.driveprojx | ForEach-Object { $_.FullName }
        } else { $item.FullName }
    }
}

function Open-DwPackage([string]$Path, [switch]$Write) {
    $full = (Resolve-Path -LiteralPath $Path).Path
    if ($Write) {
        [System.IO.Packaging.Package]::Open($full, [IO.FileMode]::Open, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)
    } else {
        [System.IO.Packaging.Package]::Open($full, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
    }
}

function Get-DwXmlPart($Package) {
    <# All XML parts except OPC relationship parts. #>
    $Package.GetParts() | Where-Object { $_.ContentType -notlike '*relationships*' }
}

function Read-DwPartBytes($Package, [Uri]$Uri) {
    $stream = $Package.GetPart($Uri).GetStream([IO.FileMode]::Open, [IO.FileAccess]::Read)
    try {
        $ms = New-Object IO.MemoryStream
        $stream.CopyTo($ms)
        , $ms.ToArray()
    } finally { $stream.Dispose() }
}

function Read-DwPartXml($Package, [Uri]$Uri) {
    <# Loads a part preserving whitespace, and records the encoding details needed to write it back unchanged. #>
    $bytes = Read-DwPartBytes $Package $Uri
    $hasBom = $bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
    $text = [Text.Encoding]::UTF8.GetString($bytes)
    $newLine = if ($text.Contains("`r`n")) { "`r`n" } else { "`n" }

    $doc = New-Object System.Xml.XmlDocument
    $doc.PreserveWhitespace = $true
    $doc.XmlResolver = $null
    $doc.Load((New-Object IO.MemoryStream(, $bytes)))

    [pscustomobject]@{ Xml = $doc; HasBom = $hasBom; NewLine = $newLine }
}

function ConvertTo-DwPartBytes([System.Xml.XmlDocument]$Doc, [bool]$HasBom, [string]$NewLine) {
    $settings = New-Object System.Xml.XmlWriterSettings
    $settings.Encoding = New-Object System.Text.UTF8Encoding($HasBom)
    $settings.Indent = $false
    $settings.NewLineChars = $NewLine
    $settings.NewLineHandling = [System.Xml.NewLineHandling]::Replace
    $settings.OmitXmlDeclaration = -not ($Doc.FirstChild -is [System.Xml.XmlDeclaration])

    $ms = New-Object IO.MemoryStream
    $writer = [System.Xml.XmlWriter]::Create($ms, $settings)
    try { $Doc.Save($writer) } finally { $writer.Dispose() }
    , $ms.ToArray()
}

function Write-DwPartBytes($Package, [Uri]$Uri, [byte[]]$Bytes) {
    $stream = $Package.GetPart($Uri).GetStream([IO.FileMode]::Create, [IO.FileAccess]::Write)
    try { $stream.Write($Bytes, 0, $Bytes.Length) } finally { $stream.Dispose() }
}

function ConvertTo-DwXPathLiteral([string]$Text) {
    if (-not $Text.Contains("'")) { return "'$Text'" }
    if (-not $Text.Contains('"')) { return "`"$Text`"" }
    "concat('" + ($Text -replace "'", "', `"'`", '") + "')"
}

function Get-DwNodePath([System.Xml.XmlNode]$Node) {
    <# Human-readable location, e.g. Forms/Form[Details]/Controls/CheckBox[DevRelease]/Visible #>
    $segments = New-Object System.Collections.Generic.List[string]
    $n = $Node
    while ($n -and $n.NodeType -eq [System.Xml.XmlNodeType]::Element) {
        $label = $n.LocalName
        foreach ($attr in 'Name', 'DisplayName', 'StoreName', 'Title') {
            $v = $n.GetAttribute($attr)
            if ($v) { $label += "[$v]"; break }
        }
        $segments.Insert(0, $label)
        $n = $n.ParentNode
    }
    if ($segments.Count -gt 1) { $segments.RemoveAt(0) }   # drop the document root
    $segments -join '/'
}

function Get-DwRuleNode([System.Xml.XmlDocument]$Doc) {
    <# Every rule/formula in a part: attributes ending in "Rule", and leaf <Rule>/<Formula>/<R> elements. #>
    foreach ($a in $Doc.SelectNodes("//@*[substring(local-name(), string-length(local-name()) - 3) = 'Rule']")) {
        if ($a.Value) {
            [pscustomobject]@{ Location = (Get-DwNodePath $a.OwnerElement) + '@' + $a.LocalName; Rule = $a.Value }
        }
    }
    foreach ($e in $Doc.SelectNodes("//*[local-name()='Rule' or local-name()='Formula' or local-name()='R'][not(*)]")) {
        if ($e.InnerText) {
            [pscustomobject]@{ Location = Get-DwNodePath $e; Rule = $e.InnerText }
        }
    }
}

function Backup-DwFile([string]$Path) {
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $dir = Join-Path $script:RepoRoot "backups\$stamp"
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    $dest = Join-Path $dir (Split-Path -Leaf $Path)
    Copy-Item -LiteralPath $Path -Destination $dest
    $dest
}

function ConvertTo-DwIdKey([string]$Id) {
    <# GUIDs appear with and without dashes across DriveWorks files; normalise to 32 lowercase hex. #>
    $Id.Replace('-', '').Replace('{', '').Replace('}', '').ToLowerInvariant()
}

function Get-DwCaptureIndex([string]$Group) {
    <# id -> @{ Path; Type; Bytes; Params } for every captured component. Cached per group file + timestamp. #>
    $full = (Resolve-Path -LiteralPath $Group).Path
    $key = $full + '|' + (Get-Item -LiteralPath $full).LastWriteTimeUtc.Ticks
    if ($script:CaptureCache.ContainsKey($key)) { return $script:CaptureCache[$key] }

    if ((Get-DwGroupFormat $full) -ne 'SQLite') { throw "'$full' is not a SQLite group." }
    Import-DwSQLite
    $builder = New-Object System.Data.SQLite.SQLiteConnectionStringBuilder
    $builder.DataSource = $full; $builder.ReadOnly = $true; $builder.FailIfMissing = $true
    $cn = New-Object System.Data.SQLite.SQLiteConnection($builder.ConnectionString)
    $cn.Open()
    $index = @{}
    try {
        $cmd = $cn.CreateCommand()
        $cmd.CommandText = 'SELECT Id, Path, Type, Data FROM CapturedComponents'
        $reader = $cmd.ExecuteReader()
        while ($reader.Read()) {
            $bytes = if ($reader.IsDBNull(3)) { $null } else { [byte[]]$reader['Data'] }
            $index[(ConvertTo-DwIdKey ([string]$reader['Id']))] = @{ Path = $reader.GetString(1); Type = $reader.GetString(2); Bytes = $bytes; Params = $null }
        }
        $reader.Close()
    } finally { $cn.Close() }
    $script:CaptureCache.Clear()
    $script:CaptureCache[$key] = $index
    $index
}

function Get-DwCaptureParam($Capture) {
    <# Parses a capture's XML once: parameter id -> @{ Name; SolidWorksName; Kind; Element; ElementSolidWorksName; FeatureType } #>
    if ($null -ne $Capture.Params) { return $Capture.Params }
    $params = @{}
    if ($Capture.Bytes) {
        $doc = New-Object System.Xml.XmlDocument
        $doc.XmlResolver = $null
        $doc.LoadXml([Text.Encoding]::UTF8.GetString($Capture.Bytes))
        foreach ($p in $doc.SelectNodes("//*[local-name()='P']")) {
            $el = $p.ParentNode
            $typeKey = ConvertTo-DwIdKey $p.GetAttribute('T')
            $params[(ConvertTo-DwIdKey $p.GetAttribute('Id'))] = @{
                Name                  = $p.GetAttribute('N')
                SolidWorksName        = $p.GetAttribute('A')
                Kind                  = if ($script:CaptureTypes.ContainsKey($typeKey)) { $script:CaptureTypes[$typeKey] } else { $typeKey }
                Element               = $el.GetAttribute('N')
                ElementSolidWorksName = $el.GetAttribute('A')
                FeatureType           = $el.GetAttribute('S')
            }
        }
    }
    $Capture.Params = $params
    $params
}

function Import-DwSQLite {
    if (-not ('System.Data.SQLite.SQLiteConnection' -as [type])) {
        if (-not [Environment]::Is64BitProcess) { throw 'Use 64-bit PowerShell: the DriveWorks SQLite interop DLL is x64.' }
        Add-Type -Path (Join-Path (Get-DwInstallPath) 'System.Data.SQLite.dll')
    }
}

# =============================================================================
#  .drivepkg
# =============================================================================

function Expand-DwPackage {
    <#
    .SYNOPSIS  Extracts a .drivepkg (plain ZIP) to a folder.
    .EXAMPLE   Expand-DwPackage .\pkg.drivepkg .\work\pkg -ExcludeCad
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)][string]$Path,
        [Parameter(Mandatory, Position = 1)][string]$Destination,
        [switch]$ExcludeCad,            # skip SOLIDWORKS/3D files (~95% of the size)
        [string]$Include,               # regex on the entry path; only matching entries are extracted
        [switch]$IncludeGitFolder,      # the Sparta package contains a stray .git folder; skipped by default
        [switch]$Force                  # overwrite existing files
    )
    $zipPath = (Resolve-Path -LiteralPath $Path).Path
    $dest = [IO.Path]::GetFullPath((Resolve-DwOutputPath $Destination)).TrimEnd('\') + '\'
    $extracted = 0; $skipped = 0; $existing = 0

    $zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
    try {
        $total = $zip.Entries.Count; $i = 0
        foreach ($entry in $zip.Entries) {
            $i++
            if ($i % 250 -eq 0) { Write-Progress -Activity 'Expanding package' -Status $entry.FullName -PercentComplete (100 * $i / $total) }
            if (-not $entry.Name) { continue }                                   # folder entry
            $rel = $entry.FullName
            $ext = [IO.Path]::GetExtension($entry.Name).ToLowerInvariant()
            if ((-not $IncludeGitFolder -and $rel -match '^\.git/') -or
                $entry.Name -eq 'Thumbs.db' -or
                ($ExcludeCad -and $script:CadExtensions -contains $ext) -or
                ($Include -and $rel -notmatch $Include)) { $skipped++; continue }

            $target = [IO.Path]::GetFullPath((Join-Path $dest ($rel -replace '/', '\')))
            if (-not $target.StartsWith($dest, [StringComparison]::OrdinalIgnoreCase)) { throw "Unsafe path in package: $rel" }
            if ((Test-Path -LiteralPath $target) -and -not $Force) { $existing++; continue }

            New-Item -ItemType Directory -Force -Path (Split-Path $target) | Out-Null
            [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $target, $true)
            $extracted++
        }
    } finally {
        $zip.Dispose()
        Write-Progress -Activity 'Expanding package' -Completed
    }
    [pscustomobject]@{ Destination = $dest; Extracted = $extracted; Skipped = $skipped; AlreadyExisted = $existing }
}

# =============================================================================
#  .driveprojx - read
# =============================================================================

function Get-DwProjectPart {
    <# .SYNOPSIS Lists the parts inside a .driveprojx (URI, size, compression). #>
    param([Parameter(Mandatory, Position = 0)][string]$Path)
    $pkg = Open-DwPackage $Path
    try {
        foreach ($part in $pkg.GetParts()) {
            $s = $part.GetStream([IO.FileMode]::Open, [IO.FileAccess]::Read)
            try { $len = $s.Length } finally { $s.Dispose() }
            [pscustomobject]@{ Uri = $part.Uri.OriginalString; Bytes = $len; Compression = $part.CompressionOption; ContentType = $part.ContentType }
        }
    } finally { $pkg.Close() }
}

function Get-DwProjectXml {
    <#
    .SYNOPSIS  Returns one part of a project as an XmlDocument (read-only view).
    .EXAMPLE   $dm = Get-DwProjectXml '.\DW Ladder.driveprojx' designMaster
    #>
    param(
        [Parameter(Mandatory, Position = 0)][string]$Path,
        [Parameter(Position = 1)][string]$Part = 'project'
    )
    $pkg = Open-DwPackage $Path
    try { (Read-DwPartXml $pkg (Resolve-DwPartUri $Part)).Xml } finally { $pkg.Close() }
}

function Select-DwXml {
    <#
    .SYNOPSIS  XPath over a project part with DriveWorks namespace prefixes pre-registered:
               p: project, f: forms/controls, sf: spec flow, ef: event flow, pcomp: components,
               ct: component tasks, meta: metadata. designMaster.xml has no namespace (no prefix).
    .EXAMPLE   Select-DwXml $proj "//f:Form[@Name='Details']/f:Controls/*[@Name='DevRelease']/f:Visible/f:Rule"
    .EXAMPLE   Select-DwXml $dm "/TDM/Variables/Variable[@DisplayName='Client']"
    #>
    param(
        [Parameter(Mandatory, Position = 0)][System.Xml.XmlNode]$Xml,
        [Parameter(Mandatory, Position = 1)][string]$XPath
    )
    $doc = if ($Xml -is [System.Xml.XmlDocument]) { $Xml } else { $Xml.OwnerDocument }
    $nsm = New-Object System.Xml.XmlNamespaceManager($doc.NameTable)
    foreach ($k in $script:XmlNamespaces.Keys) { $nsm.AddNamespace($k, $script:XmlNamespaces[$k]) }
    $Xml.SelectNodes($XPath, $nsm)
}

function Expand-DwProject {
    <# .SYNOPSIS Unzips a .driveprojx into a folder of raw XML parts (for reading/diffing; not for repacking). #>
    param(
        [Parameter(Mandatory, Position = 0)][string]$Path,
        [Parameter(Mandatory, Position = 1)][string]$Destination
    )
    $dest = Resolve-DwOutputPath $Destination
    $zip = [System.IO.Compression.ZipFile]::OpenRead((Resolve-Path -LiteralPath $Path).Path)
    try {
        foreach ($entry in $zip.Entries) {
            if (-not $entry.Name) { continue }
            $target = Join-Path $dest ($entry.FullName -replace '/', '\')
            New-Item -ItemType Directory -Force -Path (Split-Path $target) | Out-Null
            [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $target, $true)
        }
    } finally { $zip.Dispose() }
    Get-Item -LiteralPath $dest
}

function Get-DwProjectSummary {
    <#
    .SYNOPSIS  One row per project: format version, group, and counts of variables, forms, controls, etc.
    .EXAMPLE   Get-DwProjectSummary '.\DriveWorks Files' | Format-Table
    #>
    param([Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias('FullName')][string[]]$Path)
    process {
        foreach ($file in Get-DwProjectFile $Path) {
            $pkg = Open-DwPackage $file
            try {
                $proj = (Read-DwPartXml $pkg (Resolve-DwPartUri 'project')).Xml
                $dm = (Read-DwPartXml $pkg (Resolve-DwPartUri 'designMaster')).Xml
                $componentParts = @($pkg.GetParts() | Where-Object { $_.Uri.OriginalString -like '/driveProj/components/*' }).Count
            } finally { $pkg.Close() }

            $root = $proj.DocumentElement
            $conn = @{}
            foreach ($seg in $root.GetAttribute('GroupConnectionString').Split(';')) {
                if ($seg -match '^\s*([^=]+)=(.*)$') { $conn[$Matches[1].Trim()] = $Matches[2] }
            }
            $count = { param($xpath) $proj.SelectNodes($xpath).Count }

            [pscustomobject]@{
                Project        = [IO.Path]::GetFileNameWithoutExtension($file)
                FormatVersion  = $root.GetAttribute('Version')
                GroupName      = $conn['Name']
                GroupServer    = $conn['Server']
                SizeKB         = [math]::Round((Get-Item -LiteralPath $file).Length / 1KB)
                Variables      = $dm.SelectNodes('/TDM/Variables/Variable').Count
                Constants      = $dm.SelectNodes('/TDM/Constants/Constant').Count
                Forms          = & $count "/*/*[local-name()='Forms']/*[local-name()='Form']"
                Controls       = & $count "/*/*[local-name()='Forms']/*[local-name()='Form']/*[local-name()='Controls']/*"
                Documents      = & $count "/*/*[local-name()='Documents']/*[local-name()='Document']"
                Macros         = & $count "/*/*[local-name()='SpecificationMacros']/*[local-name()='SpecificationMacro']"
                CalcTables     = & $count "/*/*[local-name()='CalculationTables']/*"
                DataTables     = & $count "/*/*[local-name()='DataTables']/*"
                ComponentParts = $componentParts
                Path           = $file
            }
        }
    }
}

function Get-DwVariable {
    <# .SYNOPSIS Lists variables (name, store name, category, rule) from designMaster.xml. #>
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias('FullName')][string[]]$Path,
        [string]$Name = '*'
    )
    process {
        foreach ($file in Get-DwProjectFile $Path) {
            $pkg = Open-DwPackage $file
            try {
                $proj = (Read-DwPartXml $pkg (Resolve-DwPartUri 'project')).Xml
                $dm = (Read-DwPartXml $pkg (Resolve-DwPartUri 'designMaster')).Xml
            } finally { $pkg.Close() }

            $categories = @{}
            foreach ($c in $proj.SelectNodes("//*[local-name()='VariableCategories']//*[local-name()='Category']")) {
                $categories[$c.GetAttribute('UniqueId')] = $c.GetAttribute('Name')
            }
            foreach ($v in $dm.SelectNodes('/TDM/Variables/Variable')) {
                if ($v.GetAttribute('DisplayName') -notlike $Name) { continue }
                $catId = $v.GetAttribute('Category')
                [pscustomobject]@{
                    Project   = [IO.Path]::GetFileNameWithoutExtension($file)
                    Name      = $v.GetAttribute('DisplayName')
                    StoreName = $v.GetAttribute('StoreName')
                    Category  = if ($categories.ContainsKey($catId)) { $categories[$catId] } else { $catId }
                    Rule      = $v.GetAttribute('Rule')
                    Comment   = $v.GetAttribute('Comment')
                }
            }
        }
    }
}

function Get-DwConstant {
    <# .SYNOPSIS Lists constants (name, store name, value) from designMaster.xml. #>
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias('FullName')][string[]]$Path,
        [string]$Name = '*'
    )
    process {
        foreach ($file in Get-DwProjectFile $Path) {
            $dm = Get-DwProjectXml $file designMaster
            foreach ($c in $dm.SelectNodes('/TDM/Constants/Constant')) {
                if ($c.GetAttribute('DisplayName') -notlike $Name) { continue }
                [pscustomobject]@{
                    Project   = [IO.Path]::GetFileNameWithoutExtension($file)
                    Name      = $c.GetAttribute('DisplayName')
                    StoreName = $c.GetAttribute('StoreName')
                    Value     = $c.GetAttribute('Value')
                    Comment   = $c.GetAttribute('Comment')
                }
            }
        }
    }
}

function Get-DwControl {
    <#
    .SYNOPSIS  Lists form controls: project, form, control name, control type, number of rule-driven properties.
    .EXAMPLE   Get-DwControl '.\DriveWorks Files\HandRails' -Form 'Details' | Format-Table
    #>
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias('FullName')][string[]]$Path,
        [string]$Form = '*',
        [string]$Name = '*'
    )
    process {
        foreach ($file in Get-DwProjectFile $Path) {
            $proj = Get-DwProjectXml $file project
            foreach ($f in Select-DwXml $proj '/p:Project/p:Forms/f:Form') {
                if ($f.GetAttribute('Name') -notlike $Form) { continue }
                foreach ($c in Select-DwXml $f 'f:Controls/*') {
                    if ($c.GetAttribute('Name') -notlike $Name) { continue }
                    [pscustomobject]@{
                        Project = [IO.Path]::GetFileNameWithoutExtension($file)
                        Form    = $f.GetAttribute('Name')
                        Name    = $c.GetAttribute('Name')
                        Type    = $c.LocalName
                        Rules   = @(Select-DwXml $c '*/f:Rule').Count
                    }
                }
            }
        }
    }
}

function Get-DwControlProperty {
    <#
    .SYNOPSIS  Properties of one control: name, IsStatic, whether it holds a Value or a Rule, and the text.
               IsStatic=True properties never hold rules (observed across all Sparta projects).
    .EXAMPLE   Get-DwControlProperty $proj -Form Details -Control DevRelease | Where-Object Kind -eq Rule
    #>
    param(
        [Parameter(Mandatory, Position = 0)][string]$Path,
        [Parameter(Mandatory)][string]$Form,
        [Parameter(Mandatory)][string]$Control
    )
    $file = @(Get-DwProjectFile $Path)[0]
    $proj = Get-DwProjectXml $file project
    $ctl = @(Select-DwXml $proj "/p:Project/p:Forms/f:Form[@Name=$(ConvertTo-DwXPathLiteral $Form)]/f:Controls/*[@Name=$(ConvertTo-DwXPathLiteral $Control)]")
    if ($ctl.Count -ne 1) { throw "Control '$Control' not found on form '$Form'." }
    foreach ($prop in $ctl[0].ChildNodes) {
        if ($prop.NodeType -ne [System.Xml.XmlNodeType]::Element) { continue }
        $content = @($prop.ChildNodes | Where-Object { $_.NodeType -eq [System.Xml.XmlNodeType]::Element -and $_.LocalName -in 'Value', 'Rule' })
        [pscustomobject]@{
            Property = $prop.LocalName
            IsStatic = $prop.GetAttribute('IsStatic') -eq 'True'
            Kind     = if ($content.Count) { $content[0].LocalName } else { $null }
            Text     = if ($content.Count) { $content[0].InnerText } else { $null }
        }
    }
}

function Get-DwModelRule {
    <#
    .SYNOPSIS  Driven-model rules with real names. For each captured model in a project, lists every captured
               parameter (dimension, feature state, custom property, instance, ...) and the rule driving it.
               Needs the group file: parameter names live in the group's captured-component data, and the
               project only stores their ids (CPRef).
    .PARAMETER Unassigned         Only captured parameters with no rule yet, e.g. just captured in SOLIDWORKS.
    .PARAMETER IncludeUnassigned  Rules plus unassigned captured parameters.
    .PARAMETER Kind               Filter on kind: Dimension, FeatureSuppressionState, CustomProperty, Instance, Component, ...
    .EXAMPLE   Get-DwModelRule '.\DriveWorks Files\Ladder' -Group $g | Format-Table Model, Kind, Parameter, Rule
    .EXAMPLE   Get-DwModelRule $proj -Group $g -Model 'DW06-A136*' -Unassigned -Kind Dimension, FeatureSuppressionState
    #>
    [CmdletBinding(DefaultParameterSetName = 'Rules')]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias('FullName')][string[]]$Path,
        [string]$Group = $env:DW_GROUP_FILE,
        [string]$Model = '*',
        [string[]]$Kind,
        [Parameter(ParameterSetName = 'Unassigned')][switch]$Unassigned,
        [Parameter(ParameterSetName = 'All')][switch]$IncludeUnassigned
    )
    begin {
        if (-not $Group) { throw 'Pass -Group <file.drivegroup> (or set $env:DW_GROUP_FILE).' }
        $captures = Get-DwCaptureIndex $Group
        $emit = {
            param($kindName, $name, $swName, $rule, $ref)
            if ($Kind -and $Kind -notcontains $kindName) { return }
            [pscustomobject]@{
                Project = $projectName; ComponentSet = $componentSet; Model = $modelName; Kind = $kindName; Parameter = $name
                SolidWorksName = $swName; Rule = $rule; ParamRef = $ref; Part = $partUri; ModelPath = $modelPath
            }
        }
        $describe = {
            param($info)   # suppression-state parameters are unnamed; the name is on the parent feature
            if ($info.Name) { @($info.Name, $info.SolidWorksName) } else { @($info.Element, $info.ElementSolidWorksName) }
        }
    }
    process {
        foreach ($file in Get-DwProjectFile $Path) {
            $projectName = [IO.Path]::GetFileNameWithoutExtension($file)
            $pkg = Open-DwPackage $file
            try {
                # components/<n>.xml -> component set name, via project.xml's relationships (ComponentSet/@RId)
                $projectUri = Resolve-DwPartUri 'project'
                $relTarget = @{}
                foreach ($r in $pkg.GetPart($projectUri).GetRelationships()) {
                    $relTarget[$r.Id] = ([System.IO.Packaging.PackUriHelper]::ResolvePartUri($projectUri, $r.TargetUri)).OriginalString
                }
                $setByPart = @{}
                foreach ($cs in Select-DwXml (Read-DwPartXml $pkg $projectUri).Xml '/p:Project/p:ComponentSets/p:ComponentSet') {
                    $rid = $cs.GetAttribute('RId')
                    if ($relTarget.ContainsKey($rid)) { $setByPart[$relTarget[$rid]] = $cs.GetAttribute('Name') }
                }
                foreach ($part in @($pkg.GetParts() | Where-Object { $_.Uri.OriginalString -like '/driveProj/components/*' })) {
                    $partUri = $part.Uri.OriginalString
                    $componentSet = if ($setByPart.ContainsKey($partUri)) { $setByPart[$partUri] } else { '' }
                    $doc = (Read-DwPartXml $pkg $part.Uri).Xml
                    foreach ($pc in Select-DwXml $doc '//pcomp:PC') {
                        $ccKey = ConvertTo-DwIdKey $pc.GetAttribute('CCRef')
                        $cap = if ($captures.ContainsKey($ccKey)) { $captures[$ccKey] } else { $null }
                        $modelPath = if ($cap) { $cap.Path } else { "<capture $ccKey not in group>" }
                        $modelName = Split-Path -Leaf $modelPath
                        if ($modelName -notlike $Model) { continue }
                        $params = if ($cap) { Get-DwCaptureParam $cap } else { @{} }

                        if (-not $Unassigned) {
                            foreach ($slot in $script:ComponentSlots.Keys) {
                                $r = @(Select-DwXml $pc "pcomp:$slot/pcomp:R")
                                if ($r.Count -and $r[0].InnerText) { & $emit 'Component' $script:ComponentSlots[$slot] '' $r[0].InnerText '' }
                            }
                        }

                        $ruled = @{}
                        foreach ($pp in Select-DwXml $pc 'pcomp:PE//pcomp:PP') {     # this component's parameters only (child PCs are siblings of PE)
                            $key = ConvertTo-DwIdKey $pp.GetAttribute('CPRef')
                            $r = @(Select-DwXml $pp 'pcomp:R')
                            if (-not $r.Count -or -not $r[0].InnerText) { continue }
                            $ruled[$key] = $true
                            if ($Unassigned) { continue }
                            if ($params.ContainsKey($key)) {
                                $n = & $describe $params[$key]
                                & $emit $params[$key].Kind $n[0] $n[1] $r[0].InnerText $key
                            } else { & $emit 'Unknown' '' '' $r[0].InnerText $key }
                        }

                        if ($Unassigned -or $IncludeUnassigned) {
                            foreach ($key in $params.Keys) {
                                if ($ruled.ContainsKey($key)) { continue }
                                $n = & $describe $params[$key]
                                & $emit $params[$key].Kind $n[0] $n[1] $null $key
                            }
                        }
                    }
                }
            } finally { $pkg.Close() }
        }
    }
}

function Get-DwRuleDependency {
    <#
    .SYNOPSIS  Traces what a variable is computed from: walks DWVariable / DWConstant / control references in its
               rule, recursively, down to constants and form inputs. One row per node, depth-first.
    .EXAMPLE   Get-DwRuleDependency $proj bottomconstatmult | Format-Table Depth, Kind, Name, Detail -Wrap
    #>
    param(
        [Parameter(Mandatory, Position = 0)][string]$Path,
        [Parameter(Mandatory, Position = 1)][string]$Variable,
        [int]$MaxDepth = 12
    )
    $file = @(Get-DwProjectFile $Path)[0]
    $vars = @{}; foreach ($v in Get-DwVariable $file) { $vars[$v.Name] = $v }
    $consts = @{}; foreach ($c in Get-DwConstant $file) { $consts[$c.Name] = $c }
    $ctls = @{}; foreach ($c in Get-DwControl $file) { if (-not $ctls.ContainsKey($c.Name)) { $ctls[$c.Name] = $c } }
    $seen = @{}

    $refs = {
        param([string]$rule)
        $out = New-Object System.Collections.Generic.List[object]
        foreach ($m in [regex]::Matches($rule, '\bDWVariable([A-Za-z0-9_]+)')) { $out.Add(@('Variable', $m.Groups[1].Value)) }
        foreach ($m in [regex]::Matches($rule, '\bDWConstant([A-Za-z0-9_]+)')) { $out.Add(@('Constant', $m.Groups[1].Value)) }
        $scrubbed = [regex]::Replace($rule, '"[^"]*"|\bDW(Variable|Constant)[A-Za-z0-9_]+', ' ')
        foreach ($m in [regex]::Matches($scrubbed, '\b([A-Za-z_][A-Za-z0-9_]*?)(Return)?\b')) {
            $n = $m.Groups[1].Value
            if ($ctls.ContainsKey($n)) { $out.Add(@('Control', $n)) }
        }
        $seenLocal = @{}
        foreach ($r in $out) { $k = $r[0] + ':' + $r[1]; if (-not $seenLocal.ContainsKey($k)) { $seenLocal[$k] = 1; , $r } }
    }
    $walk = {
        param([string]$kind, [string]$name, [int]$depth)
        $key = "$kind`:$name"
        $repeat = $seen.ContainsKey($key)
        $seen[$key] = $true
        switch ($kind) {
            'Variable' {
                $v = if ($vars.ContainsKey($name)) { $vars[$name] } else { $null }
                $detail = if ($v) { ($v.Rule -replace '\s+', ' ').Trim() } else { '<not found>' }
                [pscustomobject]@{ Depth = $depth; Kind = 'Variable'; Name = $name; Detail = $detail; Repeat = $repeat }
                if ($v -and -not $repeat -and $depth -lt $MaxDepth) { foreach ($r in & $refs $v.Rule) { & $walk $r[0] $r[1] ($depth + 1) } }
            }
            'Constant' {
                $c = if ($consts.ContainsKey($name)) { $consts[$name] } else { $null }
                [pscustomobject]@{ Depth = $depth; Kind = 'Constant'; Name = $name; Detail = $(if ($c) { "= '$($c.Value)'" } else { '<not found>' }); Repeat = $repeat }
            }
            'Control' {
                $c = $ctls[$name]
                [pscustomobject]@{ Depth = $depth; Kind = 'Input'; Name = $name; Detail = "$($c.Type) on form '$($c.Form)'"; Repeat = $repeat }
            }
        }
    }
    & $walk 'Variable' $Variable 0
}

function Find-DwUnusedVariable {
    <#
    .SYNOPSIS  Variables nothing uses. Scans the raw text of EVERY part (forms, documents, macros, calc tables,
               spec flow, model rules, component tasks...), ignoring comments, and follows variable->variable
               references so dead chains show up too.
                 Unreferenced      - no reference anywhere
                 OnlyUsedByUnused  - referenced only by other unused variables (a dead chain)
               Variables whose name matches a string fragment used to build names at run time
               (Indirect("DWVariableLengthMidSection" & n)) are treated as used and never reported.
               Not checked: other projects (parent/child specifications) and external document templates.
    .EXAMPLE   Find-DwUnusedVariable '.\DriveWorks Files\Apron\DW Apron Project.driveprojx' | Format-Table
    #>
    param([Parameter(Mandatory, Position = 0)][string]$Path)
    $file = @(Get-DwProjectFile $Path)[0]
    $vars = @(Get-DwVariable $file)
    $byStore = @{}; foreach ($v in $vars) { $byStore[$v.StoreName] = $v }
    $tokenRx = '\bDWVariable[A-Za-z0-9_]+'
    $stripComments = { param([string]$t) [regex]::Replace($t, '<(pcomp:C|Comment|comp-task:Comment)>[\s\S]*?</\1>|\sComment="[^"]*"', ' ') }

    $external = New-Object System.Text.StringBuilder
    $pkg = Open-DwPackage $file
    try {
        foreach ($part in Get-DwXmlPart $pkg) {
            if ($part.Uri.OriginalString -eq $script:PartAliases['designMaster']) {
                $dm = (Read-DwPartXml $pkg $part.Uri).Xml
                foreach ($section in $dm.DocumentElement.ChildNodes) {      # everything except the variable definitions
                    if ($section.NodeType -eq [System.Xml.XmlNodeType]::Element -and $section.LocalName -ne 'Variables') {
                        [void]$external.Append((& $stripComments $section.OuterXml))
                    }
                }
            } else {
                [void]$external.Append((& $stripComments ([Text.Encoding]::UTF8.GetString((Read-DwPartBytes $pkg $part.Uri)))))
            }
        }
    } finally { $pkg.Close() }
    $externalText = $external.ToString()

    $extCount = @{}
    foreach ($m in [regex]::Matches($externalText, $tokenRx)) { $extCount[$m.Value] = 1 + $(if ($extCount.ContainsKey($m.Value)) { $extCount[$m.Value] } else { 0 }) }

    # variable -> variables it references (its own rule only; self-references ignored)
    $refs = @{}; $refBy = @{}
    foreach ($v in $vars) {
        $refs[$v.StoreName] = @([regex]::Matches([string]$v.Rule, $tokenRx) | ForEach-Object { $_.Value } | Where-Object { $byStore.ContainsKey($_) -and $_ -ne $v.StoreName } | Sort-Object -Unique)
        foreach ($r in $refs[$v.StoreName]) { if (-not $refBy.ContainsKey($r)) { $refBy[$r] = New-Object System.Collections.Generic.List[string] }; $refBy[$r].Add($v.Name) }
    }

    # run-time name fragments: "DWVariableSomething" as a string literal (&quot; inside attributes)
    $allRules = $externalText + ' ' + (($vars | ForEach-Object { [string]$_.Rule }) -join ' ')
    $fragments = @([regex]::Matches($allRules, '(?:"|&quot;)(DWVariable[A-Za-z0-9_]*)(?:"|&quot;)') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)
    $dynamic = @($fragments | Where-Object { $_ -eq 'DWVariable' })
    if ($dynamic.Count) { Write-Warning 'Found fully dynamic references ("DWVariable" & ...). Any variable could be used through them; review manually.' }
    $prefixes = @($fragments | Where-Object { $_ -ne 'DWVariable' })

    $live = @{}; $queue = New-Object System.Collections.Generic.Queue[string]
    foreach ($s in $byStore.Keys) {
        $indirect = @($prefixes | Where-Object { $s.StartsWith($_, [StringComparison]::OrdinalIgnoreCase) }).Count -gt 0
        if ($extCount.ContainsKey($s) -or $indirect) { $live[$s] = $true; $queue.Enqueue($s) }
    }
    while ($queue.Count) { foreach ($r in $refs[$queue.Dequeue()]) { if (-not $live.ContainsKey($r)) { $live[$r] = $true; $queue.Enqueue($r) } } }

    foreach ($v in ($vars | Sort-Object Name)) {
        if ($live.ContainsKey($v.StoreName)) { continue }
        $by = @($(if ($refBy.ContainsKey($v.StoreName)) { $refBy[$v.StoreName] | Sort-Object -Unique }))
        [pscustomobject]@{
            Name         = $v.Name
            Status       = if ($by.Count) { 'OnlyUsedByUnused' } else { 'Unreferenced' }
            ReferencedBy = $by -join ', '
            Category     = $v.Category
            Rule         = (([string]$v.Rule -replace '\s+', ' ').Trim())
        }
    }
}

function ConvertTo-DwFlatXml([System.Xml.XmlNode]$Node, [string]$Prefix, $Out) {
    <# Flattens an XML subtree to path -> value. Paths use Name/DisplayName/StoreName/Title labels; repeated labels get #n. #>
    $seen = @{}
    foreach ($child in $Node.ChildNodes) {
        if ($child.NodeType -ne [System.Xml.XmlNodeType]::Element) { continue }
        $label = $child.LocalName; $labelAttr = $null
        foreach ($a in 'Name', 'DisplayName', 'StoreName', 'Title') { $v = $child.GetAttribute($a); if ($v) { $label += "[$v]"; $labelAttr = $a; break } }
        $seen[$label] = 1 + $(if ($seen.ContainsKey($label)) { $seen[$label] } else { 0 })
        if ($seen[$label] -gt 1) { $label += "#$($seen[$label])" }
        $path = if ($Prefix) { "$Prefix/$label" } else { $label }
        foreach ($attr in $child.Attributes) {
            if ($attr.Name -like 'xmlns*' -or $attr.LocalName -eq $labelAttr) { continue }
            $Out["$path@$($attr.LocalName)"] = $attr.Value
        }
        $hasElementChild = $false
        foreach ($g in $child.ChildNodes) { if ($g.NodeType -eq [System.Xml.XmlNodeType]::Element) { $hasElementChild = $true; break } }
        if ($hasElementChild) { ConvertTo-DwFlatXml $child $path $Out } else { $Out[$path] = $child.InnerText }
    }
}

function Get-DwProjectContent([string]$File, [string]$Group) {
    <# Everything comparable in a project, as key -> value. #>
    $out = New-Object 'System.Collections.Generic.Dictionary[string,string]'
    foreach ($v in Get-DwVariable $File) {
        $out["Variable[$($v.Name)]"] = [string]$v.Rule
        $out["Variable[$($v.Name)]@Category"] = [string]$v.Category
        if ($v.Comment) { $out["Variable[$($v.Name)]@Comment"] = [string]$v.Comment }
    }
    foreach ($c in Get-DwConstant $File) {
        $out["Constant[$($c.Name)]"] = [string]$c.Value
        if ($c.Comment) { $out["Constant[$($c.Name)]@Comment"] = [string]$c.Comment }
    }
    $pkg = Open-DwPackage $File
    try {
        $dm = (Read-DwPartXml $pkg (Resolve-DwPartUri 'designMaster')).Xml
        $tmp = @{}; ConvertTo-DwFlatXml $dm.DocumentElement '' $tmp
        foreach ($k in $tmp.Keys) { if ($k -notmatch '^(Variables|Constants)/') { $out["designMaster/$k"] = $tmp[$k] } }
        foreach ($name in 'project', 'componentTasks') {
            $uri = Resolve-DwPartUri $name
            if (-not $pkg.PartExists($uri)) { continue }
            $tmp = @{}; ConvertTo-DwFlatXml (Read-DwPartXml $pkg $uri).Xml.DocumentElement '' $tmp
            foreach ($k in $tmp.Keys) { $out["$name/$k"] = $tmp[$k] }
        }
    } finally { $pkg.Close() }
    if ($Group) {
        foreach ($r in Get-DwModelRule $File -Group $Group) {
            $out["ModelRule[$($r.ComponentSet)|$($r.Model)|$($r.Kind)|$($r.Parameter)|$($r.ParamRef)]"] = [string]$r.Rule
        }
    }
    $out
}

function Compare-DwProjectContent {
    <#
    .SYNOPSIS  Semantic change report between two versions of a project: variables, constants, forms/controls,
               documents, macros, calc tables, spec flow, component tasks and (with -Group) model rules.
               Renamed variables/constants are detected from how references changed, reported once as Renamed,
               and substituted before comparing, so a rename does not show up as hundreds of changed rules.
    .EXAMPLE   Compare-DwProjectContent .\work\old.driveprojx '.\DriveWorks Files\Apron\DW Apron Project.driveprojx' -Group $g
    #>
    param(
        [Parameter(Mandatory, Position = 0)][string]$Reference,
        [Parameter(Mandatory, Position = 1)][string]$Difference,
        [string]$Group = $env:DW_GROUP_FILE
    )
    $old = Get-DwProjectContent (@(Get-DwProjectFile $Reference)[0]) $Group
    $new = Get-DwProjectContent (@(Get-DwProjectFile $Difference)[0]) $Group

    # --- rename detection: removed/added variables & constants, confirmed by reference changes ---
    $renames = @{}
    foreach ($kind in 'Variable', 'Constant') {
        $rx = "^$kind\[([^\]]+)\]$"
        $oldNames = @($old.Keys | Where-Object { $_ -match $rx } | ForEach-Object { [regex]::Match($_, $rx).Groups[1].Value })
        $newNames = @($new.Keys | Where-Object { $_ -match $rx } | ForEach-Object { [regex]::Match($_, $rx).Groups[1].Value })
        $removed = @($oldNames | Where-Object { $newNames -notcontains $_ })
        $added = @($newNames | Where-Object { $oldNames -notcontains $_ })
        if (-not $removed.Count -or -not $added.Count) { continue }
        $prefix = "DW$kind"
        $votes = @{}
        foreach ($k in $old.Keys) {
            if (-not $new.ContainsKey($k) -or $old[$k] -eq $new[$k]) { continue }
            $a = @([regex]::Matches($old[$k], "\b$prefix[A-Za-z0-9_]+") | ForEach-Object { $_.Value })
            $b = @([regex]::Matches($new[$k], "\b$prefix[A-Za-z0-9_]+") | ForEach-Object { $_.Value })
            if ($a.Count -ne $b.Count) { continue }
            for ($i = 0; $i -lt $a.Count; $i++) { if ($a[$i] -ne $b[$i]) { $pair = "$($a[$i])>$($b[$i])"; $votes[$pair] = 1 + $(if ($votes.ContainsKey($pair)) { $votes[$pair] } else { 0 }) } }
        }
        # a renamed variable keeps its own rule; use that too (rule equal after renaming = strong evidence)
        foreach ($r in $removed) { foreach ($n in $added) {
            if ($old["$kind[$r]"] -eq $new["$kind[$n]"] -and $old["$kind[$r]"]) { $pair = "$prefix$r>$prefix$n"; $votes[$pair] = 1000 + $(if ($votes.ContainsKey($pair)) { $votes[$pair] } else { 0 }) } } }
        $usedOld = @{}; $usedNew = @{}
        foreach ($p in ($votes.GetEnumerator() | Sort-Object Value -Descending)) {
            $parts = $p.Name -split '>'; $o = $parts[0].Substring($prefix.Length); $n = $parts[1].Substring($prefix.Length)
            if ($removed -contains $o -and $added -contains $n -and -not $usedOld.ContainsKey($o) -and -not $usedNew.ContainsKey($n)) {
                $renames["$prefix$o"] = "$prefix$n"; $usedOld[$o] = 1; $usedNew[$n] = 1
                [pscustomobject]@{ Area = $kind; Change = 'Renamed'; Item = $o; Old = $o; New = $n; Evidence = "$($p.Value) reference(s)" }
            }
        }
    }

    # --- component-set renames: same RId, different name ---
    $setRenames = @{}
    $ridOld = @{}; foreach ($k in $old.Keys) { if ($k -match '^project/ComponentSets/ComponentSet\[(.+)\]@RId$') { $ridOld[$old[$k]] = $Matches[1] } }
    foreach ($k in $new.Keys) {
        if ($k -match '^project/ComponentSets/ComponentSet\[(.+)\]@RId$' -and $ridOld.ContainsKey($new[$k]) -and $ridOld[$new[$k]] -ne $Matches[1]) {
            $setRenames[$ridOld[$new[$k]]] = $Matches[1]
            [pscustomobject]@{ Area = 'ComponentSet'; Change = 'Renamed'; Item = $ridOld[$new[$k]]; Old = $ridOld[$new[$k]]; New = $Matches[1]; Evidence = "same RId $($new[$k])" }
        }
    }

    # --- control renames: same form and type, mostly identical properties ---
    $ctlRenames = @{}
    $ctlRx = '^project/Forms/Form\[([^\]]+)\]/Controls/([A-Za-z]+)\[([^\]]+)\]/(.+)$'
    $byControl = {     # (not $group: PowerShell names are case-insensitive and $Group is a [string] parameter)
        param($dict)
        $g = @{}
        foreach ($k in $dict.Keys) { if ($k -match $ctlRx) { $id = "$($Matches[1])|$($Matches[2])|$($Matches[3])"; if (-not $g.ContainsKey($id)) { $g[$id] = @{} }; $g[$id][$Matches[4]] = $dict[$k] } }
        $g
    }
    $gOld = & $byControl $old; $gNew = & $byControl $new
    $goneCtl = @($gOld.Keys | Where-Object { -not $gNew.ContainsKey($_) }); $newCtl = @($gNew.Keys | Where-Object { -not $gOld.ContainsKey($_) })
    foreach ($o in $goneCtl) {
        $fo = $o -split '\|'; $best = $null; $bestScore = 0
        foreach ($n in $newCtl) {
            $fn = $n -split '\|'
            if ($fn[0] -ne $fo[0] -or $fn[1] -ne $fo[1] -or $ctlRenames.ContainsValue($fn[2])) { continue }
            $props = @($gOld[$o].Keys); if (-not $props.Count) { continue }
            $same = @($props | Where-Object { $gNew[$n].ContainsKey($_) -and $gNew[$n][$_] -eq $gOld[$o][$_] }).Count
            $score = $same / [Math]::Max($props.Count, $gNew[$n].Count)
            if ($score -gt $bestScore) { $bestScore = $score; $best = $n }
        }
        if ($best -and $bestScore -ge 0.6) {
            $ctlRenames[$fo[2]] = ($best -split '\|')[2]
            [pscustomobject]@{ Area = 'Control'; Change = 'Renamed'; Item = "$($fo[0]) / $($fo[1])"; Old = $fo[2]; New = $ctlRenames[$fo[2]]; Evidence = "{0:P0} of properties identical" -f $bestScore }
        }
    }

    # --- apply renames to the old side (values and keys), then diff ---
    $apply = {
        param([string]$s)
        foreach ($o in $renames.Keys) { $s = [regex]::Replace($s, "\b$([regex]::Escape($o))\b", $renames[$o]) }
        foreach ($o in $ctlRenames.Keys) { $s = [regex]::Replace($s, "\b$([regex]::Escape($o))(?=Return\b|\b)", $ctlRenames[$o]) }
        $s
    }
    $renameKey = {
        param([string]$key)
        foreach ($o in $renames.Keys) {
            $plain = $o -replace '^DW(Variable|Constant)', ''; $plainNew = $renames[$o] -replace '^DW(Variable|Constant)', ''
            $key = $key -replace "^(Variable|Constant)\[$([regex]::Escape($plain))\]", "`$1[$plainNew]"
        }
        foreach ($o in $setRenames.Keys) {
            $key = $key.Replace("ComponentSet[$o]", "ComponentSet[$($setRenames[$o])]").Replace("ModelRule[$o|", "ModelRule[$($setRenames[$o])|")
        }
        if ($key -match $ctlRx -and $ctlRenames.ContainsKey($Matches[3])) {
            $key = "project/Forms/Form[$($Matches[1])]/Controls/$($Matches[2])[$($ctlRenames[$Matches[3]])]/$($Matches[4])"
        }
        $key
    }
    $anyRename = ($renames.Count + $ctlRenames.Count) -gt 0
    $oldN = @{}
    foreach ($k in $old.Keys) { $oldN[(& $renameKey $k)] = if ($anyRename) { & $apply $old[$k] } else { $old[$k] } }
    $area = { param($k) if ($k -match '^(Variable|Constant|ModelRule)\[') { $Matches[1] } elseif ($k -match '^([^/]+)/([^/\[]+)') { "$($Matches[1])/$($Matches[2])" } else { 'Other' } }
    $squash = { param($s) ([string]$s -replace '\s+', '') }
    foreach ($k in ($oldN.Keys + $new.Keys | Sort-Object -Unique)) {
        $inOld = $oldN.ContainsKey($k); $inNew = $new.ContainsKey($k)
        if ($inOld -and $inNew -and $oldN[$k] -eq $new[$k]) { continue }
        [pscustomobject]@{
            Area     = & $area $k
            Change   = if (-not $inOld) { 'Added' } elseif (-not $inNew) { 'Removed' } elseif ((& $squash $oldN[$k]) -eq (& $squash $new[$k])) { 'Reformatted' } else { 'Changed' }
            Item     = $k
            Old      = if ($inOld) { $oldN[$k] } else { $null }
            New      = if ($inNew) { $new[$k] } else { $null }
            Evidence = ''
        }
    }
}

function Find-DwRule {
    <#
    .SYNOPSIS  Searches every rule/formula in every part of one or more projects.
    .EXAMPLE   Find-DwRule 'DWVariableWorkOrder' '.\DriveWorks Files' | Format-Table Project, Location
    .EXAMPLE   Find-DwRule 'SPA-DWP' . -SimpleMatch
    #>
    param(
        [Parameter(Mandatory, Position = 0)][string]$Pattern,
        [Parameter(Position = 1)][string[]]$Path = '.',
        [switch]$SimpleMatch
    )
    $regex = if ($SimpleMatch) { [regex]::Escape($Pattern) } else { $Pattern }
    foreach ($file in Get-DwProjectFile $Path) {
        $pkg = Open-DwPackage $file
        try {
            foreach ($part in Get-DwXmlPart $pkg) {
                $doc = (Read-DwPartXml $pkg $part.Uri).Xml
                foreach ($hit in Get-DwRuleNode $doc) {
                    if ($hit.Rule -match $regex) {
                        [pscustomobject]@{
                            Project  = [IO.Path]::GetFileNameWithoutExtension($file)
                            Part     = $part.Uri.OriginalString
                            Location = $hit.Location
                            Rule     = $hit.Rule
                        }
                    }
                }
            }
        } finally { $pkg.Close() }
    }
}

function Test-DwProject {
    <#
    .SYNOPSIS  Structural validation: package opens, required parts exist, every XML part parses,
               every relationship target exists. Does NOT validate rule syntax (only DriveWorks can).
    #>
    param([Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)][Alias('FullName')][string[]]$Path)
    process {
        foreach ($file in Get-DwProjectFile $Path) {
            $errors = New-Object System.Collections.Generic.List[string]
            try {
                $pkg = Open-DwPackage $file
                try {
                    foreach ($required in $script:PartAliases['project'], $script:PartAliases['designMaster']) {
                        if (-not $pkg.PartExists((Resolve-DwPartUri $required))) { $errors.Add("Missing required part $required") }
                    }
                    foreach ($part in Get-DwXmlPart $pkg) {
                        try { [void](Read-DwPartXml $pkg $part.Uri) } catch { $errors.Add("$($part.Uri): $($_.Exception.Message)") }
                    }
                    $rels = @($pkg.GetRelationships())
                    foreach ($part in $pkg.GetParts()) {
                        if ($part.ContentType -notlike '*relationships*') { $rels += @($part.GetRelationships()) }
                    }
                    foreach ($rel in $rels) {
                        if ($rel.TargetMode -ne [System.IO.Packaging.TargetMode]::Internal) { continue }
                        $target = [System.IO.Packaging.PackUriHelper]::ResolvePartUri($rel.SourceUri, $rel.TargetUri)
                        if (-not $pkg.PartExists($target)) { $errors.Add("Relationship $($rel.Id) ($($rel.RelationshipType)) points to missing part $target") }
                    }
                } finally { $pkg.Close() }
            } catch { $errors.Add("Cannot open package: $($_.Exception.Message)") }

            [pscustomobject]@{ Path = $file; Valid = ($errors.Count -eq 0); Errors = $errors.ToArray() }
        }
    }
}

function Compare-DwProject {
    <# .SYNOPSIS Part-by-part byte comparison of two .driveprojx files (Same / Different / Added / Removed). #>
    param(
        [Parameter(Mandatory, Position = 0)][string]$Reference,
        [Parameter(Mandatory, Position = 1)][string]$Difference
    )
    $read = {
        param($file)
        $map = @{}
        $pkg = Open-DwPackage $file
        try { foreach ($part in $pkg.GetParts()) { $map[$part.Uri.OriginalString] = Read-DwPartBytes $pkg $part.Uri } }
        finally { $pkg.Close() }
        $map
    }
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $hash = { param([byte[]]$bytes) [Convert]::ToBase64String($sha.ComputeHash($bytes)) }
    $ref = & $read $Reference
    $dif = & $read $Difference
    foreach ($uri in @($ref.Keys + $dif.Keys | Sort-Object -Unique)) {
        $status = if (-not $dif.ContainsKey($uri)) { 'Removed' }
                  elseif (-not $ref.ContainsKey($uri)) { 'Added' }
                  elseif ((& $hash $ref[$uri]) -eq (& $hash $dif[$uri])) { 'Same' }
                  else { 'Different' }
        $firstDiff = $null
        if ($status -eq 'Different') {
            $a = $ref[$uri]; $b = $dif[$uri]; $max = [Math]::Min($a.Length, $b.Length)
            for ($i = 0; $i -lt $max; $i++) { if ($a[$i] -ne $b[$i]) { $firstDiff = $i; break } }
            if ($null -eq $firstDiff) { $firstDiff = $max }
        }
        [pscustomobject]@{ Part = $uri; Status = $status; FirstDifferenceAt = $firstDiff }
    }
}

# =============================================================================
#  .driveprojx - write
# =============================================================================

function Edit-DwProject {
    <#
    .SYNOPSIS
        The one safe way to modify a project's XML. The script block gets a context object; call
        $p.GetXml('designMaster') (or 'project', 'components/2', ...) and change the XmlDocument in place.

        Steps: copy to temp -> run script block -> write only parts whose XML changed (keeping the
        original BOM and newline style) -> Test-DwProject on the result -> back up the original to
        backups\<timestamp>\ -> replace. Nothing touches the original if any step fails.
        Supports -WhatIf (reports which parts would change).
    .EXAMPLE
        Edit-DwProject '.\work\DW Ladder.driveprojx' {
            param($p)
            $c = $p.GetXml('designMaster').SelectSingleNode("/TDM/Constants/Constant[@DisplayName='ShortCornerOffset']")
            $c.SetAttribute('Value', '2.25')
        }
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, Position = 0)][string]$Path,
        [Parameter(Mandatory, Position = 1)][scriptblock]$ScriptBlock,
        [object[]]$ArgumentList = @(),
        [string]$OutPath,               # write the result here instead of replacing $Path
        [switch]$NoBackup,
        [switch]$ForceWrite             # rewrite every loaded part even if unchanged (round-trip testing)
    )
    $source = (Resolve-Path -LiteralPath $Path).Path
    if (-not $OutPath -and (Get-Item -LiteralPath $source).IsReadOnly) {
        throw "'$source' is read-only (checked in to PDM?). Check it out first, or write to a copy with -OutPath."
    }
    # Temp-copy housekeeping always runs, even under -WhatIf (the dry run needs the copy to diff against).
    $tempDir = Join-Path $env:TEMP 'DwTools'
    New-Item -ItemType Directory -Force -Path $tempDir -WhatIf:$false -Confirm:$false | Out-Null
    $temp = Join-Path $tempDir ([guid]::NewGuid().ToString() + '.driveprojx')
    Copy-Item -LiteralPath $source -Destination $temp -WhatIf:$false -Confirm:$false
    (Get-Item -LiteralPath $temp).IsReadOnly = $false

    try {
        $pkg = Open-DwPackage $temp -Write
        $ctx = [pscustomobject]@{ Path = $source; Package = $pkg; Parts = @{} }
        $ctx | Add-Member -MemberType ScriptMethod -Name GetXml -Value {
            param([string]$Part)
            $uri = Resolve-DwPartUri $Part
            $key = $uri.OriginalString
            if (-not $this.Parts.ContainsKey($key)) {
                $r = Read-DwPartXml $this.Package $uri
                $this.Parts[$key] = @{ Uri = $uri; Doc = $r.Xml; HasBom = $r.HasBom; NewLine = $r.NewLine; Original = $r.Xml.OuterXml }
            }
            $this.Parts[$key].Doc
        }
        $ctx | Add-Member -MemberType ScriptMethod -Name GetPartNames -Value {
            Get-DwXmlPart $this.Package | ForEach-Object { $_.Uri.OriginalString }
        }

        $changed = New-Object System.Collections.Generic.List[string]
        try {
            [void](& $ScriptBlock $ctx @ArgumentList)
            foreach ($p in $ctx.Parts.Values) {
                if ($ForceWrite -or $p.Doc.OuterXml -ne $p.Original) {
                    Write-DwPartBytes $pkg $p.Uri (ConvertTo-DwPartBytes $p.Doc $p.HasBom $p.NewLine)
                    $changed.Add($p.Uri.OriginalString)
                }
            }
        } finally { $pkg.Close() }

        $result = [pscustomobject]@{ Path = $source; OutPath = $null; ChangedParts = $changed.ToArray(); Backup = $null; Applied = $false }
        if ($changed.Count -eq 0) { Write-Verbose 'No changes.'; return $result }

        $check = Test-DwProject $temp
        if (-not $check.Valid) { throw "Edited project failed validation; original untouched:`n  " + ($check.Errors -join "`n  ") }

        $target = if ($OutPath) { Resolve-DwOutputPath $OutPath } else { $source }
        if ($PSCmdlet.ShouldProcess($target, "Write $($changed.Count) changed part(s): $($changed -join ', ')")) {
            if (-not $OutPath -and -not $NoBackup) { $result.Backup = Backup-DwFile $source }
            Copy-Item -LiteralPath $temp -Destination $target -Force -Confirm:$false
            $result.OutPath = $target
            $result.Applied = $true
        }
        $result
    } finally {
        Remove-Item -LiteralPath $temp -Force -ErrorAction SilentlyContinue -WhatIf:$false -Confirm:$false
    }
}

function Set-DwConstant {
    <#
    .SYNOPSIS  Sets the value (and optionally comment) of an existing constant.
    .EXAMPLE   Set-DwConstant '.\work\DW HandRails.driveprojx' ShortCornerOffset 2.25 -WhatIf
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, Position = 0)][string]$Path,
        [Parameter(Mandatory, Position = 1)][string]$Name,
        [Parameter(Mandatory, Position = 2)][AllowEmptyString()][string]$Value,
        [string]$Comment,
        [string]$OutPath,
        [switch]$NoBackup
    )
    Edit-DwProject -Path $Path -OutPath $OutPath -NoBackup:$NoBackup -WhatIf:$WhatIfPreference -ArgumentList $Name, $Value, $Comment -ScriptBlock {
        param($p, $name, $value, $comment)
        $node = $p.GetXml('designMaster').SelectNodes('/TDM/Constants/Constant') | Where-Object { $_.GetAttribute('DisplayName') -eq $name }
        if (-not $node) { throw "Constant '$name' not found. (Creating constants is not supported yet - use DriveWorks Administrator.)" }
        $node.SetAttribute('Value', $value)
        if ($comment) { $node.SetAttribute('Comment', $comment) }
    }
}

function Set-DwVariableRule {
    <#
    .SYNOPSIS  Replaces the rule of an existing variable. Use stored names in the rule (DWVariableX, DWConstantX).
               The rule is NOT syntax-checked - open the project in Administrator afterwards.
    .EXAMPLE   Set-DwVariableRule '.\work\DW Ladder.driveprojx' Client 'DWVariableTextBox1_Client' -WhatIf
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, Position = 0)][string]$Path,
        [Parameter(Mandatory, Position = 1)][string]$Name,
        [Parameter(Mandatory, Position = 2)][AllowEmptyString()][string]$Rule,
        [string]$OutPath,
        [switch]$NoBackup
    )
    Edit-DwProject -Path $Path -OutPath $OutPath -NoBackup:$NoBackup -WhatIf:$WhatIfPreference -ArgumentList $Name, $Rule -ScriptBlock {
        param($p, $name, $rule)
        $node = $p.GetXml('designMaster').SelectNodes('/TDM/Variables/Variable') | Where-Object { $_.GetAttribute('DisplayName') -eq $name }
        if (-not $node) { throw "Variable '$name' not found. (Creating variables is not supported yet - use DriveWorks Administrator.)" }
        $node.SetAttribute('Rule', $rule)
    }
}

function Set-DwControlProperty {
    <#
    .SYNOPSIS  Sets a form control property to a static -Value or a -Rule (a leading '=' is added if missing).
               Keeps IsStatic as-is and refuses a rule on an IsStatic=True property. Keeps an existing rule Comment.
    .EXAMPLE   Set-DwControlProperty $proj -Form Details -Control DevRelease -Property Visible -Rule 'DWVariableIsUserInDevelopement' -WhatIf
    .EXAMPLE   Set-DwControlProperty $proj -Form Details -Control DevRelease -Property Width -Value 150
    #>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Value')]
    param(
        [Parameter(Mandatory, Position = 0)][string]$Path,
        [Parameter(Mandatory)][string]$Form,
        [Parameter(Mandatory)][string]$Control,
        [Parameter(Mandatory)][ValidatePattern('^[A-Za-z][A-Za-z0-9]*$')][string]$Property,
        [Parameter(Mandatory, ParameterSetName = 'Value')][AllowEmptyString()][string]$Value,
        [Parameter(Mandatory, ParameterSetName = 'Rule')][string]$Rule,
        [string]$OutPath,
        [switch]$NoBackup
    )
    $isRule = $PSCmdlet.ParameterSetName -eq 'Rule'
    $text = if (-not $isRule) { $Value } elseif ($Rule.StartsWith('=')) { $Rule } else { '=' + $Rule }

    Edit-DwProject -Path $Path -OutPath $OutPath -NoBackup:$NoBackup -WhatIf:$WhatIfPreference -ArgumentList $Form, $Control, $Property, $isRule, $text -ScriptBlock {
        param($p, $form, $control, $property, $isRule, $text)
        $proj = $p.GetXml('project')
        $ctl = @(Select-DwXml $proj "/p:Project/p:Forms/f:Form[@Name=$(ConvertTo-DwXPathLiteral $form)]/f:Controls/*[@Name=$(ConvertTo-DwXPathLiteral $control)]")
        if ($ctl.Count -ne 1) { throw "Control '$control' not found on form '$form'." }
        $prop = @(Select-DwXml $ctl[0] "f:$property")
        if ($prop.Count -ne 1) {
            $available = ($ctl[0].ChildNodes | Where-Object { $_.NodeType -eq 'Element' } | ForEach-Object { $_.LocalName }) -join ', '
            throw "$($ctl[0].LocalName) '$control' has no property '$property'. Available: $available"
        }
        $prop = $prop[0]
        if ($isRule -and $prop.GetAttribute('IsStatic') -eq 'True') { throw "Property '$property' is IsStatic=True and cannot take a rule." }

        $comment = $null
        foreach ($child in @($prop.ChildNodes)) {
            if ($child.LocalName -eq 'Comment') { $comment = $child }
            [void]$prop.RemoveChild($child)
        }
        $new = $proj.CreateElement($(if ($isRule) { 'Rule' } else { 'Value' }), $prop.NamespaceURI)
        if ($text -ne '') { $new.InnerText = $text }        # empty stays <Value />, like DriveWorks writes it
        [void]$prop.AppendChild($new)
        if ($isRule -and $comment) { [void]$prop.AppendChild($comment) }
    }
}

function Set-DwComponentSetRule {
    <#
    .SYNOPSIS  Replaces a component set's file-name rule: the rule that names its top-level model, or returns "Delete".
               DriveWorks stores this rule twice, as ComponentSet/Rule in project.xml and as the root PC/CN/R in the
               set's components/<n>.xml. This updates both, and refuses if the two copies already differ.
               A leading '=' is added if missing. The rule is NOT syntax-checked - open the project in Administrator afterwards.
    .EXAMPLE   Set-DwComponentSetRule $proj 'DW10-A02-2 (DW10-A02)' 'If(DWVariableX, DWVariablePrefixMidSection2, "Delete")' -WhatIf
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, Position = 0)][string]$Path,
        [Parameter(Mandatory, Position = 1)][string]$ComponentSet,
        [Parameter(Mandatory, Position = 2)][string]$Rule,
        [string]$OutPath,
        [switch]$NoBackup
    )
    $text = if ($Rule.StartsWith('=')) { $Rule } else { '=' + $Rule }

    Edit-DwProject -Path $Path -OutPath $OutPath -NoBackup:$NoBackup -WhatIf:$WhatIfPreference -ArgumentList $ComponentSet, $text -ScriptBlock {
        param($p, $setName, $text)
        $proj = $p.GetXml('project')
        $cs = @(Select-DwXml $proj "/p:Project/p:ComponentSets/p:ComponentSet[@Name=$(ConvertTo-DwXPathLiteral $setName)]")
        if ($cs.Count -ne 1) { throw "Component set '$setName' not found." }
        $setRule = @(Select-DwXml $cs[0] 'p:Rule')
        if ($setRule.Count -ne 1) { throw "Component set '$setName' has no Rule element." }

        # the set's components/<n>.xml, via project.xml's relationship (ComponentSet/@RId)
        $projectUri = Resolve-DwPartUri 'project'
        $rel = $p.Package.GetPart($projectUri).GetRelationship($cs[0].GetAttribute('RId'))
        $partUri = [System.IO.Packaging.PackUriHelper]::ResolvePartUri($projectUri, $rel.TargetUri)
        $partRule = @(Select-DwXml $p.GetXml($partUri.OriginalString) '/pcomp:CS/pcomp:PC/pcomp:CN/pcomp:R')
        if ($partRule.Count -ne 1) { throw "$partUri has no root file-name rule (PC/CN/R)." }
        if ($setRule[0].InnerText -cne $partRule[0].InnerText) {
            throw "The two copies of the file-name rule of '$setName' already differ (project.xml vs $partUri). Resave the project in Administrator first."
        }
        $setRule[0].InnerText = $text
        $partRule[0].InnerText = $text
    }
}

# =============================================================================
#  .drivegroup (SQLite) - read-only
# =============================================================================

function Get-DwGroupFormat {
    <# .SYNOPSIS Identifies a .drivegroup file's storage: SQLite (current) or SqlCe40 (legacy SQL Server Compact 4.0). #>
    param([Parameter(Mandatory, Position = 0)][string]$Path)
    # Share read/write: the group is normally open in DriveWorks Administrator at the same time.
    $fs = [IO.File]::Open((Resolve-Path -LiteralPath $Path).Path, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::ReadWrite)
    try { $header = New-Object byte[] 20; [void]$fs.Read($header, 0, 20) } finally { $fs.Dispose() }
    if ([Text.Encoding]::ASCII.GetString($header, 0, 15) -eq 'SQLite format 3') { 'SQLite' }
    elseif ([BitConverter]::ToUInt32($header, 16) -eq 0x003D0900) { 'SqlCe40' }
    else { 'Unknown' }
}

function Invoke-DwGroupQuery {
    <#
    .SYNOPSIS  Runs a SQL query against a .drivegroup file, opened READ-ONLY, using DriveWorks' own SQLite DLL.
    .EXAMPLE   Invoke-DwGroupQuery '.\Sparta Manufacturing Group.drivegroup' 'SELECT Name, Deployed FROM Projects'
    #>
    param(
        [Parameter(Mandatory, Position = 0)][string]$Path,
        [Parameter(Mandatory, Position = 1)][string]$Sql
    )
    $format = Get-DwGroupFormat $Path
    if ($format -ne 'SQLite') { throw "'$Path' is a $format group, not SQLite. Only SQLite groups can be queried (legacy SQL CE groups: open/upgrade them in DriveWorks Administrator)." }
    Import-DwSQLite
    $builder = New-Object System.Data.SQLite.SQLiteConnectionStringBuilder
    $builder.DataSource = (Resolve-Path -LiteralPath $Path).Path
    $builder.ReadOnly = $true
    $builder.FailIfMissing = $true
    $cn = New-Object System.Data.SQLite.SQLiteConnection($builder.ConnectionString)
    $cn.Open()
    try {
        $table = New-Object System.Data.DataTable
        [void](New-Object System.Data.SQLite.SQLiteDataAdapter($Sql, $cn)).Fill($table)
        $columns = @($table.Columns | ForEach-Object { $_.ColumnName })
        foreach ($row in $table.Rows) {
            $o = [ordered]@{}
            foreach ($col in $columns) {
                $v = $row[$col]
                $o[$col] = if ($v -is [byte[]]) { "<blob $($v.Length) bytes>" } elseif ($v -is [DBNull]) { $null } else { $v }
            }
            [pscustomobject]$o
        }
    } finally { $cn.Close() }
}

function Get-DwGroupTable {
    <# .SYNOPSIS Lists the tables in a .drivegroup with row counts. #>
    param([Parameter(Mandatory, Position = 0)][string]$Path)
    foreach ($t in Invoke-DwGroupQuery $Path "SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name") {
        [pscustomobject]@{ Table = $t.name; Rows = (Invoke-DwGroupQuery $Path "SELECT COUNT(*) AS n FROM [$($t.name)]").n }
    }
}

function Get-DwCapturedComponent {
    <#
    .SYNOPSIS  Looks up captured models by id (a project component's CCRef, with or without dashes) or by path wildcard.
               Ids are stored as 16-byte blobs in .NET Guid byte order, so plain string comparison in SQL never matches.
    .EXAMPLE   Get-DwCapturedComponent $g -Id 48496ae0ee8c43278bee9715b584668e
    .EXAMPLE   Get-DwCapturedComponent $g -Path '*\Ladder\*'
    #>
    [CmdletBinding(DefaultParameterSetName = 'Id')]
    param(
        [Parameter(Mandatory, Position = 0)][string]$Group,
        [Parameter(Mandatory, ParameterSetName = 'Id')][string[]]$Id,
        [Parameter(Mandatory, ParameterSetName = 'Path')][string]$Path
    )
    $select = 'SELECT Id, Path, Type, Version FROM CapturedComponents'
    if ($PSCmdlet.ParameterSetName -eq 'Path') {
        $like = $Path.Replace("'", "''").Replace('*', '%').Replace('?', '_')
        return Invoke-DwGroupQuery $Group "$select WHERE Path LIKE '$like'"
    }
    $hex = foreach ($i in $Id) { "'" + [BitConverter]::ToString(([guid]$i).ToByteArray()).Replace('-', '') + "'" }
    Invoke-DwGroupQuery $Group "$select WHERE hex(Id) IN ($($hex -join ','))"
}

function Get-DwGroupProject {
    <# .SYNOPSIS Projects registered in a .drivegroup (name, directory, hidden/deployed flags). #>
    param([Parameter(Mandatory, Position = 0)][string]$Path)
    Invoke-DwGroupQuery $Path 'SELECT Name, Directory, Hidden, Deployed, Id FROM Projects ORDER BY Name'
}

Export-ModuleMember -Function @(
    'Get-DwInstallPath'
    'Expand-DwPackage'
    'Get-DwProjectPart', 'Get-DwProjectXml', 'Select-DwXml', 'Expand-DwProject', 'Get-DwProjectSummary'
    'Get-DwVariable', 'Get-DwConstant', 'Get-DwControl', 'Get-DwControlProperty', 'Get-DwModelRule', 'Get-DwRuleDependency', 'Find-DwUnusedVariable', 'Find-DwRule'
    'Test-DwProject', 'Compare-DwProject', 'Compare-DwProjectContent'
    'Edit-DwProject', 'Set-DwConstant', 'Set-DwVariableRule', 'Set-DwControlProperty', 'Set-DwComponentSetRule'
    'Get-DwGroupFormat', 'Invoke-DwGroupQuery', 'Get-DwGroupTable', 'Get-DwGroupProject', 'Get-DwCapturedComponent'
)
