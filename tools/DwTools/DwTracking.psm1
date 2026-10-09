#Requires -Version 5.1
<#
DwTracking: tracks re-exports of the production group into "DriveWorks Files" (Copy Group from SPA-DWP), the
changes made to the dev copy in between (tracking/ledger.jsonl, written by Edit-DwProject), and the issues and
fixes discussed (tracking/items.json), each with a behaviour check, so the next export review can tell what
production picked up, even when it was fixed with a different solution. See tracking/README.md.
#>

Set-StrictMode -Off
if (-not (Get-Command Compare-DwProjectContent -ErrorAction SilentlyContinue)) { Import-Module (Join-Path $PSScriptRoot 'DwTools.psm1') }

$script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$script:ExportRoot = Join-Path $script:RepoRoot 'DriveWorks Files'
$script:TrackDir = Join-Path $script:RepoRoot 'tracking'
$script:RegistryPath = Join-Path $script:TrackDir 'exports.json'
$script:ItemsPath = Join-Path $script:TrackDir 'items.json'
$script:LedgerPath = Join-Path $script:TrackDir 'ledger.jsonl'
$script:ReleasesPath = Join-Path $script:TrackDir 'releases.json'
$script:SnapshotDir = Join-Path $script:RepoRoot 'snapshots'
$script:Extensions = @('.driveprojx', '.drivegroup')
$script:DocsDir = Join-Path $script:RepoRoot 'docs'
# Project file (relative to DriveWorks Files) -> its folder under docs/projects/ (where issues.md is generated).
$script:ProjectFolders = [ordered]@{
    'Apron/DW Apron Project.driveprojx'                                  = @{ Folder = 'apron'; Name = 'DW Apron Project' }
    'Hopper/DW Hopper V2.driveprojx'                                     = @{ Folder = 'hopper-v2'; Name = 'DW Hopper V2' }
    'Hopper/DW Hopper V2 - Panels.driveprojx'                            = @{ Folder = 'hopper-v2-panels'; Name = 'DW Hopper V2 - Panels' }
    'Hopper/DW Hopper Project.driveprojx'                                = @{ Folder = 'hopper'; Name = 'DW Hopper Project (original)' }
    'Kit Conveyor/DW Kit Conveyor Project.driveprojx'                    = @{ Folder = 'kit-conveyor'; Name = 'DW Kit Conveyor Project' }
    'Light Duty Conveyor/Light Duty Conveyor.driveprojx'                 = @{ Folder = 'light-duty-conveyor'; Name = 'Light Duty Conveyor' }
    'Picking Conveyor/DW Picking Conveyor Project.driveprojx'            = @{ Folder = 'picking-conveyor'; Name = 'DW Picking Conveyor Project' }
    'Start Leg/DW Start Leg.driveprojx'                                  = @{ Folder = 'start-leg'; Name = 'DW Start Leg' }
    'Ladder/DW Ladder.driveprojx'                                        = @{ Folder = 'ladder'; Name = 'DW Ladder' }
    'Stairs/DW Stairs Project.driveprojx'                                = @{ Folder = 'stairs'; Name = 'DW Stairs Project' }
    'Platform/DW Platform Layout.driveprojx'                             = @{ Folder = 'platform-layout'; Name = 'DW Platform Layout' }
    'Platform/DW Platform Bolts.driveprojx'                              = @{ Folder = 'platform-layout'; Name = 'DW Platform Bolts' }
    'Platform/DW Platform - Straight.driveprojx'                         = @{ Folder = 'platform-straight'; Name = 'DW Platform - Straight' }
    'Platform/DW Platform - Picking.driveprojx'                          = @{ Folder = 'platform-picking'; Name = 'DW Platform - Picking' }
    'HandRails/DW HandRails.driveprojx'                                  = @{ Folder = 'handrails'; Name = 'DW HandRails' }
    'HandRails outside/DW HandRails outside.driveprojx'                  = @{ Folder = 'handrails-outside'; Name = 'DW HandRails outside' }
    'DW Order Project.driveprojx'                                        = @{ Folder = 'order'; Name = 'DW Order Project' }
    'DW Select Project.driveprojx'                                       = @{ Folder = 'select'; Name = 'DW Select Project' }
    'Sparta Website Configurator/Web Kit Conveyor/Web Kit Conveyor.driveprojx' = @{ Folder = 'web-kit-conveyor'; Name = 'Web Kit Conveyor' }
}

