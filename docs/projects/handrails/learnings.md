# DW HandRails: learnings

Dated findings about this project's rules, form and models. **Add new entries at the top.** Cross-project lessons go in [../../learnings.md](../../learnings.md); when an entry here teaches something that applies elsewhere, end it with an "Applies elsewhere:" line and add a short pattern there.

Related: [../inputs/handrails-inputs.md](../inputs/handrails-inputs.md) (every input). Parent: [../platform-layout/learnings.md](../platform-layout/learnings.md). Sibling: [../handrails-outside/learnings.md](../handrails-outside/learnings.md).

---

## 2026-10-01: Read for the layout-app table (with DW HandRails outside)

- **"Railing" zones fall back to Handrail, so inside railings are built.**
  - Platform Layout sends `HandrailORKickPlate` the zone's raw connection word, "Railing" or "Kick Plate".
  - DW HandRails' list is "Handrail|Kick Plate", and its `DW04-A160` railing sub-assembly is kept only for "Handrail".
  - "Railing" falls back to Handrail (the combo box's first item), so the railing is built.
  - The user explained that an inside railing is a handrail or a kick plate (`DW04-A160`, with the kick plate `DW04-A161` inside the same assembly), and that the outside railing `DW11-A160` has no kick plate option.

  I first misread this as "inside railings come out empty", because I hadn't checked the combo box's fallback setting. It still works only while Handrail is listed first.
- **Duplicate rows hide a setting.** Layout's `RailingListInput` sends `OverwriteRailingHeight` twice, FALSE first, so DW HandRails railings are always 43.25 in. DW HandRails outside takes `RailingHeight` directly, so the overwrite does reach outside railings.
- **"Long" can't land in a check box.** Layout sends "Long" for a long inside corner. Only HandRails outside has a combo box with Long; in DW HandRails' `ShortCornerLeft`/`Right` check boxes it acts as off.
- **Constants copied from the platform projects are missing here:** `PushedDownThicknessOfFloor` and `PushedDownShippingAssy` are tested in Visible/Enabled/default rules but don't exist in this project.
- **Applies elsewhere:**
  - How a host's input table is applied (first duplicate wins, unknown names ignored, no range check).
  - A combo box's SelectFirst fallback.

  Both are in [../../learnings.md](../../learnings.md) (2026-10-01).
- The full table is in [../inputs/handrails-inputs.md](../inputs/handrails-inputs.md).
