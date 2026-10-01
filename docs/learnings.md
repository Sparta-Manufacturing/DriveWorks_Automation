# Learnings log

A running record of what we discovered and what bit us. **Append new entries at the top**, dated, with the evidence.
Promote stable facts into `docs/formats/*`, and repeatable procedures into a skill (`.claude/skills/`).

---

## 2026-10-01: DW HandRails and DW HandRails outside, read for the layout-app table

- **How a host's input table is applied,** read from `DriveWorks.Engine.dll` (`SpecificationHostControl.GetInputs`, then `TitanDesignMaster.SetNamedItemValues`). Not yet tested in a release:
  - Names match a control or a constant, ignoring case.
  - When a Name appears twice, the first row wins.
  - A Name the child doesn't have is ignored.
  - Values are written as is, with no check against the child's option list or min/max.
- **So a value outside the child's option list goes through silently.** Platform Layout sends `HandrailORKickPlate` the zone's raw connection, "Railing" or "Kick Plate". DW HandRails' options are "Handrail|Kick Plate", and its railing model's file-name rule keeps the model only for "Handrail" (nothing in the project tests "Railing"). As written, a Layout-built inside railing for a Railing zone would hold only its bolts. **This needs a test release**, or the user's word on what production produces.
- **Duplicate rows hide a setting.** Layout's `RailingListInput` sends `OverwriteRailingHeight` twice, FALSE first, so DW HandRails railings are always 43.25 in. DW HandRails outside takes `RailingHeight` directly, so the overwrite does reach outside railings.
- **"Long" can't land in a check box.** Layout sends "Long" for a long inside corner. Only HandRails outside has a combo box with Long; in DW HandRails' `ShortCornerLeft`/`Right` check boxes it acts as off.
- **Outside quirks:**
  - Its Railing Inputs frame is sized from a control on another page (133 px), so opened on its own the length and heights can't be reached.
  - A never-shown Test Form control (`ThicknessOfFloor2`) drives the guard posts' middle hole.
  - `HexFromString` gives 4A–4C for railing letters J–L, so the outside-corner `IsOdd` test gets a non-number on a platform with ten or more railings.
- **Constants copied from the platform projects are missing here:** `PushedDownThicknessOfFloor`, `PushedDownShippingAssy` and (outside) `WorkOrder` are tested in Visible/Enabled/default rules but don't exist in either HandRails project.
- The full tables are in [projects/inputs/handrails-inputs.md](projects/inputs/handrails-inputs.md) and [projects/inputs/handrails-outside-inputs.md](projects/inputs/handrails-outside-inputs.md). The Layout table's railing mapping is corrected to match.

## 2026-10-01: Platform - Straight and Platform - Picking, read for the layout-app table

- **The hosted platform spec is never saved.** Every close macro (`CloseAddMode`, `CloseEditMode`, `Cancel`) ends with Cancel Specification. So a platform exists only as Layout's `PlatformList` row until Layout's release loop reopens it in Edit mode and releases it.
- **Zone planes mark zone centres. This is confirmed.** `DistanceXn@Zones` = `HalfWidthZoneXn` (zone 1 ÷ 2, zone 1 + zone 2 ÷ 2, …), and the side members repeat those values in a sketch named `Center Of Zones`.
- **The row carries the typed totals,** not the modelled `ActualTotalLength`/`ActualTotalWidth`. A 36 in Platform zone is modelled at 36.4375 in: always in Picking, and only with Grating in Straight.
- **Inputs that drive nothing:** `RailingHeight` is fixed at 43.25 (`OverwriteRailingHeight` = FALSE), and `ThicknessOfFloor` changes only grating descriptions. Layout sends its own railing height straight to the railing specs.
- **Text-box Min/Max doesn't seem to be enforced.** Saved rows hold 101 and 1101 against a maximum of 100. This matches the 2026-10-01 Start Leg finding that no DriveWorks code reads a text box's Minimum.
- **Copied rules that point at nothing:** Picking's `WOPrefix` and `WorkOrder` defaults read constants that only Straight has. Picking's "generated" email attaches `-WithRailings <id>.pdf`, while the triggered action waits for `-WithBolts`. Straight's front grating end-plate test checks for "Openn".
- The full tables are in [projects/inputs/platform-straight-inputs.md](projects/inputs/platform-straight-inputs.md) and [projects/inputs/platform-picking-inputs.md](projects/inputs/platform-picking-inputs.md).

