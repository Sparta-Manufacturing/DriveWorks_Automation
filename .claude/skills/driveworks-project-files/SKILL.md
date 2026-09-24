---
name: driveworks-project-files
description: Inspect, search, audit, and safely modify DriveWorks .driveprojx project files (variables, constants, rules, form controls, documents, component rules) with the repo's DwTools PowerShell module. Use whenever a task involves reading or changing a DriveWorks project, finding where something is used, bulk-editing rules, or reporting on projects.
---

# Working with DriveWorks project files

`.driveprojx` = an OPC (ZIP) package of XML parts. The format reference is `docs/formats/driveprojx.md`. The approach decision (why XML vs. API) is in `docs/analysis/api-vs-xml.md`.

## 1. Set up

```powershell
Import-Module .\tools\DwTools\DwTools.psm1 -Force
$root = '.\DriveWorks Files'
$g = "$root\Sparta DW Group for Claude.drivegroup"      # sandbox group; also: $env:DW_GROUP_FILE = $g
Get-DwProjectSummary $root | Format-Table Project, Variables, Constants, Forms, Controls
```

Run everything in the **PowerShell** tool (5.1). There's no Python here.

## 2. Find before you change

| Need | Command |
|---|---|
| Where is X used? | `Find-DwRule 'DWVariableX\b' $root \| Format-Table Project, Location` |
| Variables or constants | `Get-DwVariable $proj -Name 'Wild*'`, `Get-DwConstant $proj` |
| Controls on a form | `Get-DwControl $proj -Form 'Details'`, `Get-DwControlProperty $proj -Form F -Control C` |
| Model rules by SOLIDWORKS name | `Get-DwModelRule $proj -Group $g [-Model 'DW06*'] [-Kind Dimension]`. Needs the group, because names live in the captures. |
| Captured but no rule yet | `Get-DwModelRule $proj -Group $g -Unassigned -Kind Dimension, FeatureSuppressionState` |
| Ad-hoc XPath | `Select-DwXml (Get-DwProjectXml $proj project) "//f:Form[@Name='X']/f:Controls/*"` |
| Raw XML to read | `Expand-DwProject $proj .\work\x` (read-only dump, never repack it) |

**Where things live:**
- Variables and constants: `designMaster.xml` (`/TDM/Variables/Variable`, `/TDM/Constants/Constant`; no namespace).
- Forms, controls, documents, macros, and flow: `project.xml`.
- Model rules: `components/<n>.xml`.
- Forms and controls are in namespace `f:` (`pa-namespace:DriveWorks.Forms,DriveWorks.Engine`). **Plain `//Form` matches nothing.**

## 3. Decide: XML or Administrator/API?

| OK via XML (DwTools) | Use Administrator or the API instead |
|---|---|
| Change a constant's value | **Rename** anything (references are spread across all parts) |
| Replace a variable's rule text | Create or delete variables, forms, controls, documents |
| Set a control property's value or rule | Add or re-capture models, change component structure |
| Find/replace inside rule text (report first) | Anything in a `.drivegroup` (SQLite, read-only) |
| Audits, reports, inventories | Group tables, security, users |

If unsure, report what would change and ask.

## 4. Change safely

1. **Work on a copy** in `work/`. `DriveWorks Files/` is the reference snapshot. `Edit-DwProject` refuses read-only files, which usually means checked in to PDM.
2. Dry run first: `... -WhatIf` shows which parts would change.
3. Use the helpers: `Set-DwConstant`, `Set-DwVariableRule`, `Set-DwControlProperty`. For anything else, use `Edit-DwProject $proj { param($p) $doc = $p.GetXml('project'); ... }`. **Never** hand-zip or edit parts with other tools.
4. Verify:
   - `Compare-DwProject original edited`. Only the expected parts should differ.
   - `Test-DwProject edited`.
   - Re-read the changed value with a getter.
5. Tell the user to open the result in DriveWorks Administrator against the **sandbox group** (`DriveWorks Files/Sparta DW Group for Claude.drivegroup`) before deploying. XML tools can't check rule syntax.

## 5. Rule syntax cheatsheet

- **A model item with no rule is left as saved in SOLIDWORKS.** Sparta usually saves parts unsuppressed, so no rule means **present**.
- **Kill switches:** `If(TRUE=TRUE,"Delete",...)` means always delete. `If(TRUE=FALSE,"Delete",...)` means that branch is disabled.

- In rules, variables are `DWVariable<Name>`, constants are `DWConstant<Name>`, and special variables are `DWSpecification`, `DWSpecificationId`, `DWCurrentUserName`, and so on. Controls use a bare name: `Release`, `Release.Left`.
- Variable rules in `designMaster.xml` have **no** leading `=`. Control and component rules in `project.xml` and `components/*.xml` **start with `=`**.
- `IsStatic="True"` control properties hold only `<Value>`, never `<Rule>`.
- Excel-style functions: `If(...)`, `Text(x,"0000")`, `&` for concatenation.

## 6. Afterwards

- New fact or gotcha: add a dated entry at the top of `docs/learnings.md`.
- New reusable operation: add a function to `DwTools.psm1`, built on `Edit-DwProject`, and document it in `tools/README.md`.
- After changing the reader or writer: `.\tools\tests\Test-DwRoundTrip.ps1 -Path '.\DriveWorks Files'` must report all projects byte-identical.
- If projects changed on disk: `.\tools\scripts\Update-DwInventory.ps1`.
