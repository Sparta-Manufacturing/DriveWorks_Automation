# Light Duty Conveyor: learnings

Dated findings about this project's rules, form and models. **Add new entries at the top.** Cross-project lessons go in [../../learnings.md](../../learnings.md); when an entry here teaches something that applies elsewhere, end it with an "Applies elsewhere:" line and add a short pattern there.

Related: [../inputs/light-duty-conveyor-inputs.md](../inputs/light-duty-conveyor-inputs.md) (every input), [../start-leg/learnings.md](../start-leg/learnings.md) (the hosted legs).

---

## 2026-10-09: Leg positions snapped to whole inches (slider Increment 1)

- **Each leg position is a text box plus a slider that follow each other.** `LegA4xPosition`'s DefaultValue is `LegA4xPositionSliderReturn`, and the slider's DefaultValue is `LegA4xPositionReturn`. A typed 105.37 goes to the slider, which snaps it to its Increment, and the box takes the snapped value back.
- **Light Duty's five `LegA40…A44PositionSlider` had Increment 1, so every position came back a whole number.** Kit Conveyor's have 0.01. Fixed in dev on 2026-10-09: Increment 1 → 0.01 (tracking item `light-duty-leg-position-increment`).
- **The limits are still whole inches, as in Kit Conveyor:** slider Minimum `RoundUp(…,0)` (A41–A44), Maximum `RoundDown(…,0)` (A40, and A41–A44 through `LegA41…A44PositionMax`), and A40's elbow-clearance default. A position can't sit closer than the next whole inch to a limit.
- **Applies elsewhere:** a text box paired with a slider takes the slider's step (see [../../learnings.md](../../learnings.md), 2026-10-09).

## 2026-10-01: Light Duty Conveyor form, read for the layout-app table

- **A copied form is not a copied model.** The Light Duty form is a copy of the Kit Conveyor's and differs mostly in limits. But Light Duty has 147 variables the Kit doesn't, and the geometry changes:
  - Side walls `ConveyorSideHeight` = 13.197 in (Kit 20.47 in).
  - Pulleys 8 or 10 in (10 only from 48 in belts).
  - 54 in belts added.
  - Shipping split at 480 in.

  Check the rules behind each control, not just the control.
- **Two component sets are switched off for good** with `If( TRUE=TRUE,"Delete",…)`: `DW08-Conveyor Block` and `DW08-A0-Z2`. Non-Engineering releases (and Block Only) release only the Conveyor Block, so a customer or Sales release builds nothing.
- **Leftover lookup values break silently.** `HeadpulleyActualDiameter` handles 8, 12 and 14 in pulleys, and anything else falls through to 16.8125, the Kit's 16 in value. A 10 in pulley therefore gets the wrong belt speed and the wrong Helical gearbox pick.
- **Frame cut-offs can hide required inputs.** The MotorAndGearBox section is only 183 px tall for non-Engineering users. That puts `GearboxModel` (Top 272) out of view, and it has no default, so no gearbox is picked.
- **Macros can release documents the project doesn't have.** `ExportToDB` releases `DWKitConveyorData` and `EquipmentListExport`, and neither exists in Light Duty, so its specs aren't exported anywhere. The project is `Deployed=False` in the sandbox group, and DW Order Project never opens it.
- **Legs are DW Start Leg child specs.** Each leg A40–A44 is released as a `DW Start Leg` spec, fed from the `LegList`/`LegListInput` calc tables. The leg width sent is belt width + 12.52 in.
- **Applies elsewhere:**
  - A copied form doesn't mean a copied model.
  - A lookup's fall-through value can belong to another product.
- The full table is in [../inputs/light-duty-conveyor-inputs.md](../inputs/light-duty-conveyor-inputs.md).
