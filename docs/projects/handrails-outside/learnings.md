# DW HandRails outside: learnings

Dated findings about this project's rules, form and models. **Add new entries at the top.** Cross-project lessons go in [../../learnings.md](../../learnings.md); when an entry here teaches something that applies elsewhere, end it with an "Applies elsewhere:" line and add a short pattern there.

Related: [../inputs/handrails-outside-inputs.md](../inputs/handrails-outside-inputs.md) (every input). Parent: [../platform-layout/learnings.md](../platform-layout/learnings.md). Sibling: [../handrails/learnings.md](../handrails/learnings.md).

---

## 2026-10-01: Read for the layout-app table (with DW HandRails)

- **It takes `RailingHeight` directly,** so Layout's railing-height overwrite reaches outside railings (unlike DW HandRails; see its file).
- **Long corners work here only.** Only this project has a combo box with "Long" for corners.
- **Outside quirks:**
  - Its Railing Inputs frame is sized from a control on another page (133 px), so opened on its own the length and heights can't be reached.
  - A never-shown Test Form control (`ThicknessOfFloor2`) drives the guard posts' middle hole.
  - `HexFromString` gives 4A–4C for railing letters J–L, so the outside-corner `IsOdd` test gets a non-number on a platform with ten or more railings.
- **Constants copied from the platform projects are missing here:** `PushedDownThicknessOfFloor`, `PushedDownShippingAssy` and `WorkOrder` are tested in Visible/Enabled/default rules but don't exist in this project.
- **It's `Deployed=False` in the sandbox,** although Layout hosts it whenever Outside Railing is on.
- The full table is in [../inputs/handrails-outside-inputs.md](../inputs/handrails-outside-inputs.md).
