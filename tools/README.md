# Tools

PowerShell tooling for inspecting and safely modifying DriveWorks files. It targets **Windows PowerShell 5.1**, with no installs: it uses .NET Framework's `System.IO.Packaging` plus DriveWorks' own SQLite DLL.

```
tools/
  DwTools/DwTools.psm1           module: all the functions below
  scripts/Update-DwInventory.ps1 regenerates docs/inventory.md
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
| `Find-DwRule <regex> <path> [-SimpleMatch]` | Searches **every** rule in every part (variables, control properties, documents, components, flow). Returns project, part, location, and rule. |
| `Get-DwProjectXml <file> [project\|designMaster\|componentTasks\|customSections\|components/<n>]` | One part as an `XmlDocument`, for ad-hoc queries |
| `Select-DwXml <xml> <xpath>` | XPath with DriveWorks prefixes: `p:` project, **`f:` forms and controls**, `sf:`, `ef:`, `pcomp:`, `ct:`, `meta:`. Forms sit in a default namespace, so `//Form` without `f:` matches **nothing**. |
| `Get-DwProjectPart <file>` | Parts with size and compression |
| `Expand-DwProject <file> <dir>` | Dumps the raw XML parts to a folder, for reading and diffing |
| `Test-DwProject <file>` | Structural validation: opens, required parts exist, XML parses, relationships resolve |
| `Compare-DwProject <a> <b>` | Part-by-part byte comparison |
| `Expand-DwPackage <pkg> <dir> [-ExcludeCad] [-Include <regex>]` | Extracts a `.drivepkg`. Skips `Thumbs.db` and the stray `.git/`. |

## Group database (read-only)

| Command | Does |
|---|---|
| `Get-DwGroupFormat <group>` | `SQLite` or `SqlCe40` |
| `Get-DwGroupProject <group>` | Registered projects (name, directory, hidden/deployed) |
| `Get-DwGroupTable <group>` | Tables and row counts |
| `Get-DwCapturedComponent <group> -Id <CCRef> \| -Path '*\Ladder\*'` | Captured models. Resolves a component's `CCRef` to its SOLIDWORKS file and handles the blob GUID byte order. |
| `Invoke-DwGroupQuery <group> <sql>` | Any `SELECT`. The connection is opened **read-only**. |

## Write (projects only)

**Every write goes through `Edit-DwProject`:**

1. Copy to temp.
2. Run your script block.
3. Write only the XML parts that changed, keeping the BOM and newlines.
4. Run `Test-DwProject`.
5. Back up the original to `backups/<timestamp>/`.
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
