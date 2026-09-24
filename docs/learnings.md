# Learnings log

A running record of what we discovered and what bit us. **Append new entries at the top**, dated, with the evidence.
Promote stable facts into `docs/formats/*`, and repeatable procedures into a skill (`.claude/skills/`).

---

## 2026-09-23: Reading a project (Apron mid sections)

- **The group file is locked while Administrator has it open.** `Get-DwGroupFormat` now opens it with `FileShare.ReadWrite`; SQLite read-only access works alongside Administrator.
- **Pattern: N optional copies of one section.**
  - A count variable, e.g. `bottomconstatmult = RoundUp(run/10)`, gates each copy's *file-name* rule (`If(count > k-1, name, "Delete")`).
  - The same count gates *instances* inside each copy (`If(count > k, "Delete", "Unsuppress")`), so an item appears only in the **last** copy.
  - It also gates the `<Replace>` of dummy placeholders in the SA assemblies.
- **Pattern: `If(TRUE=TRUE, "Delete", ...)` / `If(TRUE=FALSE, "Delete", ...)`** are kill switches: a rule disabled or forced without deleting it.
- New tool: `Get-DwRuleDependency` traces a variable back to its inputs.
- **No instance rule means DriveWorks does nothing**, and Sparta models are usually saved unsuppressed. So an instance with no rule is normally **present**. I first assumed "suppressed"; the user corrected it. Default to "present, as saved".
- Apron findings are to be reviewed with the user:
  - The A02A placement on the incline (A11–A19) and the top run (A21–A24) doesn't follow the bottom run's "last section" rule.
  - Only 4 top-run copies exist, but `topconstatmult` can reach 6 (slider max 60 ft).

---

## 2026-09-23: Engineering process collected

- Sparta's conventions were collected from `Solidworks_Automation` into `docs/engineering-process.md`.
- Jonathan confirmed the codes that no file defines:
  - **Process index:** L Laser, B Bend, D Detailing, F Fab, P Paint, N Straight cut, S Subbed.
  - `-YD` = yard (assembled on site only).
  - `-NP` = no paint.
  - `-Z` = an assembly of parts the laser, press and fabricator never touch.
  - Welded (`F`) parts are painted with their kit.
  - Lesson: my guess that `N` meant "non-metal" was wrong; it means straight cut. **Mark inferred meanings as such until someone confirms them.**
- **The colour codes are defined only in the DriveWorks `Colors` group table**, not in the SOLIDWORKS repo.
- **Shipping-split logic exists only in DriveWorks project variables** (`NumberOfShippingAssy*`, `SameShippingAssy*`). The SOLIDWORKS macros have none.
- **Work-order numbering:** the `ClientProjects` group table (1,439 rows) is the best source for mapping WO number to WO prefix.

---

## 2026-09-23: Captures, model rules, and the typical workflow

### From the user
- Typical change: **edit SOLIDWORKS features and dimensions → capture them with the DriveWorks add-in → create variables and assign rules to the captured items in Administrator.**
- Deployment later means **Copy Group over `SPA-DWP`**, after heavy testing. The server is 24.0.3. The Administrator license is per computer, and this PC is licensed.

### DriveWorks facts
- **`CapturedComponents.Data` is XML** (namespace `c-component`): `C` → `E` (element/feature) → `P` (parameter). `N` = DriveWorks name, `A` = SOLIDWORKS name (`CageHeight@Sketch1`), `T` = type id, `S` = feature type or format. `ReferenceData` = child capture GUIDs, concatenated.
- The type ids are string literals in `DriveWorks.SolidWorks.Components.Constants` (`ID_PARAM_TYPE_DIMENSION`, ...). Reflection over static fields **didn't** find them, because the static constructor doesn't run. **Scanning the `.cctor` IL for `ldstr` → `stsfld` did.** The same technique works for any DriveWorks constant.
- The project `components/<n>.xml` mirrors the capture: `PC`↔`C` (`CCRef`), `PE`↔`E` (`CERef`), `PP`↔`P` (`CPRef`). A newly captured parameter has **no `PP` until it gets a rule**.
- Slot meanings were confirmed from the serializer class names in `DriveWorks.Engine.dll`: `CN` = `ComponentNameElement`, `CP` = `ComponentPathElement`, `CT` = `ComponentTagsElement`, `LC` = `LoopCountElement`.
- `GroupDataTables.TableData` = **raw deflate** over delimited text.
- The API has writable model rules (`DriveWorks.Components.ProjectComponentRule.Rule`) and capture management (`DriveWorks.GroupCapturedComponents`).
- 52 model rules reference captures that are no longer in the group, and 32 reference missing parameter ids. These are probably stale, from re-captures.

