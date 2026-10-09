# Tools

PowerShell tooling for inspecting and safely modifying DriveWorks files. It targets **Windows PowerShell 5.1**, with no installs: it uses .NET Framework's `System.IO.Packaging` plus DriveWorks' own SQLite DLL.

```
tools/
  DwTools/DwTools.psm1           module: all the functions below
  DwTools/DwFormEngine.psm1      form evaluator and renderer on DriveWorks' own rule engine (see "Run a form")
  DwTools/DwTracking.psm1        export registry, change ledger, tracked items, export review (see "Exports and tracking")
  DwTools/DwSpa.psm1             .spa files (what SOLIDWORKS built), the SPA files inbox, DriveWorks' generation log, and checks against the rules (see "What was built")
  DwTools/DwSimulate.psm1        every model rule evaluated offline: what DriveWorks will send to SOLIDWORKS (see "What DriveWorks will send")
  DwTools/DwApi.psm1             real specifications in the sandbox through the DriveWorks API (see "Run a real specification")
  scripts/Test-DwExportChanged.ps1  fast "did DriveWorks Files change since the last export?" (the Claude Code hook)
  scripts/Update-DwInventory.ps1 regenerates docs/inventory.md
  scripts/Set-ApronMidSectionFileNameRule.ps1  Apron: 19 mid-section file-name rules -> SectionLayout Enable
  tests/Test-DwRoundTrip.ps1     proves read/write is lossless (run after any DriveWorks upgrade)
```

## Load

```powershell
Import-Module .\tools\DwTools\DwTools.psm1 -Force
Get-Command -Module DwTools
Get-Help Edit-DwProject -Full
```

## Read (safe, any file)

| Command | Does |
|---|---|
| `Get-DwProjectSummary <file or folder>` | One row per project: format version, group, and counts of variables, constants, forms, controls, documents, macros, tables, components |
| `Get-DwVariable <path> [-Name 'Wild*']` | Variables with store name, category name, and rule |
| `Get-DwConstant <path> [-Name 'Wild*']` | Constants with value |
| `Get-DwControl <path> [-Form 'Wild*'] [-Name 'Wild*']` | Form controls: form, name, type, and number of rule-driven properties |
| `Get-DwControlProperty <file> -Form F -Control C` | One control's properties: `IsStatic`, `Value` or `Rule`, and the text |
| `Get-DwModelRule <path> -Group <group> [-Model 'Wild*'] [-Kind Dimension,...] [-Unassigned \| -IncludeUnassigned]` | **Model rules with real names.** For each captured model: kind (Dimension, FeatureSuppressionState, CustomProperty, Instance, FileFormat, Component...), DriveWorks name, SOLIDWORKS name (`CageHeight@Sketch1`), and rule. `-Unassigned` lists captured items that have no rule yet. `-Group` defaults to `$env:DW_GROUP_FILE`. |
| `Get-DwRuleDependency <file> <variable>` | **What a variable is computed from.** Walks the `DWVariable`/`DWConstant`/control references in its rule, recursively, down to constants and form inputs. |
| `Find-DwUnusedVariable <file>` | **Variables nothing uses.**<br>• Scans every part's raw text and ignores comments.<br>• Status `Unreferenced` means no reference anywhere. `OnlyUsedByUnused` means a dead chain; the output lists who references it.<br>• Names matching an `Indirect("DWVariablePrefix…")` fragment count as used.<br>• It doesn't check other projects (parent/child) or external templates. |
| `Find-DwRule <regex> <path> [-SimpleMatch]` | Searches **every** rule in every part (variables, control properties, documents, components, flow). Returns project, part, location, and rule. |
| `Get-DwProjectXml <file> [project\|designMaster\|componentTasks\|customSections\|components/<n>]` | One part as an `XmlDocument`, for ad-hoc queries |
| `Select-DwXml <xml> <xpath>` | XPath with DriveWorks prefixes: `p:` project, **`f:` forms and controls**, `sf:`, `ef:`, `pcomp:`, `ct:`, `meta:`. Forms sit in a default namespace, so `//Form` without `f:` matches **nothing**. |
| `Get-DwProjectPart <file>` | Parts with size and compression |
| `Expand-DwProject <file> <dir>` | Dumps the raw XML parts to a folder, for reading and diffing |
| `Test-DwProject <file>` | Structural validation: opens, required parts exist, XML parses, relationships resolve |
| `Compare-DwProject <a> <b>` | Part-by-part byte comparison |
| `Compare-DwProjectContent <old> <new> [-Group <group>]` | **Semantic change report.** Covers variables, constants, forms and controls, documents, macros, calc and data tables, spec flow, component tasks, and model rules (with `-Group`).<br>It **detects renames** of variables, constants, controls and component sets, and substitutes them before comparing, so a rename is one line instead of hundreds of changed rules. It also flags whitespace-only edits as `Reformatted`.<br>This is the change report to run before any Copy Group. |
| `Expand-DwPackage <pkg> <dir> [-ExcludeCad] [-Include <regex>]` | Extracts a `.drivepkg`. Skips `Thumbs.db` and the stray `.git/`. |

