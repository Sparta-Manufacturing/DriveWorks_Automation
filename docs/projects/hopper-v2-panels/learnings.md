# DW Hopper V2 - Panels: learnings

Dated findings about this project's rules, form and models. **Add new entries at the top.** Cross-project lessons go in [../../learnings.md](../../learnings.md); when an entry here teaches something that applies elsewhere, end it with an "Applies elsewhere:" line and add a short pattern there.

Related: [logic.md](logic.md) (diagrams), [../inputs/hopper-v2-panels-inputs.md](../inputs/hopper-v2-panels-inputs.md) (every input), [../hopper-v2/learnings.md](../hopper-v2/learnings.md) (the host project).

---

## 2026-10-09: The first built test panels (CAI03, CAI04)

The details are in [../hopper-v2/learnings.md](../hopper-v2/learnings.md) (2026-10-09 afternoon). For this project:
- **Every family was the one predicted.** CAI03: R/L531, R/L615, R/L131, B514, B611. CAI04: R/L111, B111.
- **The red X's** are on 531 (3LBF), 615 (3LF), 131 and B514. Same panels and same log entries as on CAI01, so they are in the masters and rules, not in the hosting.
- **The narrow-back hole rules fail in SOLIDWORKS as predicted** (B111: `#VALUE!` colour, counts of 0 rejected), but leave no red X.
- **New:** `HoleOutsideDim` is not found in the R531-3LBF and R131-2LF masters, which the L parts have (`hopper-v2-panels-holeoutsidedim`).
- Pattern counts of 0 are the most common log entry (38 on CAI03). Whether each such pattern is also suppressed is still open ([../../things-to-test.md](../../things-to-test.md), HV2-11).

## 2026-10-08: The 10 panels of production spec 46203 (rev 6 and rev 7)

The method: each panel's inputs were taken from V2's `PanelListInput`, with the bolt zones computed through a stand-in for `SppTableFilterByColumnComparison`. They were replayed in this project, and every dimension and suppression rule of the selected family was evaluated. See [../../learnings.md](../../learnings.md) (2026-10-08).

- **How the family is picked:** `PanelNomenclatureNumberEquivalent`.
  - Side wall: back-line × 100 + front-line × 10 + side profile.
  - Back wall: back-line × 100 + 10 + front-line. So V2's back profile number 524 becomes family B514, and 124 becomes B114.
  - The file-name rule keeps only the component set whose letter and number match (`PanelWithOnsiteBoltName(letter, MyNumber(2))`) and deletes the other 146.
- **Families on spec 46203, and which had a red X:**

  | Panel | Rev 6 | Rev 7 |
  |---|---|---|
  | Side K10 | x131, OK | x531, **error** |
  | Side K11 | x115, **error** (right one missing) | x615, **error** |
  | Side K20 | x131, **error** | x131, **error** |
  | Back bottom row K20/K30 | B114, **error** | B514, **error** |
  | Back top row K21/K31 | B111, OK | B611, OK |

- **Triangle panels get a C-side flange part with a negative width.**
  - `x615-3LF` `Width@Sketch1` = `CSideCutLength − 2 × thickness − 1/32`.
  - A triangle (side profile 5) has `CSideCutLength` = 0, so the width is −0.281 in on rev 7's K11. This is a certain rebuild error.
  - **Likely fix:** delete the C-side part when `SideProfile = 5`, after checking in SOLIDWORKS that the family's mates survive without it.
- **`TopSideLength` has two suspect branches:**
  - side profiles 2–4 divide by `TanD(ConveyorAngle)`, where the top cut angle (`TopCutAngle`) looks intended;
  - back-line profile 3 multiplies by `TanD(90-ConveyorAngle)`, where profile 5 divides by it.

  Neither was used on spec 46203. Side profile 5 with back line 6 gives a negative top length (−0.675 in on rev 7's K11).
- **`BottomFlangeOutsideDimFromOutsideEdge` tests "Light Duty Conveyor" twice,** so its 1.0625 branch can't be reached. Light Duty gets 1.625. Which was intended is still to be confirmed.
- **Zeros aren't the error signal here.** Bolt-pattern counts of 0 and zero sketch start dimensions appear on panels that built fine (A30-K21/K31) as well as on failing ones. The only value that separated a failing panel was the negative width above. The back bottom row's failure (B114/B514, front line 4) needs the SOLIDWORKS "What's Wrong" messages.
- **Applies elsewhere:** a child project can't validate geometry its host computes. A degenerate shape (a zero-length edge) has to be stopped in the host, or the child has to remove the part that depends on it.

## 2026-10-02: Read for the layout-app table

*Split from the joint Hopper V2 / Panels entry; the V2 half is in [../hopper-v2/learnings.md](../hopper-v2/learnings.md).*

- **Panels has 147 component sets, one per panel shape** (56 R, 56 L, 35 B). Each file-name rule keeps only the set that matches the panel's nomenclature (wall + back-line, front-line and side profile digits).
- **Frame widths cut off controls here too.** Sticker Name and Safety Parts Color sit at 624 px in a 450 px frame.
- **Typos in text comparisons:** Panels tests "Ligth Duty Conveyor" in `BottomFlange1stHoleStartDim`, so Light Duty hoppers get a different first flange hole.
- **The spec folder name comes from the raw `HostedSpecificationId`,** while V2 formats its own as `Text(…,"0000")`. See the V2 entry.
- The full table is in [../inputs/hopper-v2-panels-inputs.md](../inputs/hopper-v2-panels-inputs.md).
