# Light Duty Conveyor: issues

*Generated from [tracking/items.json](../../../tracking/items.json) by `Update-DwIssueDocs`. Do not edit by hand: log an issue with `Add-DwTrackingItem` and change it with `Set-DwTrackingItemStatus` (see [tracking/README.md](../../../tracking/README.md)).*

Known issues of this project, open ones first. Findings and context are in [learnings.md](learnings.md); cross-project issues are in [docs/issues.md](../../issues.md).

Statuses: **open** (a problem, not fixed anywhere), **recommended** (a fix proposed), **fixed-in-dev** (applied in `DriveWorks Files`, waiting for production), **verified** (the check passes on a production export), **closed** (dropped).

| Issue | Status | Priority | Check |
|---|---|---|---|
| [ld-headpulley-10in](#ld-headpulley-10in) HeadpulleyActualDiameter handles 8, 12 and 14 in; a 10 in pulley falls through to 16.8125 (the Kit's 16 in value) | open | high | by hand |
| [ld-exporttodb-missing-docs](#ld-exporttodb-missing-docs) ExportToDB releases DWKitConveyorData and EquipmentListExport, which Light Duty does not have | open | medium | by hand |
| [ld-gearbox-hidden-non-eng](#ld-gearbox-hidden-non-eng) MotorAndGearBox is 183 px tall for non-Engineering users, hiding GearboxModel (no default), so no gearbox is picked | open | low | by hand |
| [light-duty-leg-position-increment](#light-duty-leg-position-increment) Leg positions typed with decimals snap to whole inches (leg position sliders step by 1 in) | verified | medium | yes |

### ld-headpulley-10in

**HeadpulleyActualDiameter handles 8, 12 and 14 in; a 10 in pulley falls through to 16.8125 (the Kit's 16 in value)**

- **Status:** open; **Priority:** high; **Raised:** 2026-10-01
- **Check:** none (checked by hand)
- **Notes:** Wrong belt speed and wrong Helical gearbox pick for 10 in pulleys.

### ld-exporttodb-missing-docs

**ExportToDB releases DWKitConveyorData and EquipmentListExport, which Light Duty does not have**

- **Status:** open; **Priority:** medium; **Raised:** 2026-10-01
- **Check:** none (checked by hand)
- **Notes:** Light Duty specs are not exported anywhere.

### ld-gearbox-hidden-non-eng

**MotorAndGearBox is 183 px tall for non-Engineering users, hiding GearboxModel (no default), so no gearbox is picked**

- **Status:** open; **Priority:** low; **Raised:** 2026-10-01
- **Check:** none (checked by hand)
- **Notes:** Non-Engineering paths are unfinished (user, 2026-10-01).

### light-duty-leg-position-increment

**Leg positions typed with decimals snap to whole inches (leg position sliders step by 1 in)**

- **Status:** verified; **Priority:** medium; **Raised:** 2026-10-09
- **Check:** [checks/light-duty-leg-position-increment.ps1](../../../tracking/checks/light-duty-leg-position-increment.ps1)
- **Notes:** User request 2026-10-09: leg positions to 0.01 in. Each LegA40-A44Position text box follows its slider (DefaultValue = <slider>Return), and DriveWorks snaps a slider to its Increment, so Increment 1 rounds a typed 105.37 to 105. Kit Conveyor sliders already use 0.01; its only whole-inch rounding is in the limits (slider Minimum RoundUp(...,0), Maximum RoundDown(...,0), LegA41-44PositionMax) and in the A40 elbow-clearance default.
- **History:**
  - 2026-10-09: fixed-in-dev. LegA40-A44PositionSlider Increment 1 -> 0.01 in the sandbox project (ledger 2026-10-09 09:04). Check passes. Kit Conveyor already had 0.01; no change there.
  - 2026-10-09: verified (export 2026-10-09-release). In production with the first dev -> prod release (2026-10-09 13:03-13:12 -03:00, tracking/releases.json): the check passes on the project files that were pushed; the user checked prod after the copy.