## Group database (read-only)

| Command | Does |
|---|---|
| `Get-DwGroupFormat <group>` | `SQLite` or `SqlCe40` |
| `Get-DwGroupProject <group>` | Registered projects (name, directory, hidden/deployed) |
| `Get-DwGroupTable <group>` | Tables and row counts |
| `Get-DwCapturedComponent <group> -Id <CCRef> \| -Path '*\Ladder\*'` | Captured models. Resolves a component's `CCRef` to its SOLIDWORKS file and handles the blob GUID byte order. |
| `Invoke-DwGroupQuery <group> <sql>` | Any `SELECT`. The connection is opened **read-only**. |

## Run a form (DwFormEngine)

`DwFormEngine.psm1` loads a project into **DriveWorks' own rule engine** (`Titan.Rules.dll`, from the local install): variables, constants, special variables, lookup and group tables, and every control property. It then applies inputs the way a user would. No group login, license or SOLIDWORKS is needed, so it's safe to run on any copy. The model it follows is in [docs/formats/form-rules.md](../docs/formats/form-rules.md).

| Command | Does |
|---|---|
| `New-DwFormSession <file> [-Group <group>] [-Inputs @{Ctrl=value}] [-Override @{Slot=value}] [-OverrideRule @{Slot='rule'}] [-Teams 'Engineering'] [-StartValues Default\|Saved]` | Loads the project and applies inputs. It returns a session in about 2 s. **`-OverrideRule` tests a fix without editing the file.** `-Group` (or `$env:DW_GROUP_FILE`) supplies the `DWGroupTable*` tables. |
| `Set-DwFormInput $s @{Ctrl=value}` | Changes inputs like a user, then re-validates list boxes (SelectFirst, restore). It's fast, so use it for sweeps. |
| `Get-DwFormValue $s 'Ctrl.Height','CtrlReturn','CtrlListData','DWVariableX'` | Values, with `IsError` and the rule. |
| `Trace-DwFormValue $s 'Ctrl.Height' [-ErrorsOnly]` | **Why a value is what it is:** the rule and the value of each reference, recursively. With `-ErrorsOnly` it follows only the failing branch and marks the rule that fails on its own (`<== fails here`). |
| `Get-DwFormError $s [-Form F] [-IncludeVariables]` | Every slot in error. `RootCause` marks rules that fail on their own. |
| `Invoke-DwFormRule $s '<rule>' [-Owner '<set>\<instance or model>']` | **Evaluates rule text that isn't in the session**: a model rule, or a proposed fix. `-Owner` is what `MyName()`/`MyNumber()` read: `DW09B-Hopper Main Assembly\DW09B-Right Side Drop Zone Assy Dummy-8` for an instance rule, `<component set>\<model name>` for a file-name rule. So model rules that use `MyNumber` can be tested too. |
| `Get-DwCalcTable $s SectionLayout` | A calculation table's evaluated cells, one row per section (`Row` counts the way `TableGetValue` does). Calculation tables run as DriveWorks' own `SlotTable`, so relative references (`[1U]`, `[2L,1D]`) work. Change a cell for a test through `$s.CalcTables['X'].Table.GetSlot(col, row).SetRule(...)`. |
| `Export-DwFormHtml $s [-Form Details] -Path x.html [-ShowHidden] [-Screenshot]` | Renders the form and its frames from the evaluated Left/Top/Width/Height/Visible. Properties in error get a red outline. The error table and the inputs go under the form. `-Screenshot` saves a PNG through headless Edge. |

