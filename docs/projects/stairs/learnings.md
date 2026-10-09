# DW Stairs Project: learnings

Dated findings about this project's rules, form and models. **Add new entries at the top.** Cross-project lessons go in [../../learnings.md](../../learnings.md); when an entry here teaches something that applies elsewhere, end it with an "Applies elsewhere:" line and add a short pattern there.

Related: [../inputs/stairs-inputs.md](../inputs/stairs-inputs.md) (every input, with the open questions for engineering).

---

## 2026-09-30: Stairs form, read for the layout-app table

- **Stairs is always opened on its own.** No platform project creates a Stairs child spec, so no parent sets a Stairs input.
- **The Extra Stuff page is never shown.** It holds the Output DXF/PDF/STEP/Etching switches but is in no `FrameControl` and not in the navigation. So those outputs are always off, yet the "done" email attaches the stairs PDF.
- **The tread-type list repeats.** `ListAll` returned 105 entries (one per StairTreads row) for 2 types; `ListAllDistinct` returns the 2.
- **Numeric boxes default below their own minimum:** `FloorToFloorHeigth` (10–144), `Pitch` (30–45) and `RailHeightBottom` (30–50) all have `DefaultValue` 0.
- **Group-table quirks:** the two "31.5" rows in StairTreads have TreadWidth 32, and the safety-grating rows have trailing spaces (`10      `).
- **Stairs has no SQL export.** Release writes only to the ClientProjects and Colors group tables and sends two emails.
- **Applies elsewhere:**
  - Pages in no frame.
  - `ListAll` vs `ListAllDistinct`.
  - Defaults below the minimum.

  All three are in [../../learnings.md](../../learnings.md) (2026-09-30).
- The full table is in [../inputs/stairs-inputs.md](../inputs/stairs-inputs.md).
