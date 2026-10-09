# DW Start Leg (Legs project): learnings

Dated findings about this project's rules, form and models. **Add new entries at the top.** Cross-project lessons go in [../../learnings.md](../../learnings.md); when an entry here teaches something that applies elsewhere, end it with an "Applies elsewhere:" line and add a short pattern there.

Related: [../inputs/start-leg-inputs.md](../inputs/start-leg-inputs.md) (every input, and the parent-to-leg mapping). Hosts: [../kit-conveyor/learnings.md](../kit-conveyor/learnings.md), [../light-duty-conveyor/learnings.md](../light-duty-conveyor/learnings.md).

---

## 2026-10-01: DW Start Leg, and how the conveyors host it

- **The user confirmed:** Kit Conveyor and Light Duty both host DW Start Leg (the Legs project) as a child project. The two conveyors re-use the same legs with different settings.
- **The conveyors' leg loop.** `GenerateModel` → `ReleaseAllLegs` loops 1 to `NumberOfLegs`.
  - Each pass drives the hidden `SpinButton1`, which the `Index` row turns into the `LegList` lookup key, then releases one `DW Start Leg` spec.
  - The loop doesn't check `LegA4nActive`: inactive legs within the count still get a spec, but only active ones are placed (`<ReplaceFile>` on `<prefix>-A4n-Legs`).
- **Kit and Light Duty send the same leg values,** except for the tail-shaft height conversion inside Leg Height. Leg width = `ConveyorWidth + 12 + 0.2282 + 2 × 0.14474787` = belt width + 12.52 in in both.
- **Start Leg is deployed and not hidden,** so it can also be opened on its own. Neither Order nor Select opens it.
- **Its text-box limits disagree with the captions:** Leg Height's maximum is 300 but the caption says 360. Leg Angle's minimum is 5°, but conveyors can slope 1–4°.
- **Applies elsewhere:**
  - How a hosted child gets its inputs ([../../learnings.md](../../learnings.md), 2026-10-01).
  - The same loop-and-replace pattern hosts Hopper V2's panels ([../hopper-v2/logic.md](../hopper-v2/logic.md)).
- The full table is in [../inputs/start-leg-inputs.md](../inputs/start-leg-inputs.md).
