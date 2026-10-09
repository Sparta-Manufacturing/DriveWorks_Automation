# DW HandRails outside: issues

*Generated from [tracking/items.json](../../../tracking/items.json) by `Update-DwIssueDocs`. Do not edit by hand: log an issue with `Add-DwTrackingItem` and change it with `Set-DwTrackingItemStatus` (see [tracking/README.md](../../../tracking/README.md)).*

Known issues of this project, open ones first. Findings and context are in [learnings.md](learnings.md); cross-project issues are in [docs/issues.md](../../issues.md).

Statuses: **open** (a problem, not fixed anywhere), **recommended** (a fix proposed), **fixed-in-dev** (applied in `DriveWorks Files`, waiting for production), **verified** (the check passes on a production export), **closed** (dropped).

| Issue | Status | Priority | Check |
|---|---|---|---|
| [handrails-out-hexfromstring](#handrails-out-hexfromstring) HexFromString gives 4A-4C for railing letters J-L, so the outside-corner IsOdd test gets a non-number with 10+ railings | open | medium | by hand |
| [handrails-out-frame-from-other-page](#handrails-out-frame-from-other-page) Railing Inputs frame is sized from a control on another page (133 px), so opened on its own the length and heights cannot be reached | open | low | by hand |
| [handrails-out-missing-constants](#handrails-out-missing-constants) PushedDownThicknessOfFloor, PushedDownShippingAssy and WorkOrder are tested in rules but do not exist | open | low | by hand |
| [handrails-out-test-control](#handrails-out-test-control) A never-shown Test Form control (ThicknessOfFloor2) drives the guard posts' middle hole | open | low | by hand |

### handrails-out-hexfromstring

**HexFromString gives 4A-4C for railing letters J-L, so the outside-corner IsOdd test gets a non-number with 10+ railings**

- **Status:** open; **Priority:** medium; **Raised:** 2026-10-01
- **Check:** none (checked by hand)

### handrails-out-frame-from-other-page

**Railing Inputs frame is sized from a control on another page (133 px), so opened on its own the length and heights cannot be reached**

- **Status:** open; **Priority:** low; **Raised:** 2026-10-01
- **Check:** none (checked by hand)

### handrails-out-missing-constants

**PushedDownThicknessOfFloor, PushedDownShippingAssy and WorkOrder are tested in rules but do not exist**

- **Status:** open; **Priority:** low; **Raised:** 2026-10-01
- **Check:** none (checked by hand)

### handrails-out-test-control

**A never-shown Test Form control (ThicknessOfFloor2) drives the guard posts' middle hole**

- **Status:** open; **Priority:** low; **Raised:** 2026-10-01
- **Check:** none (checked by hand)