function ConvertTo-DwRel([string]$Full, [string]$Root) { $Full.Substring($Root.TrimEnd('\').Length + 1).Replace('\', '/') }

# Files may be open in DriveWorks Administrator (the group is SQLite): read with FileShare.ReadWrite.
function Get-DwSharedHash([string]$Path) {
    $fs = [IO.File]::Open($Path, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::ReadWrite -bor [IO.FileShare]::Delete)
    try { $sha = [Security.Cryptography.SHA256]::Create(); [BitConverter]::ToString($sha.ComputeHash($fs)).Replace('-', '') } finally { $fs.Dispose() }
}
function Copy-DwShared([string]$Source, [string]$Destination) {
    $in = [IO.File]::Open($Source, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::ReadWrite -bor [IO.FileShare]::Delete)
    try { $out = [IO.File]::Create($Destination); try { $in.CopyTo($out) } finally { $out.Dispose() } } finally { $in.Dispose() }
    (Get-Item -LiteralPath $Destination).LastWriteTimeUtc = (Get-Item -LiteralPath $Source).LastWriteTimeUtc
}

function Read-DwJson([string]$Path, $Default) {
    # PS 5.1: ConvertFrom-Json returns a JSON array as ONE object; unroll it so @(Read-DwJson ...) gets the elements.
    if (-not (Test-Path -LiteralPath $Path)) { return $Default }
    $o = ConvertFrom-Json -InputObject ([IO.File]::ReadAllText($Path))
    if ($o -is [array]) { foreach ($e in $o) { $e } } else { $o }
}

function Write-DwJson([string]$Path, $Object) {
    # -InputObject, not the pipeline: piping an array nested in @() serialises as {"value":[...],"Count":n} in PS 5.1.
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Path) | Out-Null
    [IO.File]::WriteAllText($Path, (ConvertTo-Json -InputObject $Object -Depth 12), (New-Object Text.UTF8Encoding($false)))
}

function Get-DwExportState {
    <#
    .SYNOPSIS  Every project and group file in DriveWorks Files, with size, modified time and (unless -Fast) SHA-256.
    #>
    param([string]$Root = $script:ExportRoot, [switch]$Fast)
    Get-ChildItem -LiteralPath $Root -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $script:Extensions -contains $_.Extension.ToLowerInvariant() } |
        ForEach-Object {
            [pscustomobject]@{
                Path     = ConvertTo-DwRel $_.FullName $Root
                Size     = $_.Length
                Modified = $_.LastWriteTimeUtc.ToString('o')
                Sha256   = $(if ($Fast) { $null } else { Get-DwSharedHash $_.FullName })
            }
        }
}

function Get-DwExport {
    <# .SYNOPSIS  Registered exports, oldest first (tracking/exports.json). -Latest returns the last one. #>
    param([switch]$Latest)
    $reg = Read-DwJson $script:RegistryPath $null
    if (-not $reg) { return }
    $all = @($reg.exports)
    if ($Latest) { $all[-1] } else { $all }
}

function Test-DwExportChanged {
    <#
    .SYNOPSIS  Compares DriveWorks Files with the latest registered export. Returns one row per added, removed or
               changed project/group file. -Fast compares size and modified time only (used by the hook).
    #>
    param([switch]$Fast)
    $last = Get-DwExport -Latest
    $now = @(Get-DwExportState -Fast:$Fast)
    if (-not $last) { return $now | ForEach-Object { [pscustomobject]@{ Path = $_.Path; Change = 'Unregistered'; Detail = 'no export registered yet' } } }
    $known = @{}; foreach ($p in $last.files.PSObject.Properties) { $known[$p.Name] = $p.Value }
    $seen = @{}
    foreach ($f in $now) {
        $seen[$f.Path] = 1
        $k = $known[$f.Path]
        if (-not $k) { [pscustomobject]@{ Path = $f.Path; Change = 'Added'; Detail = '' }; continue }
        $same = if ($Fast) { ($k.size -eq $f.Size) -and ($k.modified -eq $f.Modified) } else { $k.sha256 -eq $f.Sha256 }
        if (-not $same) { [pscustomobject]@{ Path = $f.Path; Change = 'Changed'; Detail = "size $($k.size) -> $($f.Size), modified $($k.modified) -> $($f.Modified)" } }
    }
    foreach ($p in $known.Keys) { if (-not $seen.ContainsKey($p)) { [pscustomobject]@{ Path = $p; Change = 'Removed'; Detail = '' } } }
}

function Register-DwExport {
    <#
    .SYNOPSIS  Records the current DriveWorks Files as an export: hashes in tracking/exports.json and a copy of every
               project/group file in snapshots/<Id>/ (git-ignored), so the next export can be diffed against it.
               Run it after reviewing a new export (Invoke-DwExportReview).
    .EXAMPLE   Register-DwExport -Id 2026-10-05 -Note 'Copy Group from SPA-DWP' -Review tracking/reviews/2026-10-05.md
    #>
    param(
        [string]$Id = (Get-Date -Format 'yyyy-MM-dd'),
        [string]$Note = '',
        [string]$Source = 'Copy Group from SPA-DWP (DriveWorks Data Management)',
        [string]$Review = ''
    )
    $reg = Read-DwJson $script:RegistryPath $null
    if (-not $reg) { $reg = [pscustomobject]@{ root = 'DriveWorks Files'; exports = @() } }
    if (@($reg.exports | Where-Object { $_.id -eq $Id }).Count) { throw "Export '$Id' is already registered. Use another -Id." }
    $snap = Join-Path $script:SnapshotDir $Id
    $files = [ordered]@{}
    foreach ($f in Get-DwExportState) {
        $dest = Join-Path $snap ($f.Path.Replace('/', '\'))
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dest) | Out-Null
        Copy-DwShared (Join-Path $script:ExportRoot ($f.Path.Replace('/', '\'))) $dest
        if ((Get-DwSharedHash $dest) -ne $f.Sha256) { throw "'$($f.Path)' changed while it was being copied (open in Administrator?). Close it and register again." }
        $files[$f.Path] = [ordered]@{ size = $f.Size; modified = $f.Modified; sha256 = $f.Sha256; snapshot = $f.Path }
    }
    $entry = [ordered]@{
        id = $Id; registered = (Get-Date).ToString('yyyy-MM-ddTHH:mm:sszzz'); source = $Source; note = $Note
        snapshot = "snapshots/$Id"; review = $Review; files = $files
    }
    $reg.exports = @($reg.exports) + @([pscustomobject]$entry)
    Write-DwJson $script:RegistryPath $reg
    [pscustomobject]@{ Id = $Id; Files = $files.Count; Snapshot = $snap }
}

function Register-DwRelease {
    <#
    .SYNOPSIS  Records a dev -> prod Copy Group (run by the user) in tracking/releases.json: when it ran, which is the
               rollback point (restore production from an archive taken before -Started), the configuration file the
               user saved, what it copied, and the SHA-256 of each project file as pushed. Run it right after the
               Copy Group, before any new dev edit: the hashes are read from DriveWorks Files.
    .EXAMPLE   Register-DwRelease -Id 2026-10-09 -Started 2026-10-09T13:03:27-03:00 -Finished 2026-10-09T13:11:44-03:00 -Config 'Copy Group Specification\2026-10-09 - Copy Group Specification.xml' -ProdBefore 2026-10-06 -Note '...'
    #>
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$Started,
        [string]$Finished = '',
        [Parameter(Mandatory)][string]$Config,
        [string]$ProdBefore = '',
        [string]$Note = '',
        [string[]]$Items = @()
    )
    $releases = @(Read-DwJson $script:ReleasesPath @())
    if ($releases | Where-Object { $_.id -eq $Id }) { throw "Release '$Id' is already registered." }
    $cfgPath = if ([IO.Path]::IsPathRooted($Config)) { $Config } else { Join-Path $script:RepoRoot $Config }
    $x = [xml][IO.File]::ReadAllText($cfgPath)
    $c = $x.Configuration
    $source = $c.AdditionalOptions.SourceFolder.Path.TrimEnd('\')
    $files = [ordered]@{}
    foreach ($inc in @($c.Files.IncludedFile)) {
        $p = $inc.Path
        $rel = if ($p.StartsWith($source, [StringComparison]::OrdinalIgnoreCase)) { $p.Substring($source.Length + 1).Replace('\', '/') } else { $p }
        $files[$rel] = $(if (Test-Path -LiteralPath $p) { Get-DwSharedHash $p } else { $null })
    }
    $options = [ordered]@{}
    foreach ($o in $c.AdditionalOptions.ChildNodes) { if ($o.HasAttribute('Value')) { $options[$o.LocalName] = $o.GetAttribute('Value') } }
    $entry = [ordered]@{
        id = $Id; direction = 'dev -> prod'; started = $Started; finished = $Finished
        registered = (Get-Date).ToString('yyyy-MM-ddTHH:mm:sszzz')
        config = ConvertTo-DwRel $cfgPath $script:RepoRoot
        source = $c.AdditionalOptions.SourceFolder.Path; target = $c.AdditionalOptions.TargetFolder.Path
        projects = @($c.Projects.Project | ForEach-Object { $_.Name })
        ruleHistory = @($c.Projects.Project | Where-Object { $_.RuleHistoryIncluded -eq 'true' }).Count -gt 0
        components = $(if ($c.Components.AutoSelectFromProjects -eq 'true') { 'all components of the selected projects (auto)' } else { "$($c.SelectNodes('Components/*').Count) chosen" })
        groupTables = @($c.SelectNodes('GroupTables/GroupTable') | ForEach-Object { $_.GetAttribute('Name') })
        options = $options; prodBefore = $ProdBefore; items = @($Items); note = $Note; files = $files
    }
    Write-DwJson $script:ReleasesPath (@($releases) + @([pscustomobject]$entry))
    [pscustomobject]@{ Id = $Id; Started = $Started; Projects = $entry.projects.Count; Files = $files.Count }
}

function Get-DwRelease {
    <# .SYNOPSIS  Registered dev -> prod releases, oldest first (tracking/releases.json). -Latest returns the last one. #>
    param([switch]$Latest)
    $r = @(Read-DwJson $script:ReleasesPath @())
    if ($Latest) { $r | Select-Object -Last 1 } else { $r }
}
function Get-DwLedger {
    <# .SYNOPSIS  Changes logged by Edit-DwProject to projects in DriveWorks Files. -Since filters by time. #>
    param([datetime]$Since = [datetime]::MinValue, [string]$Item)
    if (-not (Test-Path -LiteralPath $script:LedgerPath)) { return }
    foreach ($line in [IO.File]::ReadAllLines($script:LedgerPath)) {
        if (-not $line.Trim()) { continue }
        $e = $line | ConvertFrom-Json
        if ([datetime]$e.time -lt $Since) { continue }
        if ($Item -and $e.item -ne $Item) { continue }
        $e
    }
}

function Add-DwLedgerNote {
    <#
    .SYNOPSIS  Records a change made outside the DwTools writers (a file deleted or edited by hand, in Explorer or in
               Administrator) in the ledger, so the export hook stops reporting it. -Path is relative to DriveWorks Files.
    .EXAMPLE   Add-DwLedgerNote -Path 'Sparta Manufacturing Group Single.drivegroup' -Change Removed -Reason 'Old 2022 SQL CE group, deleted by the user'
    #>
    param([Parameter(Mandatory)][string]$Path, [Parameter(Mandatory)][ValidateSet('Removed', 'Changed', 'Added')][string]$Change, [Parameter(Mandatory)][string]$Reason, [string]$Item)
    $rel = $Path.Replace('\', '/')
    $full = Join-Path $script:ExportRoot ($rel.Replace('/', '\'))
    $entry = [ordered]@{
        time = (Get-Date).ToString('yyyy-MM-ddTHH:mm:sszzz'); project = $rel; parts = @(); item = $Item; reason = $Reason; user = $env:USERNAME
        backup = $null; changes = @(); manual = $Change
        sha256After = $(if ($Change -ne 'Removed' -and (Test-Path -LiteralPath $full)) { Get-DwSharedHash $full } else { $null })
        removed = ($Change -eq 'Removed')
    }
    [IO.File]::AppendAllText($script:LedgerPath, ([pscustomobject]$entry | ConvertTo-Json -Depth 4 -Compress) + "`n", (New-Object Text.UTF8Encoding($false)))
}

function Get-DwTrackingItem {
    <# .SYNOPSIS  Tracked issues and fixes (tracking/items.json). -Open hides verified/closed ones. #>
    param([string]$Id, [switch]$Open)
    $items = @(Read-DwJson $script:ItemsPath @())
    if ($Id) { $items = @($items | Where-Object { $_.id -eq $Id }) }
    if ($Open) { $items = @($items | Where-Object { $_.status -notin 'verified', 'closed' }) }
    $items
}

function Test-DwTrackingItem {
    <#
    .SYNOPSIS  Runs the behaviour check of tracked items against the current DriveWorks Files (or -Project/-Group).
               A check returns Pass = the problem is gone, whatever the solution. Items without a check are Manual.
    .EXAMPLE   Test-DwTrackingItem | Format-Table Id, Status, Result, Detail -Wrap
    #>
    param([string[]]$Id, [switch]$All)
    $group = Join-Path $script:ExportRoot 'Sparta DW Group for Claude.drivegroup'
    $items = if ($All) { Get-DwTrackingItem } else { Get-DwTrackingItem -Open }
    if ($Id) { $items = @($items | Where-Object { $Id -contains $_.id }) }
    foreach ($it in $items) {
        $result = 'Manual'; $detail = ''
        if ($it.check) {
            $project = Join-Path $script:ExportRoot ($it.project.Replace('/', '\'))
            try {
                $r = & (Join-Path $script:TrackDir $it.check) -Project $project -Group $group
                $result = if ($r.Pass) { 'Pass' } else { 'Fail' }
                $detail = $r.Detail
            } catch { $result = 'Error'; $detail = $_.Exception.Message }
        }
        [pscustomobject]@{ Id = $it.id; Project = $it.project; Status = $it.status; Result = $result; Detail = $detail; Title = $it.title }
    }
}

function Set-DwTrackingItemStatus {
    <# .SYNOPSIS  Updates an item's status and appends a dated history note. #>
    param([Parameter(Mandatory)][string]$Id, [Parameter(Mandatory)][ValidateSet('open', 'recommended', 'fixed-in-dev', 'verified', 'closed')][string]$Status, [string]$Note = '', [string]$Export = '')
    $items = @(Read-DwJson $script:ItemsPath @())
    $it = $items | Where-Object { $_.id -eq $Id }
    if (-not $it) { throw "No item '$Id'." }
    $it.status = $Status
    $it.history = @($it.history) + @([pscustomobject]@{ date = (Get-Date -Format 'yyyy-MM-dd'); status = $Status; export = $Export; note = $Note })
    Write-DwJson $script:ItemsPath $items
    Update-DwIssueDocs | Out-Null
}

function Add-DwTrackingItem {
    <#
    .SYNOPSIS  Logs a new issue in tracking/items.json and regenerates the issues.md files.
               -Project is the file relative to DriveWorks Files (e.g. 'Hopper/DW Hopper V2.driveprojx').
               -CrossProject lists it in docs/issues.md instead of one project's file (it still needs a -Project
               for its check to locate the export). -Check is a script under tracking/checks/ (optional).
    .EXAMPLE   Add-DwTrackingItem -Id hopper-v2-x -Project 'Hopper/DW Hopper V2.driveprojx' -Title '...' -Notes '...'
    #>
    param(
        [Parameter(Mandatory)][ValidatePattern('^[a-z0-9-]+$')][string]$Id,
        [Parameter(Mandatory)][string]$Project,
        [Parameter(Mandatory)][string]$Title,
        [ValidateSet('open', 'recommended', 'fixed-in-dev', 'verified', 'closed')][string]$Status = 'open',
        [ValidateSet('high', 'medium', 'low')][string]$Priority = 'medium',
        [string]$Notes = '',
        [string]$Check = '',
        [string]$Raised = (Get-Date -Format 'yyyy-MM-dd'),
        [switch]$CrossProject,
        [switch]$NoDocs
    )
    $items = @(Read-DwJson $script:ItemsPath @())
    if ($items | Where-Object { $_.id -eq $Id }) { throw "Item '$Id' already exists. Use Set-DwTrackingItemStatus." }
    if (-not $script:ProjectFolders.Contains($Project)) { throw "Unknown project '$Project'. Known: $($script:ProjectFolders.Keys -join ', ')" }
    if ($Check -and -not (Test-Path -LiteralPath (Join-Path $script:TrackDir $Check))) { throw "Check '$Check' not found under tracking/." }
    $item = [ordered]@{ id = $Id; project = $Project; title = $Title; status = $Status; priority = $Priority; raised = $Raised; check = $Check; notes = $Notes; history = @() }
    if ($CrossProject) { $item.crossProject = $true }
    $items += [pscustomobject]$item
    Write-DwJson $script:ItemsPath $items
    if (-not $NoDocs) { Update-DwIssueDocs | Out-Null }
}

function Update-DwIssueDocs {
    <#
    .SYNOPSIS  Writes docs/projects/<project>/issues.md for every project, and the index docs/issues.md, from
               tracking/items.json. The issues.md files are generated: edit items with Add-DwTrackingItem and
               Set-DwTrackingItemStatus (which call this), never by hand.
    #>
    $items = @(Read-DwJson $script:ItemsPath @())
    $order = @{ open = 0; recommended = 1; 'fixed-in-dev' = 2; verified = 3; closed = 4 }
    $prio = @{ high = 0; medium = 1; low = 2 }
    $sorted = { param($list) @($list | Sort-Object @{ e = { $order[$_.status] } }, @{ e = { $prio[$_.priority] } }, id) }
    $esc = { param($s) "$s" -replace '\|', '\|' -replace '\r?\n', ' ' }
    $legend = 'Statuses: **open** (a problem, not fixed anywhere), **recommended** (a fix proposed), **fixed-in-dev** (applied in `DriveWorks Files`, waiting for production), **verified** (the check passes on a production export), **closed** (dropped).'
    $written = @()

    $section = {
        param($it, $up)
        $L = New-Object System.Collections.Generic.List[string]
        $L.Add("### $($it.id)"); $L.Add('')
        $L.Add("**$(& $esc $it.title)**"); $L.Add('')
        $chk = if ($it.check) { "[$($it.check)]($up/tracking/$($it.check))" } else { 'none (checked by hand)' }
        $L.Add("- **Status:** $($it.status); **Priority:** $($it.priority); **Raised:** $($it.raised)")
        $L.Add("- **Check:** $chk")
        if ($it.notes) { $L.Add("- **Notes:** $(& $esc $it.notes)") }
        $h = @($it.history | Where-Object { $_ })
        if ($h.Count) {
            $L.Add('- **History:**')
            foreach ($e in $h) { $L.Add("  - $($e.date): $($e.status)$(if ($e.export) { " (export $($e.export))" })$(if ($e.note) { ". $(& $esc $e.note)" })") }
        }
        $L.Add('')
        $L
    }

    $byFolder = [ordered]@{}
    foreach ($k in $script:ProjectFolders.Keys) { $f = $script:ProjectFolders[$k].Folder; if (-not $byFolder.Contains($f)) { $byFolder[$f] = @{ Names = New-Object System.Collections.Generic.List[string]; Items = @() } }; $byFolder[$f].Names.Add($script:ProjectFolders[$k].Name) }
    foreach ($it in $items) {
        if ($it.crossProject) { continue }
        $m = $script:ProjectFolders[$it.project]; if (-not $m) { continue }
        $byFolder[$m.Folder].Items += $it
    }

    foreach ($folder in $byFolder.Keys) {
        $entry = $byFolder[$folder]
        $list = & $sorted $entry.Items
        $L = New-Object System.Collections.Generic.List[string]
        $L.Add("# $($entry.Names -join ' and '): issues"); $L.Add('')
        $L.Add('*Generated from [tracking/items.json](../../../tracking/items.json) by `Update-DwIssueDocs`. Do not edit by hand: log an issue with `Add-DwTrackingItem` and change it with `Set-DwTrackingItemStatus` (see [tracking/README.md](../../../tracking/README.md)).*'); $L.Add('')
        $L.Add("Known issues of this project, open ones first. Findings and context are in [learnings.md](learnings.md); cross-project issues are in [docs/issues.md](../../issues.md)."); $L.Add('')
        $L.Add($legend); $L.Add('')
        if (-not $list.Count) { $L.Add('No issues logged yet.') }
        else {
            $L.Add('| Issue | Status | Priority | Check |'); $L.Add('|---|---|---|---|')
            foreach ($it in $list) { $L.Add("| [$($it.id)](#$($it.id)) $(& $esc $it.title) | $($it.status) | $($it.priority) | $(if ($it.check) { 'yes' } else { 'by hand' }) |") }
            $L.Add('')
            foreach ($it in $list) { foreach ($x in (& $section $it '../../..')) { $L.Add($x) } }
        }
        $path = Join-Path $script:DocsDir "projects\$folder\issues.md"
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $path) | Out-Null
        [IO.File]::WriteAllText($path, (($L -join "`n").TrimEnd() + "`n"), (New-Object Text.UTF8Encoding($false)))
        $written += $path
    }

    # Index: counts per project, then the cross-project issues in full.
    $L = New-Object System.Collections.Generic.List[string]
    $L.Add('# Issues'); $L.Add('')
    $L.Add('*Generated from [tracking/items.json](../tracking/items.json) by `Update-DwIssueDocs`. Do not edit by hand.*'); $L.Add('')
    $L.Add("Every project's known issues are in its own ``docs/projects/<project>/issues.md``. This page counts them and lists the issues that span several projects."); $L.Add('')
    $L.Add($legend); $L.Add('')
    $L.Add('| Project | open | recommended | fixed-in-dev | verified | closed |'); $L.Add('|---|---|---|---|---|---|')
    foreach ($folder in $byFolder.Keys) {
        $c = @{}; foreach ($s in $order.Keys) { $c[$s] = @($byFolder[$folder].Items | Where-Object { $_.status -eq $s }).Count }
        $L.Add("| [$($byFolder[$folder].Names -join ', ')](projects/$folder/issues.md) | $($c.open) | $($c.recommended) | $($c.'fixed-in-dev') | $($c.verified) | $($c.closed) |")
    }
    $L.Add('')
    $L.Add('## Cross-project issues'); $L.Add('')
    $cross = & $sorted @($items | Where-Object { $_.crossProject })
    if (-not $cross.Count) { $L.Add('None logged yet.') } else { foreach ($it in $cross) { foreach ($x in (& $section $it '..')) { $L.Add($x) } } }
    $path = Join-Path $script:DocsDir 'issues.md'
    [IO.File]::WriteAllText($path, (($L -join "`n").TrimEnd() + "`n"), (New-Object Text.UTF8Encoding($false)))
    $written += $path
    $written
}

function Compare-DwGroupContent {
    <#
    .SYNOPSIS  What changed in a group between two .drivegroup files: table row counts, registered projects, captured
               models (added, removed, really re-captured), group data tables and settings. Security tables are
               compared by row count only.
    #>
    param([Parameter(Mandatory, Position = 0)][string]$Reference, [Parameter(Mandatory, Position = 1)][string]$Difference)
    $out = New-Object System.Collections.Generic.List[object]
    $add = { param($area, $change, $item, $detail) $out.Add([pscustomobject]@{ Area = $area; Change = $change; Item = $item; Detail = $detail }) }
    $to = @{}; Get-DwGroupTable $Reference | ForEach-Object { $to[$_.Table] = $_.Rows }
    $tn = @{}; Get-DwGroupTable $Difference | ForEach-Object { $tn[$_.Table] = $_.Rows }
    foreach ($t in (@($to.Keys) + @($tn.Keys) | Sort-Object -Unique)) { if ($to[$t] -ne $tn[$t]) { & $add 'Table rows' 'Changed' $t "$($to[$t]) -> $($tn[$t])" } }
    # Paths relative to the group content folder, wherever the group was exported to (DriveWorks Files, a package temp folder...).
    $contentA = [string](@(Invoke-DwGroupQuery $Reference "SELECT Value FROM GroupSettings WHERE Name='GroupContentFolder'")[0].Value)
    $contentB = [string](@(Invoke-DwGroupQuery $Difference "SELECT Value FROM GroupSettings WHERE Name='GroupContentFolder'")[0].Value)
    $rel = { param($p) $p = [string]$p; foreach ($m in @($contentA, $contentB, '\DriveWorks Files') | Where-Object { $_ }) { $i = $p.IndexOf($m, [StringComparison]::OrdinalIgnoreCase); if ($i -ge 0) { return $p.Substring($i + $m.Length).TrimStart('\') } }; $p }
    $po = @{}; Get-DwGroupProject $Reference | ForEach-Object { $po[$_.Name] = $_ }
    $pn = @{}; Get-DwGroupProject $Difference | ForEach-Object { $pn[$_.Name] = $_ }
    foreach ($n in (@($po.Keys) + @($pn.Keys) | Sort-Object -Unique)) {
        if (-not $po[$n]) { & $add 'Project' 'Added' $n ''; continue }
        if (-not $pn[$n]) { & $add 'Project' 'Removed' $n ''; continue }
        $a = $po[$n]; $b = $pn[$n]
        if ($a.Hidden -ne $b.Hidden -or $a.Deployed -ne $b.Deployed) { & $add 'Project' 'Changed' $n "hidden $($a.Hidden)->$($b.Hidden), deployed $($a.Deployed)->$($b.Deployed)" }
        if ((& $rel $a.Directory) -ne (& $rel $b.Directory)) { & $add 'Project' 'Moved' $n "$(& $rel $a.Directory) -> $(& $rel $b.Directory)" }
    }
    # Captures. Copy Group re-serialises every capture (+27 bytes, Version +1), so only other size or child changes count.
    $q = 'SELECT hex(Id) AS Id, Path, length(Data) AS Len, length(ReferenceData) AS RLen FROM CapturedComponents'
    $ca = @{}; Invoke-DwGroupQuery $Reference $q | ForEach-Object { $ca[$_.Id] = $_ }
    $cb = @{}; Invoke-DwGroupQuery $Difference $q | ForEach-Object { $cb[$_.Id] = $_ }
    $deltas = @($cb.Keys | Where-Object { $ca.ContainsKey($_) } | ForEach-Object { $cb[$_].Len - $ca[$_].Len } | Group-Object | Sort-Object Count -Descending)
    $common = if ($deltas.Count) { [int]$deltas[0].Name } else { 0 }
    foreach ($k in $cb.Keys) {
        if (-not $ca.ContainsKey($k)) { & $add 'Capture' 'Added' (& $rel $cb[$k].Path) ''; continue }
        $d = $cb[$k].Len - $ca[$k].Len
        if ($d -ne $common -or $cb[$k].RLen -ne $ca[$k].RLen) { & $add 'Capture' 'Re-captured' (& $rel $cb[$k].Path) "data $d bytes (common shift $common), child refs $($ca[$k].RLen / 16)->$($cb[$k].RLen / 16)" }
    }
    foreach ($k in $ca.Keys) { if (-not $cb.ContainsKey($k)) { & $add 'Capture' 'Removed' (& $rel $ca[$k].Path) '' } }
    $qt = 'SELECT Name, hex(TableData) AS H FROM GroupDataTables'
    $da = @{}; Invoke-DwGroupQuery $Reference $qt | ForEach-Object { $da[$_.Name] = $_.H }
    foreach ($r in Invoke-DwGroupQuery $Difference $qt) {
        if (-not $da.ContainsKey($r.Name)) { & $add 'Group table' 'Added' $r.Name '' }
        elseif ($da[$r.Name] -ne $r.H) {
            $rows = { param($h) $bytes = New-Object byte[] ($h.Length / 2); for ($i = 0; $i -lt $bytes.Length; $i++) { $bytes[$i] = [Convert]::ToByte($h.Substring(2 * $i, 2), 16) }; $ds = New-Object IO.Compression.DeflateStream((New-Object IO.MemoryStream(, $bytes)), [IO.Compression.CompressionMode]::Decompress); @((New-Object IO.StreamReader($ds)).ReadToEnd() -replace "`r", '' -split "`n" | Where-Object { $_ }) }
            $ra = & $rows $da[$r.Name]; $rb = & $rows $r.H
            & $add 'Group table' 'Changed' $r.Name ("rows $($ra.Count - 1) -> $($rb.Count - 1): +$(@($rb | Where-Object { $ra -notcontains $_ }).Count) -$(@($ra | Where-Object { $rb -notcontains $_ }).Count)")
        }
    }
    foreach ($t in 'GroupSettings', 'GroupProperties') {
        $a = @{}; Invoke-DwGroupQuery $Reference "SELECT * FROM $t" | ForEach-Object { $a[$_.Name] = [string]$_.Value }
        foreach ($r in Invoke-DwGroupQuery $Difference "SELECT * FROM $t") { if ($a[$r.Name] -ne [string]$r.Value) { & $add $t 'Changed' $r.Name "$($a[$r.Name]) -> $($r.Value)" } }
    }
    $out
}

function Invoke-DwExportReview {
    <#
    .SYNOPSIS  Reviews DriveWorks Files against the latest registered export after a re-export:
               changed files, a semantic diff per project, the group diff, the dev changes logged since then
               (overwritten by the export) and every open tracked item's check. Writes the facts to
               tracking/reviews/<date>.md and full diffs to work/export-review-<date>/. Then add the summary by
               hand, update item statuses, and Register-DwExport.
    #>
    param([string]$Id = (Get-Date -Format 'yyyy-MM-dd'), [switch]$NoChecks)
    $last = Get-DwExport -Latest
    if (-not $last) { throw 'No export registered yet. Register-DwExport first.' }
    $snap = Join-Path $script:RepoRoot ($last.snapshot.Replace('/', '\'))
    $group = Join-Path $script:ExportRoot 'Sparta DW Group for Claude.drivegroup'
    $workDir = Join-Path $script:RepoRoot "work\export-review-$Id"
    New-Item -ItemType Directory -Force -Path $workDir | Out-Null
    $changes = @(Test-DwExportChanged)
    $sb = New-Object System.Text.StringBuilder
    $w = { param($s) [void]$sb.AppendLine($s) }
    & $w "# Export review $Id"
    & $w ''
    & $w "Compared with export **$($last.id)** (registered $($last.registered)). Generated by ``Invoke-DwExportReview``; full diffs in ``work/export-review-$Id/``."
    & $w ''
    & $w '## Summary'
    & $w ''
    & $w '*(to write: what changed, what was fixed, what to check)*'
    & $w ''
    & $w '## Files'
    & $w ''
    if (-not $changes.Count) { & $w 'No project or group file changed.' }
    else { & $w '| File | Change |'; & $w '|---|---|'; foreach ($c in $changes) { & $w "| $($c.Path) | $($c.Change) |" } }
    foreach ($c in $changes | Where-Object { $_.Change -eq 'Changed' }) {
        $k = $last.files.($c.Path)
        $old = Join-Path $snap ($k.snapshot.Replace('/', '\'))
        $new = Join-Path $script:ExportRoot ($c.Path.Replace('/', '\'))
        & $w ''
        & $w "## $($c.Path)"
        & $w ''
        if ($c.Path -like '*.driveprojx') {
            $d = @(Compare-DwProjectContent $old $new -Group $group)
            $d | Select-Object Area, Change, Item, @{ n = 'Old'; e = { ([string]$_.Old -replace '\s+', ' ') } }, @{ n = 'New'; e = { ([string]$_.New -replace '\s+', ' ') } }, Evidence |
                Export-Csv -LiteralPath (Join-Path $workDir (($c.Path -replace '[\\/]', '_') + '.csv')) -NoTypeInformation -Encoding UTF8
            & $w "$($d.Count) items."
            & $w ''
            & $w '| Area | Change | Count |'; & $w '|---|---|---|'
            foreach ($gq in ($d | Group-Object Area, Change | Sort-Object Count -Descending)) { $p = $gq.Name -split ', '; & $w "| $($p[0]) | $($p[1]) | $($gq.Count) |" }
            $ren = @($d | Where-Object Change -eq 'Renamed')
            if ($ren.Count) { & $w ''; & $w 'Renamed:'; foreach ($r in $ren) { & $w "- $($r.Area): ``$($r.Old)`` -> ``$($r.New)``" } }
        } elseif ($c.Path -like '*.drivegroup') {
            $d = @(Compare-DwGroupContent $old $new)
            $d | Export-Csv -LiteralPath (Join-Path $workDir (($c.Path -replace '[\\/]', '_') + '.csv')) -NoTypeInformation -Encoding UTF8
            & $w '| Area | Change | Count | Examples |'; & $w '|---|---|---|---|'
            foreach ($gq in ($d | Group-Object Area, Change)) { $p = $gq.Name -split ', '; & $w "| $($p[0]) | $($p[1]) | $($gq.Count) | $((@($gq.Group | Select-Object -First 4 | ForEach-Object { $_.Item + $(if ($_.Detail) { " ($($_.Detail))" } else { '' }) }) -join '; ') -replace '\|', '/') |" }
        }
    }
    & $w ''
    & $w '## Dev changes since the last export'
    & $w ''
    $since = [datetime]$last.registered
    $led = @(Get-DwLedger -Since $since)
    if (-not $led.Count) { & $w 'None logged.' }
    else { & $w '| Time | Project | Item | Reason | Changes |'; & $w '|---|---|---|---|---|'; foreach ($e in $led) { & $w "| $($e.time) | $($e.project) | $($e.item) | $($e.reason) | $(@($e.changes).Count) |" } }
    & $w ''
    & $w '## Tracked items'
    & $w ''
    if ($NoChecks) { & $w '(checks skipped)' }
    else {
        & $w '| Item | Status before | Check | Detail |'; & $w '|---|---|---|---|'
        foreach ($r in Test-DwTrackingItem) { & $w "| $($r.Id) | $($r.Status) | **$($r.Result)** | $(([string]$r.Detail) -replace '\|', '/') |" }
    }
    $path = Join-Path $script:TrackDir "reviews\$Id.md"
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $path) | Out-Null
    [IO.File]::WriteAllText($path, $sb.ToString(), (New-Object Text.UTF8Encoding($false)))
    [pscustomobject]@{ Review = $path; ChangedFiles = $changes.Count; Diffs = $workDir }
}

Export-ModuleMember -Function Get-DwExportState, Get-DwExport, Test-DwExportChanged, Register-DwExport, Register-DwRelease, Get-DwRelease, Get-DwLedger, Add-DwLedgerNote, Get-DwTrackingItem, Test-DwTrackingItem, Set-DwTrackingItemStatus, Add-DwTrackingItem, Update-DwIssueDocs, Compare-DwGroupContent, Invoke-DwExportReview