```powershell
Import-Module .\tools\DwTools\DwTools.psm1 -Force
Import-Module .\tools\DwTools\DwFormEngine.psm1 -Force
$g  = '.\DriveWorks Files\Sparta DW Group for Claude.drivegroup'
$in = @{ BottomElbow = $false; SLD_ConveyorLength = 20; ConveyorLength = 20; CommonSpecsCheckExtend = $true }
$s  = New-DwFormSession '.\work\DW Apron Project.driveprojx' -Group $g -Inputs $in
Trace-DwFormValue $s 'MotorAndGBFrame.Top' -ErrorsOnly
Export-DwFormHtml $s -Path .\work\apron.html -Screenshot

# Try a fix before writing it:
$s2 = New-DwFormSession '.\work\DW Apron Project.driveprojx' -Group $g -Inputs $in -OverrideRule @{ DWVariablenone = 'If(DWVariableNumberOfBottomSection>0,"None|","None")' }
```

It doesn't run macros, the spec flow or documents, and it runs model rules only through `Invoke-DwFormRule`. `QueryData` returns blank, and `SppGetTeamsDataForUser` returns `-Teams`. Fonts and pictures are approximate. A property in error is drawn at a fallback position, which DriveWorks may handle differently, so trust the error table more than the picture.

## Run a real specification (DwApi)

Creates specifications in the **sandbox group** through the DriveWorks API (`DriveWorks.Engine.dll`, as Administrator does), with exact inputs.
- **Credentials:** from `$env:DW_GROUP_USER` / `$env:DW_GROUP_PASSWORD`, set per command and never stored.
- **Refused:** any group other than the sandbox, and any WO prefix that doesn't start with **`CAI`**.
- **Dev Release** is always checked (there is no Autopilot on the dev group).

| Command | Does |
|---|---|
| `Connect-DwGroup` / `Disconnect-DwGroup $c` | Opens and closes the sandbox group (`Provider=LocalGroupProvider;Path=…`) |
| `New-DwSpec $c '<project>' @{ Control = value } [-Transition Save\|ReleaseLocal]` | Starts a spec, drives the inputs as a user would, optionally runs a transition. Returns the context, name, id and transitions. Without `-Transition` nothing is saved, though each start uses up a spec id. |
| `Invoke-DwSpecTransition $c '<CAI spec>' [-Transition ReleaseLocal]` | Reopens a saved CAI spec (Edit first if Saved) and runs the transition. Returns the state, the folder, the specs it released (Panels children), the **components queued for generation**, and the deferred tasks. With Dev Release forced on outside production (2026-10-09), ReleaseLocal is what the Release button does in dev. |
| `Get-DwSpecValue $spec.Context [-Name 'DZ*']` | Variable values as DriveWorks computed them |

```powershell
$env:DW_GROUP_USER = '...'; $env:DW_GROUP_PASSWORD = '...'   # per session, never in a file
Import-Module .\tools\DwTools\DwApi.psm1 -Force
$c = Connect-DwGroup
try { $s = New-DwSpec $c 'DW Hopper V2' @{ WOPrefix = 'CAI03'; DropZoneLengthRight = 6 } -Transition Save; $s.Name } finally { Disconnect-DwGroup $c }
```

Checked 2026-10-09: on the same inputs, DriveWorks and `DwFormEngine` agree on 746 of 747 Hopper V2 variables (the user name differs). The spec folder holds the project copy in a hidden `DriveWorksFiles` subfolder, which `Get-DwHopperV2Expected` / `Test-DwHopperV2Build` take as `-Spec`. **A release from the API queues the models; it doesn't generate them** (`Generated=False` on every component). The user generates them from SOLIDWORKS.