## 2026-10-01: Platform Layout and Platform Bolts, read for the layout-app table

- **The design, as the user described it.** DW Platform Layout is the parent of all the platform projects.
  - It is mainly a big table plus empty assemblies that capture what the user does in the hosted Platform - Straight and Platform - Picking forms.
  - At release it loops through its tables and generates each platform, each handrail, and the bolts between shipping assemblies. It puts the platforms into SAs and the SAs into the top level.
  - The handrail logic still inside Straight and Picking is **inactive on purpose**, because the handrails must sit outside the SAs.
- **A hosted child can send values back.** The child's close macros (`CloseAddMode`, `CloseEditMode`, `Cancel`) run a macro in the parent (`RunFromSpartaChild…`), with the child's `ListToPlatform` pipe list as the argument. Layout swaps `|` for `,` and stores it as one `PlatformList` row, so a comma inside a value shifts the columns.
- **Host input tables can set child constants,** not just controls (`PushedDown…`, `Hosted…`). A Name the child doesn't have is ignored.
- **Rule engine behaviour, checked in `Titan.Rules.dll`:**
  - `TableGetValue` returns blank for row 0, and `TableGetColumnIndexByName` returns NaN for a missing column.
  - `ListAll` skips the first row as a header.
  - `ListFindItem` and `ListGetItem` count from 1.
  
  Layout's `BinBackHeight` row looks up a column that `PlatformList` doesn't have: it has `BinBackWidth`. So Picking platforms may lose that value on every release, because release refreshes each platform in Edit mode.