---

## 2026-09-23: Project kickoff

### DriveWorks facts
- `.driveprojx` = OPC package of XML. `.drivegroup` = SQLite (current) **or** SQL CE 4.0 (legacy). Details are in [formats/](formats/).
- **Round-trip is lossless.** `System.IO.Packaging` + `XmlDocument` with `PreserveWhitespace = $true` + `XmlWriter` with the original BOM and newline style reproduces every part of all 23 project files byte for byte. Evidence: `tools/tests/Test-DwRoundTrip.ps1`.
- Variables and constants live in **`designMaster.xml`**, not `project.xml`. Their rules have no leading `=`. Control and component rules in the other parts **do** start with `=`.
- Rules reference variables by store name, `DWVariable<Name>`, and controls by bare name. Renaming via XML means rewriting every reference, so leave renames to the API or Administrator.
- Component XML `CCRef` = `CapturedComponents.Id` in the group DB (without dashes). 10,206 of 10,216 references resolved.
- The DriveWorks engine exposes an authoring API: `Project.Variables.CreateVariable`, `ProjectVariable.Rule` (read/write), `Project.CreateRenameProcess`, and `Project.Save()`. The assemblies load in PowerShell 5.1.
- Rules hard-code `C:\Sparta SW Vault\Driveworks\...` paths: 16 hits in Hopper and Platform. That's a PDM vault view.
- The package contained a stray empty `.git` folder and a `.github/copilot-instructions.md` about form CSS. It was ported to the `driveworks-form-css` skill.

- **Forms and controls use a default XML namespace**, `pa-namespace:DriveWorks.Forms,DriveWorks.Engine`, so un-prefixed XPath silently returns nothing. `Select-DwXml` registers `f:` and the other prefixes. A first draft of the tools README had this exact bug.
- `IsStatic="True"` control properties never contain `<Rule>` (0 of 69,087).
- Group DB GUIDs are **16-byte blobs in .NET byte order**. A naive `WHERE Id = '...'` or `lower(Id)` never matches. Use `Get-DwCapturedComponent`, or compare `hex(Id)` against `[guid]::ToByteArray()`.
- The local sandbox group `Sparta DW Group for Claude.drivegroup` was set up by the user, with its content folder set to `DriveWorks Files`. **Credentials are provided per session. Never store them.**

### Tooling gotchas (PowerShell 5.1)
- **Function output unrolls.** A function returning an `XmlNodeList` with 0 or 1 items gives `$null` or a single node, so `.Count` and `[0]` break under StrictMode. Wrap calls in `@(...)`.
- **The `[xml]` adapter shadows properties.** On an element that has a `Name` attribute, `$node.Name` returns the *attribute*, not the element name. Use `$node.LocalName` and `$node.GetAttribute('Name')`.
- **Paths containing `[` `]`**, like `[Content_Types].xml`, are wildcards to `-Path`. Always use `-LiteralPath`.
- **Variables are case-insensitive.** `$s` silently overwrote `$S`. Use distinct names.
- **`-WhatIf` propagates** into every cmdlet the function calls, so internal temp-file work needs `-WhatIf:$false`.
- `Get-Content -Raw` fails with the "parameter not found" error if the path doesn't resolve, which is misleading. It's the wildcard issue above.
- DriveWorks' SQLite interop is x64 only, so use 64-bit PowerShell.
- Files that come out of PDM checked-in are **ReadOnly**. `Copy-Item` preserves that, so clear it on temp copies.
- `Find-DwRule` over 19 projects takes about 30 s (XPath over every attribute). Pre-filtering the raw text would speed it up, but watch out for XML entities and regex anchors.