## What DriveWorks will send to SOLIDWORKS (DwSimulate)

Evaluates **every model rule** of a project for given inputs, offline, with the owner names `MyName`/`MyNumber` need. How this fits with the API and SOLIDWORKS is in [docs/formats/simulation.md](../docs/formats/simulation.md).

| Command | Does |
|---|---|
| `Get-DwModelOutput <file> [-Inputs @{..}] [-Override @{..}] [-OverrideRule @{..}] [-StartValues Saved\|Default] [-Kind ..] [-Model 'pattern']` | One row per model rule: component set, model, kind, SOLIDWORKS name, the value DriveWorks would send, and an `Action` (instances and file names: Keep as …, Delete, Suppress, Unsuppress, Replace -> file). `-StartValues Saved` on a spec folder's project copy replays that spec. |
| `Compare-DwModelOutput $before $after` | What changes in the model between two runs (another input, revision or rule fix) |
| `Test-DwModelOutput $out -Project <file>` | Values that can't build, on parts that exist: `RuleError`, `NotNumber`, `Negative`, `PatternCount` (< 1); `-IncludeZero` adds zeros. Deleted components (and their children, from the tree) and deleted or suppressed features are skipped. |
| `Get-DwComponentTree <file>` | Each driven model and its parent model |

```powershell
Import-Module .\tools\DwTools\DwSimulate.psm1 -Force
$p = '.\Test specification to check\ARD1653\DW Hopper V2.driveprojx'
$a = Get-DwModelOutput $p -StartValues Saved
$b = Get-DwModelOutput $p -StartValues Saved -Inputs @{ DropZoneLengthRight = 8 }
Compare-DwModelOutput $a $b | Format-Table Kind, Model, Name, Before, After   # 28 changes: K80 back, K70 pattern 1, planes +24 in
Test-DwModelOutput $a -Project $p
```

## What was built (DwSpa)

A `.spa` is Sparta's extraction of a built SOLIDWORKS assembly: one record per component (name, configuration, quantities, class, sheet-metal blank and bends, mass) plus a STEP model. It is written by the DataExtractionMacro in the **Solidworks_Automation** repo. DwSpa imports that repo's reader (`modules\spa_format\lib\powershell\SpaFile.psm1`, from the sibling checkout or `$env:DW_SPA_LIB`) rather than copying it. The format notes are in [docs/formats/spa.md](../docs/formats/spa.md).

