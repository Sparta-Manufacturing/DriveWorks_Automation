---
name: driveworks-model-change
description: The typical Sparta DriveWorks change - a SOLIDWORKS model gets new or changed features/dimensions, they are captured with the DriveWorks add-in, then variables are created and rules assigned to the captured items. Use when the user has just captured (or plans to capture) model changes and wants to program them, review what is unassigned, or verify the result.
---

# Model change: capture → variables → model rules

The background is in `docs/formats/captured-models.md`, and the approach is in `docs/analysis/api-vs-xml.md` (sections 5 and 6).
Everything happens in the **sandbox group** (`DriveWorks Files/Sparta DW Group for Claude.drivegroup`). Production is updated later by the user with Copy Group.

```powershell
Import-Module .\tools\DwTools\DwTools.psm1 -Force
$env:DW_GROUP_FILE = '.\DriveWorks Files\Sparta DW Group for Claude.drivegroup'
$proj = '.\DriveWorks Files\Ladder\DW Ladder.driveprojx'
```

## 1. Before the user edits or captures: take a baseline
```powershell
$stamp = Get-Date -Format yyyyMMdd-HHmmss
New-Item -ItemType Directory -Force ".\work\baseline-$stamp" | Out-Null
Copy-Item $proj ".\work\baseline-$stamp\"
Copy-Item $env:DW_GROUP_FILE ".\work\baseline-$stamp\"
Get-DwModelRule $proj -Model '<model>*' -IncludeUnassigned | Export-Csv ".\work\baseline-$stamp\model-rules.csv" -NoTypeInformation
```

## 2. The user edits in SOLIDWORKS and captures with the DriveWorks add-in
Claude **does not** capture or edit models. Captures must match the real file, and only the add-in does that.

## 3. Find what's new and unassigned
```powershell
Get-DwModelRule $proj -Model '<model>*' -Unassigned -Kind Dimension, FeatureSuppressionState, CustomProperty, Instance |
    Format-Table Model, Kind, Parameter, SolidWorksName
```
Compare against the baseline CSV to separate "new since the capture" from "never had a rule".

## 4. Propose the programming
For each new item, propose the following. Output file names must follow Sparta's naming grammar in `docs/engineering-process.md` §3 (`<prefix>-A<n>-K<n>-<index><process letters>-<colour>[-YD|-NP]`, where the process letters are the part's shop route: L laser, B bend, D detailing, F fab, P paint, N straight cut, S subbed), so that downstream BOM extraction classifies kits, single parts and ERP parts correctly:
- The **variable**: name, category, rule. Follow the project's naming. Look at neighbours with `Get-DwVariable $proj -Name '<prefix>*'` and `Find-DwRule`.
- The **model rule**, for example `DWVariableCageSection1Height`, or `If( DWVariableX , TRUE , "Delete" )` for suppression. Show it without the `=` that the XML stores. Copy the conventions used on sibling parameters of the same model (`Get-DwModelRule $proj -Model '<model>*'`).

Present the proposals as a table, with each rule that isn't a one-liner in its own code block below the table, laid out as in `driveworks-project-files` §5 "Rule layout". **Get the user's OK** before any write.

## 5. Apply
| Change | How, today |
|---|---|
| Rule on a parameter that already has a rule | XML: `Edit-DwProject` (a `Set-DwModelRule` helper is planned) |
| Create a variable | **Administrator** or the API. XML insert only after the oracle experiment confirms the format. |
| First rule on a newly captured parameter | **Administrator** or the API. XML needs new `PP`/`PE` nodes, which isn't confirmed yet. |

Update this table as the roadmap lands. See `docs/analysis/api-vs-xml.md`.

## 6. Verify
- `Get-DwModelRule -Unassigned` again. The new items should be gone.
- `Compare-DwProject <baseline copy> $proj`. Only `designMaster.xml` (variables) and the relevant `components/<n>.xml` should differ.
- The user opens the project in Administrator against the sandbox group and runs a test specification.
- Add anything surprising to `docs/learnings.md`.
