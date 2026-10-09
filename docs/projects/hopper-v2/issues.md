# DW Hopper V2: issues

*Generated from [tracking/items.json](../../../tracking/items.json) by `Update-DwIssueDocs`. Do not edit by hand: log an issue with `Add-DwTrackingItem` and change it with `Set-DwTrackingItemStatus` (see [tracking/README.md](../../../tracking/README.md)).*

Known issues of this project, open ones first. Findings and context are in [learnings.md](learnings.md); cross-project issues are in [docs/issues.md](../../issues.md).

Statuses: **open** (a problem, not fixed anywhere), **recommended** (a fix proposed), **fixed-in-dev** (applied in `DriveWorks Files`, waiting for production), **verified** (the check passes on a production export), **closed** (dropped).

| Issue | Status | Priority | Check |
|---|---|---|---|
| [hopper-v2-inx0sidepanel](#hopper-v2-inx0sidepanel) BoltZoneTable InX0SidePanel gives a zone starting above row 1 its end height (39.5) instead of FALSE | open | high | yes |
| [hopper-v2-topcut-offset-row](#hopper-v2-topcut-offset-row) The top cut can cut into the offset bottom row, whose panel shapes are always rectangles | open | high | by hand |
| [hopper-v2-bolt-spacing-thresholds](#hopper-v2-bolt-spacing-thresholds) Bolt-hole rules differ from the design table: no hole under 4 in (design 3 in), and a second hole from 15 in (design none until 18 in) | open | medium | by hand |
| [hopper-v2-dummies-not-deleted](#hopper-v2-dummies-not-deleted) Rev 6 of spec 46203 kept 7 drop-zone dummies whose instance rule evaluated to Delete | open | medium | by hand |
| [hopper-v2-k50-left-dims](#hopper-v2-k50-left-dims) Left K50 part: captured dimensions CutOutGap1@Sketch14 and CutOutGap2@Sketch17 are not found | open | medium | by hand |
| [hopper-v2-backward-hidden](#hopper-v2-backward-hidden) Back Angle Direction stays Backward while Back Angle is off; PanelListInput sends the back top row BackAngle 83 | open | low | by hand |
| [hopper-v2-covers-chute-unused](#hopper-v2-covers-chute-unused) Covers and Chute check boxes drive nothing (no rule or model rule reads them) | open | low | by hand |
| [hopper-v2-frame-cutoffs](#hopper-v2-frame-cutoffs) Equipment Name, Sticker Name and Safety Parts Color sit at Left 748 in a 600 px frame with scroll bars hidden | open | low | by hand |
| [hopper-v2-tables-page](#hopper-v2-tables-page) The Tables page does not show clearly what the hopper is doing | open | low | by hand |
| [hopper-v2-dropzone-length-limits](#hopper-v2-dropzone-length-limits) Drop Zone Length has no limit (69 ft accepted; it silently removed the transition and mid section) | recommended | high | yes |
| [hopper-v2-topcut-limit](#hopper-v2-topcut-limit) Angled top cut can run the side down to 0 before the drop zone ends (gap before the transition, triangle panels) | verified | high | yes |
| [hopper-v2-min-panel-height](#hopper-v2-min-panel-height) Drop-zone side panels thinner than a minimum (slivers under the top cut) are still built | verified | medium | yes |
| [hopper-v2-spec-id-format](#hopper-v2-spec-id-format) V2 names its folder with Text(DWSpecificationID,"0000") but sends Panels the raw id; folder names differ below spec 1000 | verified | medium | yes |

### hopper-v2-inx0sidepanel

**BoltZoneTable InX0SidePanel gives a zone starting above row 1 its end height (39.5) instead of FALSE**

- **Status:** open; **Priority:** high; **Raised:** 2026-10-08
- **Check:** [checks/hopper-v2-inx0sidepanel.ps1](../../../tracking/checks/hopper-v2-inx0sidepanel.ps1)
- **Notes:** Last branch [5L] - 0 should be FALSE. On R531 (back angle on) the 39.5 turns on a 3-hole Forward C bolt pattern in a 2.5 in section: likely the rev 7 (ARD1653) K10 red X. InX0BackPanel has the same branch (dormant); its Comment holds a corrected draft.
- **History:**
  - 2026-10-09: open. CAI03: K10 (R/L531) red X on both sides; the 3LBF part failed to rebuild and six bolt-zone counts of 0 were rejected. Consistent with this bug, not proven: test the fix as CAI05 (things-to-test HV2-01).

### hopper-v2-topcut-offset-row

**The top cut can cut into the offset bottom row, whose panel shapes are always rectangles**

- **Status:** open; **Priority:** high; **Raised:** 2026-10-08
- **Check:** none (checked by hand)
- **Notes:** User design (logic PDF p.3/p.6): offset front profiles 2-4 only take side profile 1 (rectangle); offset families x131/x531 never read CSideCutLength. Spec 46203: K10 is built a full 18.5 in rectangle where the cut is at 7.1/9.0 in at its head; K20 is sent as an offset panel only 7.1/9.0 in tall (< 18.5 in offset top), Panels C-zone height -11.4/-9.5 in: likely the K20 red X in both revisions. The 4 in drop-zone stop does not fix it (rev 7 K20 still 9.03 in). Needs a design decision: stop the drop zone where the cut reaches the offset top, or new offset+cut shapes.
- **History:**
  - 2026-10-09: open. CAI03: K20 (R/L131) red X on both sides. Built blank 18.32 x 12 while V2 sends H 9.03: the panel ignores the cut. 2LF, 3LF and the main part failed to rebuild. things-to-test HV2-02.

### hopper-v2-bolt-spacing-thresholds

**Bolt-hole rules differ from the design table: no hole under 4 in (design 3 in), and a second hole from 15 in (design none until 18 in)**

- **Status:** open; **Priority:** medium; **Raised:** 2026-10-08
- **Check:** none (checked by hand)
- **Notes:** Design (logic PDF p.4): x<3 none; 3-12 one hole at x/2; 12-18 one hole at 6 in; 18-24 start 6, spacing 6; 24+ spacing 12. Code (LambdaBoltHoleZoneLengthInGet*): FirstHoleOnOff x<=4 false; FirstDim x<=12 x/2 else 6; Spacing <24 6 else 12; Qty RoundDown((x-9)/spacing)+1, so qty 2 from 15 in. Which is right?

### hopper-v2-dummies-not-deleted

**Rev 6 of spec 46203 kept 7 drop-zone dummies whose instance rule evaluated to Delete**

- **Status:** open; **Priority:** medium; **Raised:** 2026-10-08
- **Check:** none (checked by hand)
- **Notes:** Left dummies 5,7,8,10,11 and right <8>,<11> stayed; all evaluate to "Delete" offline (e.g. Left K31: Enable FALSE, cut line at -10.3 in). Rules are right; the build did not apply them. Needs the rev 6 generation report or a sandbox re-run. Only seen with the 69 ft input.
- **History:**
  - 2026-10-08: open. Confirmed from the build (SPA files\00- ARD1652-Hopper.spa, Test-DwHopperV2Build): Left dummy x5 and Right dummy x2 still in the assembly, A32-K11 never placed. A .spa drops suppressed components, so these were neither deleted nor suppressed. Every instance rule evaluates to Delete. Rev 7 (ARD1653) built exactly what the rules asked. Remaining question: why rev 6 generation skipped them (model generation report).
  - 2026-10-09: open. The sandbox generation log starts 2026-10-05 and has no 46203 run; the production generation report is needed (things-to-test HV2-18).

### hopper-v2-k50-left-dims

**Left K50 part: captured dimensions CutOutGap1@Sketch14 and CutOutGap2@Sketch17 are not found**

- **Status:** open; **Priority:** medium; **Raised:** 2026-10-09
- **Check:** none (checked by hand)
- **Notes:** DriveWorks generation log (CAI01, CAI03; Get-DwGenerationIssue): "Drive dimension ... not found" on <WO>-A31-K50-GR-YD.SLDPRT only; the right K50 takes both. Explains the left-only K50 warning (46203 rev 6/7, CAI03) and the left/right blank difference (49.05 x 22.51 vs 48.97 x 22.50). The cut-out gaps keep the master value. Fix in SOLIDWORKS (user): name the dimensions in the left K50 master as captured, or re-capture. docs/things-to-test.md HV2-08.

### hopper-v2-backward-hidden

**Back Angle Direction stays Backward while Back Angle is off; PanelListInput sends the back top row BackAngle 83**

- **Status:** open; **Priority:** low; **Raised:** 2026-10-08
- **Check:** none (checked by hand)
- **Notes:** No model effect: the vertical back family (B111) reads no rule from BackAngle. Gating DZBackAngleDirectionBackward on DZBackAngleOnOff changes only that value (tested). Clean-up only.

### hopper-v2-covers-chute-unused

**Covers and Chute check boxes drive nothing (no rule or model rule reads them)**

- **Status:** open; **Priority:** low; **Raised:** 2026-10-08
- **Check:** none (checked by hand)
- **Notes:** Both are on the design form (logic PDF p.13). Sticker "on what panel" (drop-down, x2 Sparta and SP01) is not built either; only StickerName text exists.

### hopper-v2-frame-cutoffs

**Equipment Name, Sticker Name and Safety Parts Color sit at Left 748 in a 600 px frame with scroll bars hidden**

- **Status:** open; **Priority:** low; **Raised:** 2026-10-02
- **Check:** none (checked by hand)
- **Notes:** They keep their defaults.

### hopper-v2-tables-page

**The Tables page does not show clearly what the hopper is doing**

- **Status:** open; **Priority:** low; **Raised:** 2026-10-08
- **Check:** none (checked by hand)
- **Notes:** User plan: a Drive3D viewer, later. Earlier ideas: all 30 drop-zone panels with a status, a K50-K120 sections table, side height at the drop-zone end.

### hopper-v2-dropzone-length-limits

**Drop Zone Length has no limit (69 ft accepted; it silently removed the transition and mid section)**

- **Status:** recommended; **Priority:** high; **Raised:** 2026-10-08
- **Check:** [checks/hopper-v2-dropzone-length-limits.ps1](../../../tracking/checks/hopper-v2-dropzone-length-limits.ps1)
- **Notes:** Agreed 2026-10-08, the user makes the change in Administrator: DropZoneLengthRight max = (DWVariableK1XMaxLengthRight + 3 * DWConstantPanelMaxLength) / 12 (16 ft, 15 with a backward lean); BeforeElbowLength min = drop zone length. Text-box Min/Max may not be enforced (platform rows hold 101 vs max 100), so pair with Error messages. Spec 46203 rev 6 (ARD1652) entered 69 ft.

### hopper-v2-topcut-limit

**Angled top cut can run the side down to 0 before the drop zone ends (gap before the transition, triangle panels)**

- **Status:** verified; **Priority:** high; **Raised:** 2026-10-08
- **Check:** [checks/hopper-v2-topcut-limit.ps1](../../../tracking/checks/hopper-v2-topcut-limit.ps1)
- **Notes:** Rev 7: 20 deg reaches 0 at 59.1 in, drop zone ends at 70.3 in, transition 12 in: 11.2 in gap. Proposed max angle = RoundDown(Degrees(ATan((DZHeight - next section height) / (DZLength*12 - K13OriginZDiff))),1) = 8.8 deg on rev 7. Waiting for the user: limit the angle, or clamp the cut at the transition height.
- **History:**
  - 2026-10-08: open. User 2026-10-08: no limit on the angle. Options: (1) delete a bottom-row panel thinner than PanelMinHeight - done for the tail by hopper-v2-min-panel-height, but it does not close the gap; (2) cap the drop zone length where the cut crosses a height. Tested, no circular reference: crossing 0 -> 59.1 in on rev 7 (gap closed, K20 still a triangle to 0); crossing PanelMinHeight -> 48.1 in (K20 front edge 4 in, 4 -> 12 in step); crossing the transition height -> 26.2 in (flush). Waiting for the user to pick the crossing height.
  - 2026-10-08: fixed-in-dev. User decision: no angle limit; the drop zone stops where the top cut comes down to PanelMinHeight. DZLengthRight/DZLengthLeft changed in dev (ledger 2026-10-08). Rev 7: 70.3 -> 48.1 in, side ends at 4.0 in, mid section fills the rest. Rev 6: 826 -> 55.0 in. No cut or a cut that never reaches 4 in: unchanged. Check passes.
  - 2026-10-08: fixed-in-dev. Corrected: the stop is rounded DOWN to whole typed feet, so the transition and mid panels stay on the conveyors 12 in bolt grid (user design rule). Rev 7: drop zone 46.3 in (4 ft typed), side ends at 4.66 in, transition at 48 in, mid at 96 in, K80 2 ft. Check now also asserts the 12 in grid.
  - 2026-10-09: verified (export 2026-10-09-release). In production with the first dev -> prod release (2026-10-09 13:03-13:12 -03:00, tracking/releases.json): the check passes on the project files that were pushed; the user checked prod after the copy.

### hopper-v2-min-panel-height

**Drop-zone side panels thinner than a minimum (slivers under the top cut) are still built**

- **Status:** verified; **Priority:** medium; **Raised:** 2026-10-08
- **Check:** [checks/hopper-v2-min-panel-height.ps1](../../../tracking/checks/hopper-v2-min-panel-height.ps1)
- **Notes:** User decision 2026-10-08: minimum panel height 4 in, kept in its own value (constant PanelMinHeight, next to PanelMaxHeight/PanelMaxLength). To be used by DropZonePanelList.Enable: a side panel is built only if it has at least PanelMinHeight of height under the top-cut line at its tail. Spec 46203 had 5.5 in rows and triangle panels.
- **History:**
  - 2026-10-08: recommended. Constant PanelMinHeight = 4 added to the dev project (ledger 2026-10-08 15:38). Enable wiring tested on copies: rev 6/7 unchanged, 5 deg K21 sliver dropped, a 1.5 in second row dropped. Waiting for the user: drop short rows, or stop them on the form.
  - 2026-10-08: fixed-in-dev. Enable rule now uses PanelMinHeight (ledger 2026-10-08 16:12). Short rows and slivers are dropped with no message (user decision). Check passes on the dev project.
  - 2026-10-09: verified (export 2026-10-09-release). In production with the first dev -> prod release (2026-10-09 13:03-13:12 -03:00, tracking/releases.json): the check passes on the project files that were pushed; the user checked prod after the copy.

### hopper-v2-spec-id-format

**V2 names its folder with Text(DWSpecificationID,"0000") but sends Panels the raw id; folder names differ below spec 1000**

- **Status:** verified; **Priority:** medium; **Raised:** 2026-10-02
- **Check:** [checks/hopper-v2-spec-id-format.ps1](../../../tracking/checks/hopper-v2-spec-id-format.ps1)
- **Notes:** Needs a check on a real release.
- **History:**
  - 2026-10-09: fixed-in-dev. Confirmed by test specs CAI01-Hopper 0008 / CAI02-Hopper 0009: panels generated into "CAI0x-Hopper 8/9", V2 replaced from "...0008/0009", so all 10 + 5 dummies that should be replaced stayed dummies (SPA). Fixed in dev: Panels SWFileLocation uses Text(...,"0000"). Production ids >= 1000 were never affected.
  - 2026-10-09: fixed-in-dev. User chose consistency (2026-10-09): keep the Panels fix, prod-neutral. Panels DWSpecificationPath padded too. Verified in DriveWorks: CAI03-Hopper 0026 / CAI04-Hopper 0037 release every panel into the V2 folder (0026 / 0037), tags 99. Awaiting the regenerated SPA.
  - 2026-10-09: fixed-in-dev. Confirmed by the builds: CAI03 (26/26) and CAI04 (20/20) placed every panel, and their generation logs have no 'Failed to replace a component instance' entry (CAI01/CAI02 had one per dummy to replace).
  - 2026-10-09: verified (export 2026-10-09-release). In production with the first dev -> prod release (2026-10-09 13:03-13:12 -03:00, tracking/releases.json): the check passes on the project files that were pushed; the user checked prod after the copy.
