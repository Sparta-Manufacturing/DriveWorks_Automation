# DW Picking Conveyor Project: learnings

Dated findings about this project's rules, form and models. **Add new entries at the top.** Cross-project lessons go in [../../learnings.md](../../learnings.md); when an entry here teaches something that applies elsewhere, end it with an "Applies elsewhere:" line and add a short pattern there.

Related: [../inputs/picking-conveyor-inputs.md](../inputs/picking-conveyor-inputs.md) (every input).

---

## 2026-10-01: Picking Conveyor form, read for the layout-app table

- **Four Conveyor Options check boxes can't be reached.** Section frames are `LeftSideWindowWidth` = 400 px wide with both scroll bars hidden. The four boxes sit at Left 424–583, so they keep their defaults: Head Scraper always on, HD Takeup Rod always off.
- **A separate design behind a copied form.** Picking Conveyor has its own DW02 models (the Kit is DW01), but its form came from an older Kit form.
  - The header label is still `KitConveyorConfigurator`, and a `ClientTeamName` query reads a control that doesn't exist.
  - It has no legs and no DW Start Leg host.
  - No other project names it, and it is `Deployed=False`.
- **Every full release builds a one-part block model,** `<prefix>-Block Picking Conveyor`, sized from incline and level lengths, angle, width, pulleys and side-plate heights. It is the nearest thing to a layout envelope in this project.
- **More defaults below their minimum:** `ConveyorHeight` defaults to 10 with a minimum of 26, and `Slider_ConveyorHorizontalLength` to 7 with a minimum of 10.
- **Applies elsewhere:** check `Left` against the frame width, not only `Top` against its height ([../../learnings.md](../../learnings.md), 2026-10-01).
- The full table is in [../inputs/picking-conveyor-inputs.md](../inputs/picking-conveyor-inputs.md).
