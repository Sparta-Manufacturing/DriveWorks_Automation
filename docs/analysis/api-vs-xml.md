# Analysis: DriveWorks API vs. editing project files directly

*Started 2026-09-23 and revised the same day after the answers in section 8. Status: **recommendation stands; the next step is the "oracle" experiment in section 6.***

## TL;DR

**Use a hybrid approach built around the usual change:** SOLIDWORKS edit → capture → new variables → rules on the captured items.

| Step | Where it happens | Automation route |
|---|---|---|
| 1. Add or change features and dimensions | SOLIDWORKS | **Manual** for now. The SOLIDWORKS API is a possible later project. |
| 2. Capture them | DriveWorks SOLIDWORKS add-in → group DB | **Manual. Keep it in DriveWorks.** The capture must match the real model file. |
| 3. See what's new | project + group | **XML, done.** `Get-DwModelRule -Unassigned` lists captured parameters that have no rule yet, by name (`CageHeight@Sketch1`). |
| 4. Create the variables | project (`designMaster.xml`) | **API** (`CreateVariable`), or an XML insert once we've seen exactly what DriveWorks writes (section 6) |
| 5. Assign rules to captured items | project (`components/<n>.xml`) | Existing rule: **XML, easy.** New rule on a new capture: **API** (`ProjectComponentRule.Rule`), or XML after the oracle experiment |
| 6. Verify before Copy Group | sandbox | **XML change report** against the baseline package, then regression specifications through the API. Still to build. |
| 7. Deploy | Copy Group → `SPA-DWP` | **Manual, done by you** after heavy testing. A migration system comes later. |

**Never write to a `.drivegroup`,** and never touch `SPA-DWP` or the PDM vault from automation.

The XML route is viable because **all 23 project files round-trip byte-identically**, and because the group's capture data turns out to be readable XML. That's how model rules resolve to real SOLIDWORKS names.

---

## 1. What we're working with (verified)

| Item | Finding |
|---|---|
| Project file `.driveprojx` | OPC package holding plain XML parts, written by .NET `System.IO.Packaging`. See [formats/driveprojx.md](../formats/driveprojx.md). |
| Group file `.drivegroup` | **SQLite** (current) or **SQL CE 4.0** (legacy). The blobs are readable: capture data is **XML** and table data is deflated text. See [formats/drivegroup.md](../formats/drivegroup.md) and [formats/captured-models.md](../formats/captured-models.md). |
| Production group | `Sparta Manufacturing Group` on **Pro Server `SPA-DWP`**, version **24.0.3** (confirmed) |
| Local sandbox group | `DriveWorks Files/Sparta DW Group for Claude.drivegroup`. The content folder and all 18 projects point into `DriveWorks Files`. **All work happens here.** |
| Deployment | **None for now.** Later: DriveWorks **Copy Group** over the `SPA-DWP` group, after heavy testing. |
| Content storage | Production content is in the **SOLIDWORKS PDM** vault `Sparta SW Vault` (server `SPA-PDM`) |
| Local installs | DriveWorks **24.0.1.4** (and 22.2.1.76), and SOLIDWORKS. **This PC holds an Administrator license** (one per computer), so API automation here is covered. |
| Scale | 19 projects, about 5,600 variables, 2,456 form controls, and **103,409 model rules**. See [inventory.md](../inventory.md). |
| Tooling | Windows PowerShell 5.1 (.NET Framework 4.8), Node 24, git. No Python, and no .NET SDK. |

## 2. The options

### Option A: DriveWorks API

