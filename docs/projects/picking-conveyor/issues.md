# DW Picking Conveyor Project: issues

*Generated from [tracking/items.json](../../../tracking/items.json) by `Update-DwIssueDocs`. Do not edit by hand: log an issue with `Add-DwTrackingItem` and change it with `Set-DwTrackingItemStatus` (see [tracking/README.md](../../../tracking/README.md)).*

Known issues of this project, open ones first. Findings and context are in [learnings.md](learnings.md); cross-project issues are in [docs/issues.md](../../issues.md).

Statuses: **open** (a problem, not fixed anywhere), **recommended** (a fix proposed), **fixed-in-dev** (applied in `DriveWorks Files`, waiting for production), **verified** (the check passes on a production export), **closed** (dropped).

| Issue | Status | Priority | Check |
|---|---|---|---|
| [picking-dw02-a50-capture-refs](#picking-dw02-a50-capture-refs) The DW02-A50 elbow capture lost a child reference in dev (6 -> 5) and probably went to prod with the 2026-10-09 release | open | medium | by hand |
| [picking-unreachable-options](#picking-unreachable-options) Four Conveyor Options check boxes sit at Left 424-583 in a 400 px frame: Head Scraper always on, HD Takeup Rod always off | open | medium | by hand |
| [picking-clientteamname-query](#picking-clientteamname-query) A ClientTeamName query reads a control that does not exist | open | low | by hand |
| [picking-defaults-below-min](#picking-defaults-below-min) ConveyorHeight defaults to 10 (min 26); Slider_ConveyorHorizontalLength to 7 (min 10) | open | low | by hand |

### picking-dw02-a50-capture-refs

**The DW02-A50 elbow capture lost a child reference in dev (6 -> 5) and probably went to prod with the 2026-10-09 release**

- **Status:** open; **Priority:** medium; **Raised:** 2026-10-09
- **Check:** none (checked by hand)
- **Notes:** Group diff vs the 10-06 prod copy: Picking Conveyor\Models\Elbow Section\DW02-A50.SLDASM re-captured on 10-06 (sandbox session 06b) with identical data but 5 child references instead of 6. The capture path says "Elbow Section"; the dev file is in "ElbowSection" (dated 02-04). The 2026-10-09 release auto-selected all components, so prod likely has the 5-reference capture now. To check: release a Picking Conveyor with an elbow in prod; every DW02-A50 child should be copied and renamed (none left pointing at the masters). If one is missing, re-capture DW02-A50 in prod. docs/things-to-test.md PC-1.

### picking-unreachable-options

**Four Conveyor Options check boxes sit at Left 424-583 in a 400 px frame: Head Scraper always on, HD Takeup Rod always off**

- **Status:** open; **Priority:** medium; **Raised:** 2026-10-01
- **Check:** none (checked by hand)

### picking-clientteamname-query

**A ClientTeamName query reads a control that does not exist**

- **Status:** open; **Priority:** low; **Raised:** 2026-10-01
- **Check:** none (checked by hand)

### picking-defaults-below-min

**ConveyorHeight defaults to 10 (min 26); Slider_ConveyorHorizontalLength to 7 (min 10)**

- **Status:** open; **Priority:** low; **Raised:** 2026-10-01
- **Check:** none (checked by hand)
