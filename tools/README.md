# Tools

PowerShell tooling for inspecting and safely modifying DriveWorks files. It targets **Windows PowerShell 5.1**, with no installs: it uses .NET Framework's `System.IO.Packaging` plus DriveWorks' own SQLite DLL.

```
tools/
  DwTools/DwTools.psm1           module: all the functions below
  DwTools/DwFormEngine.psm1      form evaluator and renderer on DriveWorks' own rule engine (see "Run a form")
  DwTools/DwTracking.psm1        export registry, change ledger, tracked items, export review (see "Exports and tracking")
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

It doesn't run macros, the spec flow, documents or model rules. `QueryData` returns blank, and `SppGetTeamsDataForUser` returns `-Teams`. Fonts and pictures are approximate. A property in error is drawn at a fallback position, which DriveWorks may handle differently, so trust the error table more than the picture.

## Exports and tracking (DwTracking)

How the pieces fit together is in [tracking/README.md](../tracking/README.md).

| Command | Does |
|---|---|
| `Test-DwExportChanged [-Fast]` | Project and group files that differ from the last registered export (added, removed, changed) |
| `Invoke-DwExportReview [-Id <date>]` | After a re-export, writes `tracking/reviews/<date>.md`. It covers changed files, the semantic diff of each project (full CSV in `work/export-review-<date>/`), `Compare-DwGroupContent` for the group, the dev changes logged since the last export, and every open item's check. |
| `Register-DwExport -Id <date> -Note .. -Review ..` | Records the current `DriveWorks Files` as an export: hashes in `exports.json` and copies in `snapshots/<id>/`. It reads files that are open in Administrator. |
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
- Record surprises in `docs/learnings.md`.