| Command | Does |
|---|---|
| `Find-DwSpa <name>` | Path of a bundle by name: `CAI03` finds `00- CAI03-Hopper.spa`. It looks in the inbox (`SPA files\`, where the SOLIDWORKS macro saves), then `SPA files\Specs`, then `SPA files\Masters`. **Every DwSpa `-Path`/`-Spa` takes a path or such a name.** |
| `Move-DwSpa <name> [-WhatIf]` | Files a checked bundle (`.spa` + `.xlsx`) from the inbox: `Masters` for `DW<n>-…` masters, `Specs` for spec builds. An older bundle of the same name goes to `<folder>\Previous\` with its date. |
| `Read-DwSpa <x.spa>` | Records with `Qty_Total`, plus the parsed Sparta name: `WO`, `Assembly` (A32), `Kit` (K50, K50A), `Colour`, `Suffix`, `Key` (without WO and colour) and `IsDummy` |
| `Get-DwSpaKit <x.spa>` | One row per built kit: quantity, its parts (`main`, `2LF`, `3LBF`…), and the main panel's thickness, blank length × width and bends. Leftover dummies and loose on-site bolts are included. |
| `Compare-DwSpa <a.spa> <b.spa> [-IncludeSame]` | Two builds kit by kit: `Added`, `Removed`, `Qty`, `Parts`, `Size` |
| `Get-DwHopperV2Expected <spec .driveprojx>` | The prediction, before generation: each top-level kit file with its quantity, and each drop-zone panel with the dummy it replaces |
| `Test-DwHopperV2Build -Spec <spec .driveprojx> -Spa <x.spa> [-PanelCatalog <All Panels.spa>] [-OverrideRule @{..}]` | **Did SOLIDWORKS build what the rules asked for?** It replays the spec's inputs (from the spec folder's project copy), evaluates V2's component-set and dummy instance rules, and reports per kit: `OK`, `Missing`, `Unexpected`, `Qty` (K70/K110 against their pattern quantity) or `Leftover` (a dummy still in the build). With the Panels master `.spa` (found in `Masters` by default) it also checks each drop-zone panel's shape, and lists V2's PanelHeight/Length beside the built blank. About 20 s. `-OverrideRule` shows what a rule change would have built. |

```powershell
Import-Module .\tools\DwTools\DwSpa.psm1 -Force
$env:DW_GROUP_FILE = '.\DriveWorks Files\Sparta DW Group for Claude.drivegroup'
Test-DwHopperV2Build -Spec '.\Test specification to check\ARD1652\DW Hopper V2.driveprojx' -Spa ARD1652 | Where-Object Status -ne OK
# A test spec: its project copy is in the spec record's hidden DriveWorksFiles folder
$spec = '.\DriveWorks Files\Specifications\DriveWorks Files\CAI03-Hopper 0026\DriveWorksFiles\DW Hopper V2.driveprojx'
Test-DwHopperV2Build -Spec $spec -Spa CAI03 | Format-Table
Get-DwGenerationIssue CAI03 | Where-Object Kind -notin 'Property','Rebuild' | Format-Table File, Kind, Item, Value   # DriveWorks' generation log
Move-DwSpa CAI03                                     # checked: out of the inbox
```

A `.spa` has no instance numbers (instances are grouped per file and configuration), no suppression state (suppressed components are dropped), no rebuild errors, mates or dimensions. A red X therefore doesn't show, and must be read in SOLIDWORKS.

DriveWorks' own generation log fills part of that gap:

| Command | Does |
|---|---|
| `Get-DwGenerationIssue <WO or *> [-Since <date>]` | **DriveWorks' generation log** for the files whose name starts with the WO prefix, read from the group database (read-only: tables `Reports`, `ReportEntries`). One row per warning or error, with a `Kind`: `NotFound` (a captured dimension, feature or instance is missing from the model), `InvalidValue` (SOLIDWORKS refused the value, e.g. a pattern count of 0, and the old value stays), `RuleError` (`#VALUE!` reached a model), `Replace` (a `<ReplaceFile>` failed), `Reference`, `Property`, `SavedWithError`, `Rebuild`. A `Rebuild` entry alone doesn't mean a red X ([docs/things-to-test.md](../docs/things-to-test.md), HV2-05). `Property` is mostly the group-wide `Date` failure on assemblies. |

## Exports and tracking (DwTracking)

How the pieces fit together is in [tracking/README.md](../tracking/README.md).

| Command | Does |
|---|---|
| `Test-DwExportChanged [-Fast]` | Project and group files that differ from the last registered export (added, removed, changed) |
| `Invoke-DwExportReview [-Id <date>]` | After a re-export, writes `tracking/reviews/<date>.md`. It covers changed files, the semantic diff of each project (full CSV in `work/export-review-<date>/`), `Compare-DwGroupContent` for the group, the dev changes logged since the last export, and every open item's check. |
| `Register-DwExport -Id <date> -Note .. -Review ..` | Records the current `DriveWorks Files` as an export: hashes in `exports.json` and copies in `snapshots/<id>/`. It reads files that are open in Administrator. |
| `Register-DwRelease -Id <date> -Started <time> [-Finished <time>] -Config <saved .xml> [-ProdBefore <export id>] [-Items <ids>] -Note ..` | Logs a **dev → prod** Copy Group in `tracking/releases.json`: the time window (the rollback point), the configuration the user saved, the projects, components and options, and the SHA-256 of each pushed project file. Run it right after the copy, before any new dev edit. `Get-DwRelease [-Latest]` lists them. |
| `Compare-DwGroupContent <old.drivegroup> <new.drivegroup>` | Table row counts, project registrations relative to the content folder, captures (added, removed, and really re-captured, ignoring the uniform shift a Copy Group adds), group data tables (rows added and removed), and settings |
| `Get-DwTrackingItem [-Id] [-Open]`, `Test-DwTrackingItem [-Id] [-All]`, `Set-DwTrackingItemStatus -Id -Status -Note -Export` | Tracked issues and fixes, their behaviour checks, and their status history |
| `Get-DwLedger [-Since] [-Item]` | The dev-change ledger |
| `Add-DwLedgerNote -Path <file> -Change Removed\|Changed\|Added -Reason '..'` | Records a change made by hand (Explorer, Administrator), so the hook doesn't report it as a re-export |
| `Set-DwChangeContext -Item <id> -Reason '..'` / `-Clear` | (DwTools) Tags the next `Edit-DwProject` writes in the ledger |

**Ledger hook:** `Edit-DwProject` logs every write to a file inside `DriveWorks Files` to `tracking/ledger.jsonl`. Each entry holds the semantic diff (without model rules), the backup and the new hash, so `Test-DwExportChanged` doesn't mistake our edits for a re-export. Writes to `work/` copies aren't logged.

## Write (projects only)

**Every write goes through `Edit-DwProject`:**

1. Copy to temp.
2. Run your script block.
3. Write only the XML parts that changed, keeping the BOM and newlines.
4. Run `Test-DwProject`.
5. Back up the original to `backups/<timestamp>/`. Edits in the same second get `<timestamp>-2`, `-3`, and so on, so no backup is overwritten.
6. Replace the original.

If any step fails, the original is untouched. It **refuses read-only files** (PDM checked-in) unless you use `-OutPath`. It supports **`-WhatIf`**.

```powershell
# Dry run: which parts would change?
Set-DwConstant '.\work\DW HandRails.driveprojx' ShortCornerOffset 2.25 -WhatIf

# Write to a copy and leave the original alone
Set-DwConstant $src ShortCornerOffset 2.25 -OutPath '.\work\DW HandRails.driveprojx'

# Replace a variable rule (use store names: DWVariableX / DWConstantX)
Set-DwVariableRule $proj Client 'DWVariableTextBox1_Client'

# Control properties: a static value, or a rule (a leading '=' is added if missing)
Set-DwControlProperty $proj -Form Details -Control DevRelease -Property Width -Value 150
Set-DwControlProperty $proj -Form Details -Control DevRelease -Property Visible -Rule 'DWVariableIsUserInDevelopement'

# A component set's file-name rule. It is stored in project.xml and in its components/<n>.xml; this updates both.
Set-DwComponentSetRule $proj 'DW10-A02-2 (DW10-A02)' 'If(DWVariableX, DWVariablePrefixMidSection2, "Delete")' -WhatIf

# Anything else: a script block over the XML
Edit-DwProject $proj {
    param($p)
    $proj = $p.GetXml('project')
    foreach ($label in Select-DwXml $proj "//f:Form[@Name='Details']/f:Controls/f:Label") {
        # ... change $label ...
    }
}
```

**Workflow:**
1. Copy the project into `work/`.
2. Edit it with the tools.
3. `Compare-DwProject original edited`.
4. Open it in DriveWorks Administrator using the sandbox group.
5. Deploy through the normal PDM and Pro Server process.

## Conventions for new tools

- Put new functions in `DwTools.psm1` and add them to `Export-ModuleMember`. Verb-`Dw`Noun naming, with comment-based help.
- Stay **PS 5.1-compatible**: no `??`, `?:`, `&&`, or `-AsHashtable`. Use `GetAttribute()` and `LocalName` on XML nodes. Use `-LiteralPath`.
- Any new writer **must** be built on `Edit-DwProject`.
- Never write to `.drivegroup` files.
- After changing the reader or writer, run `tools/tests/Test-DwRoundTrip.ps1 -Path '.\DriveWorks Files'`. It must report 23/23 identical.
- Record surprises in `docs/learnings.md` (tools and engine) or `docs/projects/<project>/learnings.md` (one project).
