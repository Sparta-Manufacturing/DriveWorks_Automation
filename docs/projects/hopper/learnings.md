# DW Hopper Project (original): learnings

Dated findings about this project's rules, form and models. **Add new entries at the top.** Cross-project lessons go in [../../learnings.md](../../learnings.md); when an entry here teaches something that applies elsewhere, end it with an "Applies elsewhere:" line and add a short pattern there.

Related: [../inputs/hopper-inputs.md](../inputs/hopper-inputs.md) (every input). V2 is the current hopper: [../hopper-v2/learnings.md](../hopper-v2/learnings.md).

---

## 2026-10-02: Read for the layout-app table

- **The model can read only hidden helper controls.** Here, rules copy the visible inputs into hidden or off-screen controls, and only those reach the model:
  - ft × 12 goes into `HopperLength`, `DropZoneLength`, `DropZoneLengthl` and `HopperInclineLength`;
  - 90 − the typed angle goes into `DropZoneAngle`;
  - left and right are swapped into `Angledside` and `CutSide`.

  Searching on the visible control's name finds no model rules. Follow the control's value into other controls' rules too.
- **Elbow Angle means different things in the two hoppers.** In the original it is the angle between the runs (180 = straight); in V2 it is the bend itself.
- **Hidden limits can be tighter than the visible ones.** The visible Before elbow Length allows 78 ft, but the hidden inch controls stop at 900 in (75 ft).
- **Leftovers from Kit Conveyor and Apron:**
  - the `ExportToDB` and `ImportFromDB` macros are missing;
  - `DWProjectNumber` = 2 (the same as Kit Conveyor, Apron and Light Duty) is used for the export's EquipmentType;
  - the conveyor labels are still in the export's Notes text.
- **Its `EquipmentListExport` SQL document stores a login in plain text** (one of seven across the projects; see [../../learnings.md](../../learnings.md), 2026-10-02).
- **Applies elsewhere:** follow a control's value through other controls' rules before calling it unused.
- The full table is in [../inputs/hopper-inputs.md](../inputs/hopper-inputs.md).
