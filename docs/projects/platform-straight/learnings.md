# DW Platform - Straight: learnings

Dated findings about this project's rules, form and models. **Add new entries at the top.** Cross-project lessons go in [../../learnings.md](../../learnings.md); when an entry here teaches something that applies elsewhere, end it with an "Applies elsewhere:" line and add a short pattern there.

Related: [../inputs/platform-straight-inputs.md](../inputs/platform-straight-inputs.md) (every input). Parent: [../platform-layout/learnings.md](../platform-layout/learnings.md). Sibling: [../platform-picking/learnings.md](../platform-picking/learnings.md).

---

## 2026-10-01: Read for the layout-app table (with Platform - Picking)

These points apply to both platform projects; Picking's own are in its file.

- **The hosted platform spec is never saved.** Every close macro (`CloseAddMode`, `CloseEditMode`, `Cancel`) ends with Cancel Specification. So a platform exists only as Layout's `PlatformList` row until Layout's release loop reopens it in Edit mode and releases it.
- **Zone planes mark zone centres. This is confirmed.** `DistanceXn@Zones` = `HalfWidthZoneXn` (zone 1 ÷ 2, zone 1 + zone 2 ÷ 2, …), and the side members repeat those values in a sketch named `Center Of Zones`.
- **The row carries the typed totals,** not the modelled `ActualTotalLength`/`ActualTotalWidth`. A 36 in Platform zone is modelled at 36.4375 in: always in Picking, and only with Grating in Straight.
- **Inputs that drive nothing:** `RailingHeight` is fixed at 43.25 (`OverwriteRailingHeight` = FALSE), and `ThicknessOfFloor` changes only grating descriptions. Layout sends its own railing height straight to the railing specs.
- **Saved rows hold 101 and 1101 against a maximum of 100.** Text-box Min/Max doesn't seem to be enforced (a cross-project lesson, in [../../learnings.md](../../learnings.md), 2026-10-01).
- **Straight's front grating end-plate test checks for "Openn".**
- **Its close macros write debug text files to a personal folder** (see [../platform-layout/learnings.md](../platform-layout/learnings.md)).
- The full table is in [../inputs/platform-straight-inputs.md](../inputs/platform-straight-inputs.md).
