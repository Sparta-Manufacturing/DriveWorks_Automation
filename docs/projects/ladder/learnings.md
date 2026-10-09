# DW Ladder: learnings

Dated findings about this project's rules, form and models. **Add new entries at the top.** Cross-project lessons go in [../../learnings.md](../../learnings.md); when an entry here teaches something that applies elsewhere, end it with an "Applies elsewhere:" line and add a short pattern there.

Related: [../inputs/ladder-inputs.md](../inputs/ladder-inputs.md) (every input).

---

## 2026-10-01: Ladder form, read for the layout-app table

- **No project opens DW Ladder,** so nothing passes values to it. The platforms' "Rung Ladder" side option changes only the platform: connection holes, grating end plates and the 3D preview.
- **The output-switch page is unreachable.** Ladder's Extra Info page, like Stairs' Extra Stuff, is in no frame. Output PDF stays off, yet the "done" email attaches the ladder PDF. Expect the same pattern in other projects built from this template.
- **Ladder geometry, from the rules:**
  - Rails = floor-to-floor − 1 in (`BottomSupportToLadder`) + railing height.
  - Default railing height = 43.25 in − top floor thickness.
  - Rungs = RoundUp((floor-to-floor − 0.375) ÷ 12).
  - Sections are at most 119 in (`RoundDown(119 / rung pitch) × pitch`).
- **The cage drops itself silently.** `CageEnabled` turns off when the height isn't overwritten and the cage would be under 36 in, that is when floor-to-floor + railing height is under 120 in.
- **Copied-template leftovers.** `CageColorName`'s rules still test Stairs' `HandRailColor`/`AlternateHandRailColor`, which don't exist in Ladder. The section labels read "Conveyor Options" for non-Engineering users. The railing-height box allows 12–80 in, but its slider allows 0–80 in.
- **Width and cage depth are not inputs.** They are fixed in the model and haven't been read from SOLIDWORKS yet.
- **Applies elsewhere:** a form page that sits in no frame is never shown ([../../learnings.md](../../learnings.md), 2026-09-30).
- The full table is in [../inputs/ladder-inputs.md](../inputs/ladder-inputs.md).