The .NET Framework assemblies in `C:\Program Files\DriveWorks\24.0.1.4\` load in PowerShell 5.1. Reflection shows an authoring API:

- **Group and project:** `IGroupService.OpenGroup(connectionString, credentials)`, `IProjectService.OpenProject(name)`, `Project.Save()`, `Project.CreateTransactionFactory()`
- **Variables:** `ProjectVariables.CreateVariable(name, category, rule, comment)`, plus `ProjectVariable.Rule`, `DisplayName` (read/write), and `Delete()`
- **Renames:** `Project.CreateRenameProcess(oldNames, newNames)` updates every reference
- **Model rules:** `ProjectComponents`, and `ProjectComponentRule.Rule` / `SetRuleAndComment()` (read/write)
- **Captures:** `GroupCapturedComponents.GetComponent`, `CreateComponent`, `SaveComponent`, `ChangeComponentPath`, `RemapComponents`
- **Validation:** `Project.EvaluateRule(formula)`

Opening a group headlessly is **not yet tested**. It needs host initialization and the sandbox credentials, which are passed through environment variables and never stored. Administrator plug-ins are possible later, but need compiled C#. **Rejected:** automating the Administrator UI.

### Option B: edit the `.driveprojx` XML

Everything a project defines is readable text, and edits are surgical and safe through `Edit-DwProject`. The weak spots are creating new items (DriveWorks' ids and defaults), renames, and validation.

## 3. Comparison

| Criterion | A. API | B. XML files |
|---|---|---|
| Setup | Medium. Host init and credentials. **License OK on this PC.** | **None.** Working today. |
| Speed and bulk work | Slower. Loads group and project. | **Fast.** 103k model rules resolved in seconds per project. |
| Validation | **DriveWorks validates** | Structural only. Rule syntax isn't checked. |
| Renames | **`CreateRenameProcess`** | Manual and risky. Don't. |
| Create variables | **`CreateVariable`** | Simple element, but the exact DriveWorks output is unconfirmed (section 6) |
| Rule on an existing captured parameter | `ProjectComponentRule.Rule` | **Easy.** Replace `pcomp:R`. |
| Rule on a newly captured parameter | Supported | Needs new `PP`/`PE` nodes with a fresh `RId`. Unconfirmed (section 6). |
| Capture a model | Possible (`GroupCapturedComponents`) but needs SOLIDWORKS | **No.** Stays in the add-in. |
| Rule history (`RuleRevisions`) | Kept | Bypassed |
| Reviewable diffs | No | **Yes** |
| Upgrade fragility | Low | Medium. Re-run the round-trip test after upgrades. |

## 4. Evidence

1. **Lossless round-trip.** All 23 project files in `DriveWorks Files` came back byte-identical in every part (`tools/tests/Test-DwRoundTrip.ps1`).
2. **Surgical edits.** Each helper edit changed exactly one part, passed validation, and was backed up. Read-only (PDM checked-in) files are refused.
3. **Rules are plain text** in every part: variables, control properties, documents, and components.
4. **Captures are readable.** `CapturedComponents.Data` is XML with the DriveWorks name, SOLIDWORKS name, and type for every captured dimension, feature, and property. The type GUIDs were resolved to DriveWorks' own constants (`ID_PARAM_TYPE_DIMENSION`, etc.) from the assembly. `Get-DwModelRule` joins project and capture: **103,409 rules resolved**, with 32 unresolved parameter ids and 52 rules on captures no longer in the group (stale, worth an audit).
5. **The API covers the whole workflow**, from variables to model rules and captures. See section 2.

## 5. Roadmap

**Phase 1: read tooling (done).**
The summary, variable, constant, control, and rule-search commands, plus **`Get-DwModelRule`** (with `-Unassigned`) and the group queries.
Ideas for later: an unused-variable audit, a stale model-rule audit, a hard-coded path audit (16 hits), and dependency graphs.

**Phase 2: XML writes for existing items (done).**
`Edit-DwProject`, `Set-DwConstant`, `Set-DwVariableRule`, `Set-DwControlProperty`.
**Next:** `Set-DwModelRule` for a parameter that already has a `PP`. This is low risk and has the same shape as the existing helpers.

**Phase 3: the "oracle" experiment (next, small).**
See section 6. This decides whether steps 4 and 5 go through XML or through the API.

**Phase 4: API spike.**
Use PowerShell to open the sandbox group and a project, then `CreateVariable`, set a model rule, and `Save()`. Then **diff the result** with `Compare-DwProject`. The API becomes both a way to write changes and a validator.

**Phase 5: verification before Copy Group.**
- A **change report**: a semantic diff (variables, rules, controls, and model rules added, changed, or removed) between the baseline `.drivepkg` and the sandbox. It proves nothing changed that shouldn't have.
- Then **regression specifications**: run fixed inputs before and after through the API or Autopilot, and compare the outputs.

## 6. The oracle experiment (proposed next step)

Make one representative change **in Administrator** on a copy, and diff it:

1. Copy one small project folder.
2. In SOLIDWORKS, capture one new dimension and one feature on a model.
3. In Administrator, create one variable and give both captured items a rule.
4. Save.
5. Run `Compare-DwProject` and `Get-DwModelRule -Unassigned` before and after.

That shows exactly what DriveWorks writes: the `Variable` attributes, the new `PP`/`PE` nodes, `RId` format, and the capture XML changes. Then either the XML writers copy it faithfully, or we know the API is required. It costs about 15 minutes of Administrator time and needs no code.

## 7. Risks and mitigations

| Risk | Mitigation |
|---|---|
| **Copy Group overwrites `SPA-DWP`**, including any change made on the server since the snapshot | Freeze server edits while the sandbox is in use, or take a fresh server snapshot and run the change report against it right before Copy Group |
| **Version skew.** The server is 24.0.3 and the local install is 24.0.1.4. | Upgrade the local DriveWorks to 24.0.3 before any Copy Group. Re-run the round-trip test after the upgrade. |
| XML format changes on upgrade | Round-trip test, and the `FormatVersion` column in the inventory |
| Edited rule has a syntax error | Open in Administrator, and later validate through the API with `EvaluateRule` or a project load |
| Manual rename misses references | Renames only through the API or Administrator |
| Capture doesn't match the model | Captures only through the DriveWorks add-in |
| Stale model rules (52 on missing captures) | Audit and clean them in Administrator, deliberately and separately from feature work |

## 8. Questions

| # | Question | Answer (2026-09-23) |
|---|---|---|
| 1 | Deployment path? | Nothing goes to production for now. Later: **Copy Group** over `SPA-DWP` after heavy testing, then a migration system. |
| 2 | Does "Deployed" need a redeploy? | Mostly moot, because Copy Group carries the flags |
| 3 | Sandbox group? | `Sparta DW Group for Claude.drivegroup` |
| 4 | Server version? | **24.0.3** |
| 5 | Typical change? | SOLIDWORKS feature/dimension change → capture with the add-in → create variables and assign rules to the captured items |
| 6 | License? | One per computer. **This PC is licensed.** |
| 7 | *New:* Will anyone change `SPA-DWP` while we work in the sandbox? | open |
| 8 | *New:* OK to upgrade the local DriveWorks to 24.0.3? | open |
| 9 | *New:* Will you run the oracle experiment (section 6), or should I go straight to the API spike? | open |
