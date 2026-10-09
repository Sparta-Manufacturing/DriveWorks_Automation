# DW Platform Layout and DW Platform Bolts: issues

*Generated from [tracking/items.json](../../../tracking/items.json) by `Update-DwIssueDocs`. Do not edit by hand: log an issue with `Add-DwTrackingItem` and change it with `Set-DwTrackingItemStatus` (see [tracking/README.md](../../../tracking/README.md)).*

Known issues of this project, open ones first. Findings and context are in [learnings.md](learnings.md); cross-project issues are in [docs/issues.md](../../issues.md).

Statuses: **open** (a problem, not fixed anywhere), **recommended** (a fix proposed), **fixed-in-dev** (applied in `DriveWorks Files`, waiting for production), **verified** (the check passes on a production export), **closed** (dropped).

| Issue | Status | Priority | Check |
|---|---|---|---|
| [layout-binbackheight-column](#layout-binbackheight-column) The BinBackHeight row looks up a column PlatformList does not have (it has BinBackWidth) | open | high | by hand |
| [layout-debug-exports](#layout-debug-exports) Layout's railing loop writes debug text files to a personal OneDrive folder (C:\Users\oligod\...) on every release | open | medium | by hand |
| [layout-overwrite-railing-height-duplicate](#layout-overwrite-railing-height-duplicate) RailingListInput sends OverwriteRailingHeight twice, FALSE first, so DW HandRails railings are always 43.25 in | open | medium | by hand |
| [layout-sa-counters-1-9](#layout-sa-counters-1-9) Assembly-number counters exist only for SAs 1-9; new platforms in SAs 10-15 all get 100 x SA + 1 | open | medium | by hand |
| [layout-comma-shifts-columns](#layout-comma-shifts-columns) A comma inside a returned platform value shifts PlatformList columns (\| is swapped for ,) | open | low | by hand |
| [layout-handrails-outside-not-deployed](#layout-handrails-outside-not-deployed) DW HandRails outside is Deployed=False in the sandbox, although Layout hosts it when Outside Railing is on | open | low | by hand |

### layout-binbackheight-column

**The BinBackHeight row looks up a column PlatformList does not have (it has BinBackWidth)**

- **Status:** open; **Priority:** high; **Raised:** 2026-10-01
- **Check:** none (checked by hand)
- **Notes:** Picking platforms may lose the value on every release (release refreshes each platform in Edit mode).

### layout-debug-exports

**Layout's railing loop writes debug text files to a personal OneDrive folder (C:\Users\oligod\...) on every release**

- **Status:** open; **Priority:** medium; **Raised:** 2026-10-01
- **Check:** none (checked by hand)
- **Notes:** 4 rules. Straight's close macros do the same.

### layout-overwrite-railing-height-duplicate

**RailingListInput sends OverwriteRailingHeight twice, FALSE first, so DW HandRails railings are always 43.25 in**

- **Status:** open; **Priority:** medium; **Raised:** 2026-10-01
- **Check:** none (checked by hand)
- **Notes:** The first duplicate row wins.

### layout-sa-counters-1-9

**Assembly-number counters exist only for SAs 1-9; new platforms in SAs 10-15 all get 100 x SA + 1**

- **Status:** open; **Priority:** medium; **Raised:** 2026-10-01
- **Check:** none (checked by hand)
- **Notes:** The saved list already has two platforms numbered 1101 in SA 11.

### layout-comma-shifts-columns

**A comma inside a returned platform value shifts PlatformList columns (\| is swapped for ,)**

- **Status:** open; **Priority:** low; **Raised:** 2026-10-01
- **Check:** none (checked by hand)

### layout-handrails-outside-not-deployed

**DW HandRails outside is Deployed=False in the sandbox, although Layout hosts it when Outside Railing is on**

- **Status:** open; **Priority:** low; **Raised:** 2026-10-01
- **Check:** none (checked by hand)
- **Notes:** Check production.
