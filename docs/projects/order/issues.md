# DW Order Project: issues

*Generated from [tracking/items.json](../../../tracking/items.json) by `Update-DwIssueDocs`. Do not edit by hand: log an issue with `Add-DwTrackingItem` and change it with `Set-DwTrackingItemStatus` (see [tracking/README.md](../../../tracking/README.md)).*

Known issues of this project, open ones first. Findings and context are in [learnings.md](learnings.md); cross-project issues are in [docs/issues.md](../../issues.md).

Statuses: **open** (a problem, not fixed anywhere), **recommended** (a fix proposed), **fixed-in-dev** (applied in `DriveWorks Files`, waiting for production), **verified** (the check passes on a production export), **closed** (dropped).

| Issue | Status | Priority | Check |
|---|---|---|---|
| [order-row-mismatch](#order-row-mismatch) Edit, Generate and Copy read the type from row n of EquipmentListData but the ID from row n of the filtered ListOfEquipments, with no ORDER BY | open | high | by hand |
| [order-childclose-wrong-controls](#order-childclose-wrong-controls) RunFromSpartaChildClose drives Select's and Layout's host controls, not Order's DisplayEquipmentHost | open | medium | by hand |
| [order-waitingforengineering-unconnected](#order-waitingforengineering-unconnected) The step that saves the WaitingForEngineering state is not connected | open | medium | by hand |

### order-row-mismatch

**Edit, Generate and Copy read the type from row n of EquipmentListData but the ID from row n of the filtered ListOfEquipments, with no ORDER BY**

- **Status:** open; **Priority:** high; **Raised:** 2026-10-02
- **Check:** none (checked by hand)

### order-childclose-wrong-controls

**RunFromSpartaChildClose drives Select's and Layout's host controls, not Order's DisplayEquipmentHost**

- **Status:** open; **Priority:** medium; **Raised:** 2026-10-02
- **Check:** none (checked by hand)

### order-waitingforengineering-unconnected

**The step that saves the WaitingForEngineering state is not connected**

- **Status:** open; **Priority:** medium; **Raised:** 2026-10-02
- **Check:** none (checked by hand)
