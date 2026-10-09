# DW Kit Conveyor Project: learnings

Dated findings about this project's rules, form and models. **Add new entries at the top.** Cross-project lessons go in [../../learnings.md](../../learnings.md); when an entry here teaches something that applies elsewhere, end it with an "Applies elsewhere:" line and add a short pattern there.

Related: [../inputs/kit-conveyor-inputs.md](../inputs/kit-conveyor-inputs.md) (every input), [../start-leg/learnings.md](../start-leg/learnings.md) (the hosted legs).

---

## 2026-10-09: Leg position inputs already keep 0.01 in

- **The five `LegA40…A44PositionSlider` have Increment 0.01** (in every export since 2026-09-23), and the `LegA4xPosition` text boxes have DecimalPlaces -1 (no rounding). In the engine, a typed 105.37 stays 105.37 through to `DWVariableLegA41Position`.
- **The whole-inch rounding that remains is in the limits:**
  - slider Minimum `RoundUp(…,0)` on A41–A44;
  - slider Maximum `RoundDown(…,0)` on A40, and on A41–A44 through the variables `LegA41…A44PositionMax`, which also place non-Engineering users' legs;
  - A40's elbow-clearance default, `RoundDown(elbow − 8,0)` / `RoundUp(elbow + 8,0)`.
- Light Duty, a copy of this form, had Increment 1 and did round (see [../light-duty-conveyor/learnings.md](../light-duty-conveyor/learnings.md)).

## 2026-10-01: Correction to 2026-09-29 (leg style, leg planes)

- **`StubLegStyleA40…A44` doesn't only feed the SQL export.** `LegList` reads it through `Indirect("DWVariableStubLegStyle" & [13L])`, and it sets each leg's foot plate. A name search misses `Indirect` references, so check for them before calling an input unused.
- The table's "leg planes belt width + 11.6 in apart" also came from the Conveyor Block part (`W/2 + 5.8`), not the real legs. Both are fixed in [../inputs/kit-conveyor-inputs.md](../inputs/kit-conveyor-inputs.md).
- **Applies elsewhere:** search for `Indirect` name fragments before calling anything unused.

## 2026-09-29: Kit Conveyor form, read for the layout-app table

- **Inputs with no model rule:** the MaterialInfo inputs only feed the costing sheet, the SQL export and the dev-only trajectory. ~~`StubLegStyleA40…A44` feeds only the SQL export.~~ Wrong: it also reaches each DW Start Leg spec through `Indirect` (see 2026-10-01).
- **Every Kit Conveyor spec is exported** to SQL table `DWKitConveyorData` (document `DWKitConveyorData`, keyed by ClientNumber, ProjectNumber, EquipmentNumber and Revision). The ForDevOnly Load Data button reads a spec back.
- **Checked against screenshots of the live form** (`DriveWorks Files/Kit Conveyor/DriveWorks Kit Conveyor Project Input.docx`, an Engineering + Developement login).
  - Captions, order, positions, hidden-control gaps and greyed-out controls all matched the XML.
  - Computed fields matched when recomputed from the rules: Horizontal Elbow/Head Loc 239.31/236.35 for 18 ft at 10°, and Gearbox Selected SK9032 - 35RPM with 135.7 fpm for 120 fpm, 14 in pulley, 5 hp, AGMA Class 2.
- **The OutputChecks frame is never visible.** Its height is `FooterFrame.Height`, which comes from `FooterExtend.Height = HeaderColor.Height*1.618*0`, so it is always 0.
- **Applies elsewhere:** frame-level visibility, `IsUserInEngineering`, and a control's `Source` holding its static value. All three are in [../../learnings.md](../../learnings.md) (2026-09-29).
- The full input table is in [../inputs/kit-conveyor-inputs.md](../inputs/kit-conveyor-inputs.md).