- **Layout has no coordinates.** Platforms are placed only by coincident mates between connected zone planes and faces, and every Top plane is level. The overall footprint has to be worked out from the platform sizes and connections.
- **Assembly-number counters exist only for SAs 1–9.** New platforms in SAs 10–15 all get 100 × SA + 1. The saved list already has two platforms numbered 1101 in SA 11.
- **Sandbox registration:** Layout, Straight, Picking and Bolts are hidden and deployed, and DW HandRails is deployed. DW HandRails outside is `Deployed=False`, although Layout hosts it whenever Outside Railing is on.
- **Debug exports to a personal folder.** Layout's railing loop and Straight's close macros write text files to `C:\Users\oligod\OneDrive - Sparta Manufacturing\Desktop\text\` on every release (4 rules in each project).
- The full tables are in [projects/inputs/platform-layout-inputs.md](projects/inputs/platform-layout-inputs.md) and [projects/inputs/platform-bolts-inputs.md](projects/inputs/platform-bolts-inputs.md).

## 2026-10-01: Apron form, read for the layout-app table

- **List strings joined without a `|` merge items.** Apron's oiler list starts with `If(BottomHorizontalLength1,"None|","None")`. With no bottom elbow that check box is off, so the list comes out as `NoneA02|A03|…`. This was confirmed with the engine's own `StringFunctions.ListGetItems(list, first, count)`. The ski, E-stop and logo lists are built from it, so all four break.
- **The ClientProjects export runs on every release**, not only for new clients: `NewClientProjects` is released with all documents. The sandbox table holds 161 Apron rows, most of them test prefixes with Work Order "-". Stairs, Ladder and Start Leg release the same `NewClientProjects` document on completion, and Picking Conveyor releases a similar one, `NewClientProject`.
- **Apron has no height input and no supports.** `ConveyorTailHeight` is hidden and no rule reads it, and there is no Start Leg host. So a layout has to set the apron's elevation itself.
- **The 10 ft limit is still hard-coded.** `ftMaximumSectionLength` = 10 is read only by the three `…finallength` guards. The section counts and carry-overs in 21 variables still use a literal 10 (see [projects/apron.md](projects/apron.md)).
- **Kit hooks copied over that point at nothing:**
  - the `ExportToDB` and `ImportFromDB` macros;
  - the `EmailToCustomerCAD` email;
  - `DWVariableProjectNameFromDB`;
  - a `DataLine` query on the Kit's SQL table.
- **Defaults that aren't options:** `TypeBelt` defaults to 2.4375 (a shaft size) and `Thickness` to None, so no belt or chain is built until one is picked.
- The full table is in [projects/inputs/apron-inputs.md](projects/inputs/apron-inputs.md).

## 2026-10-01: Picking Conveyor form, read for the layout-app table

- **Controls past a frame's width can't be reached.** Section frames are `LeftSideWindowWidth` = 400 px wide with both scroll bars hidden. Four Conveyor Options check boxes sit at Left 424–583, so they keep their defaults: Head Scraper always on, HD Takeup Rod always off. Check `Left` against the frame width, as well as `Top` against its height (2026-09-29).
- **A separate design behind a copied form.** Picking Conveyor has its own DW02 models (the Kit is DW01), but its form came from an older Kit form: the header label is still `KitConveyorConfigurator`, and a `ClientTeamName` query reads a control that doesn't exist. It has no legs and no DW Start Leg host. No other project names it, and it is `Deployed=False`.
- **Every full release builds a one-part block model,** `<prefix>-Block Picking Conveyor`, sized from incline and level lengths, angle, width, pulleys and side-plate heights. It is the nearest thing to a layout envelope in this project.
- **More defaults below their minimum:** `ConveyorHeight` defaults to 10 with a minimum of 26, and `Slider_ConveyorHorizontalLength` to 7 with a minimum of 10.
- The full table is in [projects/inputs/picking-conveyor-inputs.md](projects/inputs/picking-conveyor-inputs.md).

## 2026-10-01: DW Start Leg, and how the conveyors host it

- **How a hosted child spec gets its inputs.** The parent has a `SpecificationHostControl` (`SpecificationHostLegs`), and its `InputValues` rule points at a Name/Value calc table (`=DWCalcLegListInput`). Each Name is a child control, and each Value sets it. The child sees plain control values, with no parent references or driven constants, and its own form rules still run. In calc-table rules, `[nU]` means n rows up and `[nL]` means n columns left.
- **The conveyors' leg loop.** `GenerateModel` → `ReleaseAllLegs` loops 1 to `NumberOfLegs`. Each pass drives the hidden `SpinButton1`, which the `Index` row turns into the `LegList` lookup key, then releases one `DW Start Leg` spec. The loop doesn't check `LegA4nActive`: inactive legs within the count still get a spec, but only active ones are placed (`<ReplaceFile>` on `<prefix>-A4n-Legs`).
- **Kit and Light Duty send the same leg values,** except for the tail-shaft height conversion inside Leg Height. Leg width = `ConveyorWidth + 12 + 0.2282 + 2 × 0.14474787` = belt width + 12.52 in in both.
- **Correction to 2026-09-29.** `StubLegStyleA40…A44` doesn't only feed the SQL export. `LegList` reads it through `Indirect("DWVariableStubLegStyle" & [13L])`, and it sets each leg's foot plate. A name search misses `Indirect` references, so check for them before calling an input unused. The Kit table's "leg planes belt width + 11.6 in apart" also came from the Conveyor Block part (`W/2 + 5.8`), not the real legs. Both are fixed in [projects/inputs/kit-conveyor-inputs.md](projects/inputs/kit-conveyor-inputs.md).
- **Start Leg is deployed and not hidden,** so it can also be opened on its own. Neither Order nor Select opens it. Its text-box limits disagree with the captions: Leg Height's maximum is 300 but the caption says 360. Leg Angle's minimum is 5°, but conveyors can slope 1–4°.
- The full table, including the parent-to-leg mapping, is in [projects/inputs/start-leg-inputs.md](projects/inputs/start-leg-inputs.md).

## 2026-10-01: Light Duty Conveyor form, read for the layout-app table

- **A copied form is not a copied model.** The Light Duty form is a copy of the Kit Conveyor's and differs mostly in limits. But Light Duty has 147 variables the Kit doesn't, and the geometry changes:
  - Side walls `ConveyorSideHeight` = 13.197 in (Kit 20.47 in).
  - Pulleys 8 or 10 in (10 only from 48 in belts).
  - 54 in belts added.
  - Shipping split at 480 in.
  
  Check the rules behind each control, not just the control.
- **A model can be switched off for good with `If( TRUE=TRUE,"Delete",…)`.** Light Duty does this to the `DW08-Conveyor Block` and `DW08-A0-Z2` component sets. Non-Engineering releases (and Block Only) release only the Conveyor Block, so a customer or Sales release builds nothing.
- **Leftover lookup values break silently.** `HeadpulleyActualDiameter` handles 8, 12 and 14 in pulleys, and anything else falls through to 16.8125, the Kit's 16 in value. A 10 in pulley therefore gets the wrong belt speed and the wrong Helical gearbox pick.
- **Frame cut-offs can hide required inputs.** The MotorAndGearBox section is only 183 px tall for non-Engineering users. That puts `GearboxModel` (Top 272) out of view, and it has no default, so no gearbox is picked.
- **Macros can release documents the project doesn't have.** `ExportToDB` releases `DWKitConveyorData` and `EquipmentListExport`, and neither exists in Light Duty, so its specs aren't exported anywhere. The project is `Deployed=False` in the sandbox group, and DW Order Project never opens it.
- **Legs are DW Start Leg child specs.** Each leg A40–A44 is released as a `DW Start Leg` spec, fed from the `LegList`/`LegListInput` calc tables. The leg width sent is belt width + 12.52 in.
- The full table is in [projects/inputs/light-duty-conveyor-inputs.md](projects/inputs/light-duty-conveyor-inputs.md).
- **The user confirmed:** non-Engineering users can reach only Kit Conveyor and the platform projects, because Sparta's website access is limited. In every other project the Engineering/non-Engineering paths are partly built and not live, so read them as unfinished rather than broken. The user will revisit this.
- **The user confirmed:** Kit Conveyor and Light Duty both host DW Start Leg (the Legs project) as a child project. The two conveyors re-use the same legs with different settings.

## 2026-10-01: Ladder form, read for the layout-app table

- **Which project opens which.** Platform Layout opens Platform Straight, Platform Picking, both HandRails projects and Platform Bolts. Straight and Picking open only DW HandRails. No project opens DW Ladder or DW Stairs, so nothing passes values to them. The platforms' "Rung Ladder" side option changes only the platform: connection holes, grating end plates and the 3D preview.
- **The output-switch page is unreachable here too.** Ladder's Extra Info page, like Stairs' Extra Stuff, is in no frame. Output PDF stays off, yet the "done" email attaches the ladder PDF. Expect the same pattern in other projects built from this template.
- **Ladder geometry, from the rules:**
  - Rails = floor-to-floor − 1 in (`BottomSupportToLadder`) + railing height.
  - Default railing height = 43.25 in − top floor thickness.
  - Rungs = RoundUp((floor-to-floor − 0.375) ÷ 12).
  - Sections are at most 119 in (`RoundDown(119 / rung pitch) × pitch`).
- **The cage drops itself silently.** `CageEnabled` turns off when the height isn't overwritten and the cage would be under 36 in, that is when floor-to-floor + railing height is under 120 in.
- **Copied-template leftovers.** `CageColorName`'s rules still test Stairs' `HandRailColor`/`AlternateHandRailColor`, which don't exist in Ladder. The section labels read "Conveyor Options" for non-Engineering users. The railing-height box allows 12–80 in, but its slider allows 0–80 in.
- **Width and cage depth are not inputs.** They are fixed in the model and haven't been read from SOLIDWORKS yet.
- The full table is in [projects/inputs/ladder-inputs.md](projects/inputs/ladder-inputs.md).

## 2026-09-30: Instance-rule grammar, corrected

- **The instance-rule handler is `ReleasedAssembly.ReleaseInstance` in `DriveWorks.SolidWorks.dll`**, not `ReleaseComponentHelper` in the Engine. The `|` split found on 2026-09-28 in `EvaluateComponentReferences` is on the component set's **Tags** rule. That method's `IsDelete`/`IsSuppress` chain matches whole strings, and it handles component **file-name** rules.
- In `ReleaseInstance`, each `|` part is handled on its own, so **`S|<Replace>X` and `<Replace>X|S` are the same**. With two state words, the last one wins. The angle-bracket forms (`<suppress>`, `<delete>`) are **not** recognised in instance rules. Details are in [formats/captured-models.md](formats/captured-models.md).
- How it was found: scan all `DriveWorks*.dll` for `ldstr` containing `<replace`, then decode the method IL with `GetILAsByteArray()` + `System.Reflection.Emit.OpCodes`, resolving tokens through `Module.ResolveMember`/`ResolveString`. Gotcha: a PS 5.1 `AssemblyResolve` handler that runs `Get-ChildItem` can recurse into a stack overflow. Pre-index the DLL folder, and skip `*.resources`.

## 2026-09-30: Stairs form, read for the layout-app table

- **DW Order Project opens only two equipment projects:** its `NewConveyor` button opens `DW Kit Conveyor Project` and its `NewPlatform` button opens `DW Platform Layout`. Stairs is always opened on its own. No platform project creates a Stairs child spec, so no parent sets a Stairs input.
- **A form page that sits in no frame is never shown.** Stairs' Extra Stuff page, which holds the Output DXF/PDF/STEP/Etching switches, is in no `FrameControl` and not in the navigation. So those outputs are always off, yet the "done" email attaches the stairs PDF.
- **`ListAll` doesn't remove duplicates.** Called from the rule engine (`TableFunctions.ListAll`), the tread-type list returned 105 entries (one per StairTreads row) for 2 types. `ListAllDistinct` returns the 2.
- **Numeric boxes can default below their own minimum.** Stairs' `FloorToFloorHeigth` (10–144), `Pitch` (30–45) and `RailHeightBottom` (30–50) all have `DefaultValue` 0.
- **Group-table quirks:** the two "31.5" rows in StairTreads have TreadWidth 32, and the safety-grating rows have trailing spaces (`10      `).
- **Stairs has no SQL export.** Release writes only to the ClientProjects and Colors group tables and sends two emails.
- The full table, with the open questions for engineering, is in [projects/inputs/stairs-inputs.md](projects/inputs/stairs-inputs.md).

## 2026-09-29: Kit Conveyor form, read for the layout-app table

- **User visibility is decided at the frame level.** `LeftSideWindow` stacks one `FrameControl` per section. The frames have scroll bars hidden, and their `Height` rules return 0 for non-Engineering users. So whole sections disappear, and fields below a frame's cut-off height are clipped even when their own `Visible` is TRUE. To find what a user sees, read the frame heights and the control `Top`/`Height` rules, not just `Visible`.
- **The user test is `IsUserInEngineering`** (teams Engineering or Xortion Engineering). `IsUserInSparta` (Engineering or Sales) has no reference outside its own definition.
- **Inputs with no model rule:** the MaterialInfo inputs only feed the costing sheet, the SQL export and the dev-only trajectory. ~~`StubLegStyleA40…A44` feeds only the SQL export.~~ Wrong: it also reaches each DW Start Leg spec through `Indirect` (see 2026-10-01).
- **Every Kit Conveyor spec is exported** to SQL table `DWKitConveyorData` (document `DWKitConveyorData`, keyed by ClientNumber, ProjectNumber, EquipmentNumber and Revision). The ForDevOnly Load Data button reads a spec back.
- **PowerShell trap:** in `-like` patterns the backtick is the escape character, so `'| `*'` matches a literal `*`, not "anything". To match text that starts with a backtick, such as markdown code spans, use `.StartsWith()`.
- The full input table is in [projects/inputs/kit-conveyor-inputs.md](projects/inputs/kit-conveyor-inputs.md).
- **Checked against screenshots of the live form** (`DriveWorks Files/Kit Conveyor/DriveWorks Kit Conveyor Project Input.docx`, an Engineering + Developement login). Captions, order, positions, hidden-control gaps and greyed-out controls all matched the XML. Computed fields matched when recomputed from the rules: Horizontal Elbow/Head Loc 239.31/236.35 for 18 ft at 10°, and Gearbox Selected SK9032 - 35RPM with 135.7 fpm for 120 fpm, 14 in pulley, 5 hp, AGMA Class 2.
- **A control's `Source` property holds its static value.** A Label's text is there ("Standard Conveyor Configurator"); its `Text` rule `=IF(X="","",X)` only points back to it. NumericTextBoxes store their last design-time value there. ComboBoxes and CheckBoxes have no `Source`.
- **The OutputChecks frame is never visible.** Its height is `FooterFrame.Height`, which comes from `FooterExtend.Height = HeaderColor.Height*1.618*0`, so it is always 0.
- **Group table text uses tab between columns and LF between rows.** See [formats/drivegroup.md](formats/drivegroup.md).
- The sandbox group has **no specifications** (the `Specifications` table is empty). Spec values have to come from DriveWorks or from the `DWKitConveyorData` SQL table.

## 2026-09-28: Table lookups, tested in the real engine

- **The rule functions are static .NET methods** in `Titan.Rules.dll`, class `Titan.Rules.Common.TableFunctions`. You can call them from PowerShell on a table built with `Titan.Rules.Execution.StandardArrayValue(object[,])`. Return it with `,$obj`, because PowerShell unrolls it otherwise. This checks a lookup rule without Administrator.
- Signatures:
  - `DWVLookup(value, table, lookupColumnIndex, returnColumnIndex[, closestMatch])` searches down a column.
  - `DWHLookup(value, table, lookupRowIndex, returnRowIndex[, closestMatch])` searches across a row.
  - Indexes are 1-based.
- **With 4 arguments, the lookup defaults to closest match, meaning the *nearest* value** (55 → 60, 105 → 108, 0 → the first row). It doesn't round down, and it never errors. Pass `FALSE` for exact match: a missing value then returns an error.
- Cells stored as text or as numbers both match a numeric lookup value.
- Simple-table data is in `designMaster.xml`, not `project.xml`. See [formats/driveprojx.md](formats/driveprojx.md).
- A calc table is referenced in rules as `DWCalc<Name>`, for example `DWCalcSectionLayout`. To read one cell, use `DWVLookup(key, DWCalc<Name>, 1, TableGetColumnIndexByName(DWCalc<Name>, "<Column>"), FALSE)`. Hopper already uses this pattern.
- **A component set's file-name rule is stored twice**, in `project.xml` and in the root `PC/CN/R` of its part. Editing only one copy would leave them out of sync, so the new `Set-DwComponentSetRule` updates both and refuses if they already differ.
- *(Corrected 2026-09-30: wrong method, see the entry above.)* **Instance-rule grammar, from the engine:** the result is split on `|`, and `S`/`U`/`TRUE`/`FALSE` are short forms of suppress and unsuppress. See [formats/captured-models.md](formats/captured-models.md). How it was found: scan method IL for `ldstr` of `<replace>`, which leads to `ReleaseComponentHelper.EvaluateComponentReferences` and `IsSuppress`/`IsUnsuppress`/`IsDelete`.
- Gotcha: loading a part with a plain `[xml]` cast drops the `\r` from rule text, so comparing it to a `PreserveWhitespace` load showed false differences. Always compare parts loaded the same way.

---

## 2026-09-28: Reviewing a saved project

- **Keys that include a name break on renames.** A renamed component set changes every model-rule key under it, and a renamed control changes every property key. `Compare-DwProjectContent` detects:
  - variable and constant renames, by voting on how references changed;
  - component-set renames, by the same `RId`;
  - control renames, by the same form and type with 60% or more identical properties.

  It then substitutes the new names before diffing. Without this, 5 renames looked like 2,400 changes.
- **Renaming a component set doesn't update `<Replace>` strings everywhere.** Administrator updated the replace in one SA1 but not in the other (V2). Always search for the old name after a component-set rename.
- The user edits the **production** group and copies only the `.driveprojx` into the sandbox. The sandbox's models and captures then lag behind production. Check that captures still resolve: look for `Get-DwModelRule` rows whose Kind is `Unknown` or whose ModelPath starts with `<capture`.
- **PS 5.1 gotcha:** a local `$group` silently overwrote the `[string]$Group` parameter, because names are case-insensitive.

---

## 2026-09-28: Unused variables

- `Find-DwUnusedVariable` scans raw part text (not just rule fields), follows variable→variable references to find dead chains, and respects `Indirect("DWVariable…"&…)` name fragments.
- Apron result: 99 of 309 variables are unused, listed in `docs/projects/apron.md` §4c.
- **PS 5.1 gotcha, again:** `$x = if (...) { @(...) } else { @() }` unrolls. Write `$x = @($(if (...) { ... }))`.

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
