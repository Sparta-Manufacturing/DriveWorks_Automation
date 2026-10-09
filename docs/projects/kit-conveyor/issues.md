# DW Kit Conveyor Project: issues

*Generated from [tracking/items.json](../../../tracking/items.json) by `Update-DwIssueDocs`. Do not edit by hand: log an issue with `Add-DwTrackingItem` and change it with `Set-DwTrackingItemStatus` (see [tracking/README.md](../../../tracking/README.md)).*

Known issues of this project, open ones first. Findings and context are in [learnings.md](learnings.md); cross-project issues are in [docs/issues.md](../../issues.md).

Statuses: **open** (a problem, not fixed anywhere), **recommended** (a fix proposed), **fixed-in-dev** (applied in `DriveWorks Files`, waiting for production), **verified** (the check passes on a production export), **closed** (dropped).

| Issue | Status | Priority | Check |
|---|---|---|---|
| [kit-leg-loop-inactive-legs](#kit-leg-loop-inactive-legs) ReleaseAllLegs releases a DW Start Leg spec for every leg up to NumberOfLegs, active or not | open | low | by hand |
| [kit-outputchecks-frame](#kit-outputchecks-frame) The OutputChecks frame is never visible (height FooterExtend.Height = HeaderColor.Height*1.618*0) | open | low | by hand |

### kit-leg-loop-inactive-legs

**ReleaseAllLegs releases a DW Start Leg spec for every leg up to NumberOfLegs, active or not**

- **Status:** open; **Priority:** low; **Raised:** 2026-10-01
- **Check:** none (checked by hand)
- **Notes:** Only active legs are placed. Same loop in Light Duty.

### kit-outputchecks-frame

**The OutputChecks frame is never visible (height FooterExtend.Height = HeaderColor.Height*1.618*0)**

- **Status:** open; **Priority:** low; **Raised:** 2026-09-29
- **Check:** none (checked by hand)
- **Notes:** Maybe intended; confirm.
