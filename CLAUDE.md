# DriveWorks Automation

Automating the building and modifying of Sparta's DriveWorks projects: 19 projects, about 5,600 variables, 2,500 form controls, and 103k model rules.
The **approach decision** is in `docs/analysis/api-vs-xml.md`: read and do small edits via the project XML, and leave structural changes to the DriveWorks API or Administrator.

**The typical change** is: SOLIDWORKS feature/dimension edit → capture with the DriveWorks add-in (the user does this) → create variables → assign rules to the captured items. Follow the `driveworks-model-change` skill.
**Sparta's engineering conventions** are in `docs/engineering-process.md`: naming (`<WO prefix>-A<n>-K<n>-<index><process letters>-<colour>[-YD|-NP]`; process index L/B/D/F/P/N/S), kits, shipping assemblies, part classes. Follow them when proposing names, variables or rules.
**DriveWorks rules** are always written in the user's multi-line rule-builder layout, one code block per rule. Keep each rule as simple as possible: for example, input files use paths relative to the project folder. See §5 of the `driveworks-project-files` skill.
**Deployment** is only ever done by the user: Copy Group from the sandbox over `SPA-DWP`, after heavy testing. Until then, nothing leaves the sandbox.

## Layout

| Path | What |
|---|---|
| `DriveWorks Files/` | **Reference snapshot** of the group: projects, models, the sandbox group. 3.3 GB, git-ignored. Don't edit in place. Copy to `work/` first. |
| `tools/DwTools/DwTools.psm1` | PowerShell module: every read/write helper. See `tools/README.md`. |
| `tools/tests/`, `tools/scripts/` | Round-trip fidelity test, inventory generator |
| `docs/` | Analysis, file formats, environment, generated inventory, **learnings log** |
| `.claude/skills/` | `driveworks-model-change` (the typical change), `driveworks-project-files`, `driveworks-group-db`, `driveworks-form-css` |
| `work/`, `backups/` | Scratch copies, and automatic backups from `Edit-DwProject` (git-ignored) |

## Hard rules

1. **Never write to a `.drivegroup` file.** They're SQLite (or legacy SQL CE) with binary blobs. Read them with `Invoke-DwGroupQuery` only.
2. **Every project write goes through `Edit-DwProject`** or a helper built on it. It works on a temp copy, writes only changed parts, validates, and backs up. Never hand-zip a `.driveprojx`.
3. **Don't rename, create, or delete** variables, forms, controls, or models via XML. References span all parts. Use the API or Administrator.
4. **Production is off-limits.** Don't touch Pro Server `SPA-DWP` or the PDM vault `C:\Sparta SW Vault` without the user explicitly saying so for that task. Automation targets the sandbox group `DriveWorks Files/Sparta DW Group for Claude.drivegroup`.
5. **Credentials** are given per session. Pass them via `$env:DW_GROUP_USER` and `$env:DW_GROUP_PASSWORD`. Never write them to files, docs, commits, or memory.
6. Tell the user to open edited projects in DriveWorks Administrator before deploying. XML tools can't validate rule syntax.

## Environment

- Use the **PowerShell tool (Windows PowerShell 5.1)** for tooling. There's no Python and no .NET SDK. Node and git are available.
- PS 5.1 only: no `??`, `?:`, `&&`, or `-AsHashtable`. Use `-LiteralPath` because of `[Content_Types].xml`. On XML nodes use `.LocalName` and `.GetAttribute()`; `.Name` is shadowed by attributes. Wrap function results in `@(...)` before `.Count` or `[0]`.
- XPath over forms and controls needs the `f:` prefix, via `Select-DwXml`.
- Model rules need the group for names: `$env:DW_GROUP_FILE = '.\DriveWorks Files\Sparta DW Group for Claude.drivegroup'`, then `Get-DwModelRule`.
- **Never capture or edit SOLIDWORKS models.** Captures must come from the DriveWorks add-in, so the user does them.
- DriveWorks 24.0.1.4 is at `C:\Program Files\DriveWorks\24.0.1.4\`. The group schema and server are 24.0.3. This PC holds an Administrator license, so API use here is OK.

## Exports and tracking

`DriveWorks Files` is refreshed by a Copy Group from production, which overwrites our dev edits. `tracking/` records:
- each export (`exports.json` and `snapshots/`);
- every dev write (`ledger.jsonl`, logged by `Edit-DwProject`);
- the issues and fixes we discussed (`items.json`, each with a behaviour check in `tracking/checks/`).

A SessionStart/UserPromptSubmit hook says when `DriveWorks Files` stops matching the last export. Then follow `tracking/README.md`: `Invoke-DwExportReview`, write the summary, update item statuses, `Register-DwExport`.

When we agree on a fix or find an issue, add it to `items.json` with a check. Tag dev edits with `Set-DwChangeContext -Item <id>`.

## Keep knowledge current

- Discovered something, or got bitten? Add a dated entry at the **top** of `docs/learnings.md`.
- Stable format facts go in `docs/formats/*.md`. Repeatable procedures become a skill or a `DwTools` function.
- After touching the reader or writer in `DwTools.psm1`, run `.\tools\tests\Test-DwRoundTrip.ps1 -Path '.\DriveWorks Files'`. It must report all projects byte-identical.
- When project files change, run `.\tools\scripts\Update-DwInventory.ps1`.
