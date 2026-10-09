# DW Order Project: learnings

Dated findings about this project's rules, form and models. **Add new entries at the top.** Cross-project lessons go in [../../learnings.md](../../learnings.md); when an entry here teaches something that applies elsewhere, end it with an "Applies elsewhere:" line and add a short pattern there.

Related: [../inputs/order-inputs.md](../inputs/order-inputs.md) (inputs, SQL hierarchy, flow states). Entry point: [../select/learnings.md](../select/learnings.md).

---

## 2026-10-02: Read for the layout-app table (with DW Select Project and Web Kit Conveyor)

- **Why Select and Order exist, from the user:** they move the storage of project information into a SQL database outside DriveWorks, they give users an interface they can edit that shows the right content for each user, and with the data outside DriveWorks, tables and reports are easy to build where DriveWorks can't make them. So they are about the user interface and data storage, not specific equipment.
- **The hierarchy lives in SQL, not in specs.** Database `SpartaDWdata`:
  - client: `ClientListData`, key `ClientNumber`, where `ClientTeam` must equal the user's DriveWorks team;
  - project: `ProjectListData`, key + `ProjectNumber`;
  - equipment: `EquipmentListData`, key + `EquipmentNumber`;
  - values: `DWKitConveyorData` or `DWPlatformLayout`, key + `Revision`.

  Opened from Order, Kit Conveyor and Platform Layout write their rows, then cancel their spec. Order's own Save and Close cancels the Order spec too. Only a release leaves a spec.
- **Which project Order opens:** Add uses fixed names (DW Kit Conveyor Project, DW Platform Layout). Edit, Generate Selected and Copy take the row's `EquipmentType` from `EquipmentListData` and look up `DWProjectName` in `DWProjectList`.
- **Order sends `Mode` = Add for new equipment.** The Add button's macro argument "Add" drives `EquipmentMode` through the macro's START → Argument connection. The Layout table had this wrong, and it is corrected.
- **Order bugs found:**
  - Edit, Generate and Copy read the type from row n of `EquipmentListData` but the ID from row n of the filtered view `ListOfEquipments`, with no ORDER BY.
  - `RunFromSpartaChildClose` drives `DisplayEquipmentInterface` (Select's control) and `DisplaySpecificationHostControl1` (Layout's), not Order's `DisplayEquipmentHost`.
  - The step that saves the WaitingForEngineering state isn't connected.
- **Its `ProjectListExport` SQL document stores a login in plain text** (see [../../learnings.md](../../learnings.md), 2026-10-02).
- **Applies elsewhere:**
  - A Drive Control Value task can take its value from the macro argument.
  - The sandbox permissions.

  Both are in [../../learnings.md](../../learnings.md) (2026-10-02).
- The full table is in [../inputs/order-inputs.md](../inputs/order-inputs.md).
