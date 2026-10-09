# DW Hopper V2 - Panels: issues

*Generated from [tracking/items.json](../../../tracking/items.json) by `Update-DwIssueDocs`. Do not edit by hand: log an issue with `Add-DwTrackingItem` and change it with `Set-DwTrackingItemStatus` (see [tracking/README.md](../../../tracking/README.md)).*

Known issues of this project, open ones first. Findings and context are in [learnings.md](learnings.md); cross-project issues are in [docs/issues.md](../../issues.md).

Statuses: **open** (a problem, not fixed anywhere), **recommended** (a fix proposed), **fixed-in-dev** (applied in `DriveWorks Files`, waiting for production), **verified** (the check passes on a production export), **closed** (dropped).

| Issue | Status | Priority | Check |
|---|---|---|---|
| [hopper-v2-panels-backbottom-redx](#hopper-v2-panels-backbottom-redx) Back bottom-row panels (families B114 / B514, front line 4) have a red X in both revisions of spec 46203 | open | high | by hand |
| [hopper-v2-panels-holeoutsidedim](#hopper-v2-panels-holeoutsidedim) Right panel masters R531-3LBF and R131-2LF: captured HoleOutsideDim (Sketch15 / Sketch85) is not found | open | medium | by hand |
| [hopper-v2-panels-ligth-typo](#hopper-v2-panels-ligth-typo) BottomFlange1stHoleStartDim tests "Ligth Duty Conveyor", so Light Duty hoppers get a different first flange hole | open | medium | by hand |
| [hopper-v2-panels-narrow-back-holes](#hopper-v2-panels-narrow-back-holes) Back panels narrower than 15 in per side: bottom-flange hole pattern rules fail (If on the text "Delete") | open | medium | by hand |
| [hopper-v2-panels-straight-boltzone-negative](#hopper-v2-panels-straight-boltzone-negative) Straight side panels (R/L111, no offset) get negative bolt-zone start dimensions (-0.21875 in) | open | medium | by hand |
| [hopper-v2-panels-triangle-cside](#hopper-v2-panels-triangle-cside) Triangle panels (side profile 5) keep a C-side part with a negative width | open | medium | by hand |
| [hopper-v2-panels-frame-cutoffs](#hopper-v2-panels-frame-cutoffs) Sticker Name and Safety Parts Color sit at 624 px in a 450 px frame | open | low | by hand |
| [hopper-v2-panels-topsidelength](#hopper-v2-panels-topsidelength) TopSideLength: side profiles 2-4 divide by TanD(ConveyorAngle) where TopCutAngle looks intended; back line 3 multiplies by TanD(90-ConveyorAngle) where 5 divides | open | low | by hand |
| [hopper-v2-panels-flange-dim-duplicate](#hopper-v2-panels-flange-dim-duplicate) BottomFlangeOutsideDimFromOutsideEdge tests "Light Duty Conveyor" twice; the 1.0625 branch is unreachable | recommended | low | by hand |

### hopper-v2-panels-backbottom-redx

**Back bottom-row panels (families B114 / B514, front line 4) have a red X in both revisions of spec 46203**

- **Status:** open; **Priority:** high; **Raised:** 2026-10-08
- **Check:** none (checked by hand)
- **Notes:** Inputs look normal and bolt zones add up. Needs the SOLIDWORKS What's Wrong messages.
- **History:**
  - 2026-10-09: open. CAI03: B514 (A30-K20, A30-K30) red X again. Log: main part SideBoltHole VerticalA/BackwardC counts of 0 rejected, 2LF/3LF vertical weld-stitch and bolt-hole counts of 0 rejected, rebuild failed. things-to-test HV2-04.

### hopper-v2-panels-holeoutsidedim

**Right panel masters R531-3LBF and R131-2LF: captured HoleOutsideDim (Sketch15 / Sketch85) is not found**

- **Status:** open; **Priority:** medium; **Raised:** 2026-10-09
- **Check:** none (checked by hand)
- **Notes:** DriveWorks generation log (CAI01, CAI03): "HoleOutsideDim@Sketch15 not found" on A32-K10-3LBF (R531) and "HoleOutsideDim@Sketch85" on A32-K20-2LF (R131). The L531/L131 parts do not log it, so only the right masters lack the dimension (or name it differently). The hole keeps the master value on right panels. Fix in SOLIDWORKS (user) or re-capture. docs/things-to-test.md HV2-09.

### hopper-v2-panels-ligth-typo

**BottomFlange1stHoleStartDim tests "Ligth Duty Conveyor", so Light Duty hoppers get a different first flange hole**

- **Status:** open; **Priority:** medium; **Raised:** 2026-10-02
- **Check:** none (checked by hand)

### hopper-v2-panels-narrow-back-holes

**Back panels narrower than 15 in per side: bottom-flange hole pattern rules fail (If on the text "Delete")**

- **Status:** open; **Priority:** medium; **Raised:** 2026-10-09
- **Check:** none (checked by hand)
- **Notes:** LambdaBackBoltHoleZoneLengthInGetHolePatternOnOff returns TRUE or the text "Delete", and the feature rules use it as a condition: If( Lambda...OnOff(InternalWidthLeft) ,TRUE ,"Delete") -> ConvertFailed when the half-width is under 15 in. Qty dims then give 0. Predicted on test spec CAI02-Hopper 0009 (Kit Conveyor 30 in belt, one-piece back, 12 in per side); to confirm with its build. Likely fix: make the lambda return TRUE/FALSE.
- **History:**
  - 2026-10-09: open. Confirmed by the CAI04 generation log (A30-K10, B111): colour of BottomFlangeHoleLeft/RightPattern = #VALUE!, and counts of 0 rejected on the bottom flange, top flange and vertical C hole patterns. No red X: SOLIDWORKS kept the master patterns. What it built: things-to-test HV2-06.

### hopper-v2-panels-straight-boltzone-negative

**Straight side panels (R/L111, no offset) get negative bolt-zone start dimensions (-0.21875 in)**

- **Status:** open; **Priority:** medium; **Raised:** 2026-10-09
- **Check:** none (checked by hand)
- **Notes:** Predicted by Test-DwModelOutput on test spec CAI02-Hopper 0009 (30 in single-row sides, no offset): R111-2LF BoltZoneVertical A/B/C StartDim = -0.21875 on K10 and K20. To confirm with the build; the offline bolt zones use a stand-in for SppTableFilterByColumnComparison.
- **History:**
  - 2026-10-09: open. CAI04: no log entry for the negative starts and no red X; vertical bolt-zone counts of 0 rejected on K10/K20-2LF. Built result: things-to-test HV2-07.

### hopper-v2-panels-triangle-cside

**Triangle panels (side profile 5) keep a C-side part with a negative width**

- **Status:** open; **Priority:** medium; **Raised:** 2026-10-08
- **Check:** none (checked by hand)
- **Notes:** x615-3LF Width@Sketch1 = CSideCutLength - 2*thickness - 1/32 = -0.281 in when CSideCutLength = 0 (rev 7 K11). Likely fix: delete the C-side part when SideProfile = 5, after checking the mates in SOLIDWORKS.
- **History:**
  - 2026-10-08: open. Confirmed from the build: rev 7 A31/A32-K11-3LF came out 2.38 x 0.28 in (the rule gives -0.28 in).
  - 2026-10-09: open. CAI03 (rev 7 inputs, dev rules): K11 (R/L615) red X on both sides; the generation log shows the 3LF part failing to rebuild. What's Wrong and the mates: things-to-test HV2-03.

### hopper-v2-panels-frame-cutoffs

**Sticker Name and Safety Parts Color sit at 624 px in a 450 px frame**

- **Status:** open; **Priority:** low; **Raised:** 2026-10-02
- **Check:** none (checked by hand)

### hopper-v2-panels-topsidelength

**TopSideLength: side profiles 2-4 divide by TanD(ConveyorAngle) where TopCutAngle looks intended; back line 3 multiplies by TanD(90-ConveyorAngle) where 5 divides**

- **Status:** open; **Priority:** low; **Raised:** 2026-10-08
- **Check:** none (checked by hand)
- **Notes:** Not used on spec 46203; confirm intent.

### hopper-v2-panels-flange-dim-duplicate

**BottomFlangeOutsideDimFromOutsideEdge tests "Light Duty Conveyor" twice; the 1.0625 branch is unreachable**

- **Status:** recommended; **Priority:** low; **Raised:** 2026-10-08
- **Check:** none (checked by hand)
- **Notes:** Light Duty gets 1.625. Which was intended?
- **History:**
  - 2026-10-08: recommended. Answered by the user's logic PDF (p.12): bottom flange outside dim = Kit 1.625, LDC 1.625, Picking 1.0625. The duplicated "Light Duty Conveyor" test should be "Picking Conveyor".
