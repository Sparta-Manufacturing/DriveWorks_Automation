# DW Order Project: form inputs

*Read from `DriveWorks Files/DW Order Project.driveprojx` as saved 2026-05-11 08:23. Written 2026-10-02 for Bruno's pre-sales layout app, which should use the same parameters as DriveWorks.*

This table lists every input on the DW Order Project form, the equipment list of one customer project, so the layout app can use the same parameter names. Order isn't equipment: it creates, edits, copies and releases the equipment specs of a project, and it is itself opened from DW Select Project ([select-inputs.md](select-inputs.md)).

**Why Select and Order exist** (from the user):
- **The project information is stored in a SQL database outside DriveWorks,** not in DriveWorks specifications. The database holds the clients, projects, equipment and each equipment's values (see "The hierarchy" below).
- **They give users an interface they can edit,** showing the right content for each user: their client's projects, and each project's equipment.
- **With the data outside DriveWorks, tables and reports are easy to build** where DriveWorks can't make them.

So Select and Order are less about specific equipment and more about the user interface and data storage. The equipment itself is still configured in Kit Conveyor or Platform Layout.

- **DriveWorks Input**: the control name exactly as it appears in DriveWorks.
- **Description**: what the input is for, inferred from its caption, options and rules.
- **Group**: the form page the input sits on.
- **Limitation**: minimum, maximum, option list, or an override limit set by a rule. Empty when there is none.
- **Layout effect**: what the input changes in the equipment's size or position in a layout. Empty when it changes neither, which is the case for every input here.

## Inputs

Rows follow the form from top to bottom: the Tables page (the main window), its pop-up, then the ForDevOnly page at the bottom of the window. Paired controls share a row. Units are in the description, and defaults are at the end of the limitation.

| DriveWorks Input | Description | Group | Limitation | Layout effect |
| --- | --- | --- | --- | --- |
| `ProjectName` | Project name. Saved to SQL table `ProjectListData`. Edit Equipment also writes it to the `Project` column of the project's `DWKitConveyorData` rows. | Tables | Default: the name saved in ProjectListData, else "EnterName" |  |
| `E2ProjectNumber` | E2 project number, followed by a "-XX" label. Sent to the equipment project, which locks it and builds its work order from it (E2 number + "-" + work order number). Saved like Project Name. | Tables | Shown only to Engineering and Sales. Default: the number saved in ProjectListData, else "XXXXX" |  |
| `FilterByEquipmentName`, `FilterByEquipmentWO` | Search boxes, "Filter By Equipment Name..." and "Filter By Equipment WO...". They keep the rows whose name or work order number contains the text. Clear Search empties both. | Tables |  |  |
| `EquipmentList` | The project's equipment, read from SQL view `ListOfEquipments`: Equipment Number, Equipment Type, Equipment Name, Work Order Number, Notes, and Status. Clicking a row picks the equipment for Edit, Copy, Delete and Generate Selected. | Tables | Active rows only, unless Show Deleted Equipment is on. Work Order Number column for Engineering only |  |
| `ShowDeletedEquipment` | Also lists deleted (inactive) equipment, adds the Status column and shows the Re Activate Equipment button. | Tables | Shown only to Engineering and Sales, and forced off for others. Default off |  |
| `SelectOlderRevision` + `EquipmentRevision` | "Equipment Revision to Open": the revision sent to the equipment project, which loads that revision's SQL row. | Tables | Development team only. Revision 1–100. Default: the Revision column of the selected row, but the list has no such column (see the notes) |  |
| `ShowPopUpEmailSent` | Shows the pop-up "Request Sent. Files are being generated. It could take up to 1 hour. You will receive an email with the files when they are ready." The release macros turn it on and its Ok button turns it off. | EmailToBeSentPopUp | The check box is shown to the Development team only. Default off |  |
| `ClientNumber`, `ProjectNumber` | Client and project numbers: the project's keys in SQL. DW Select Project sets them when it opens Order. | ForDevOnly | Development team only. 0–100 each, default 0 |  |
| `SpinButtonEquipmentList` | Index of the selected row in Equipment List; 0 means none. | ForDevOnly | Development team only, locked. Default: the row selected in Equipment List |  |
| `EquipmentNumberSelected` | "Equipment ID": the equipment number sent to the equipment project. | ForDevOnly | Development team only, locked. Default: Equipment Number of the selected row. Add New Equipment sets it to the project's highest equipment number + 1 |  |
| `DisplayEquipmentHost` | Shows the hosted equipment form over the whole window. | ForDevOnly | Development team only. Default off. Add and Edit turn it on |  |
| `EquipmentMode` | Add or Edit, sent to the equipment project as `Mode`. | ForDevOnly | Development team only. Add, Edit. No default set. Add New Equipment sets Add; Edit Equipment and Generate Selected set Edit |  |
| `RefreshEquipmentList` | Refresh counter. Each refresh lowers it by 1, which makes the SQL queries run again. | ForDevOnly | Development team only. −9999 to 0, default 0 |  |
| `ClientUsualColor`, `HostToOpen`, `MaxEquipmentNumber`, `State`, `CopyEquipmentText` | Computed fields: the client's preferred paint colour (SQL table `ClientListData`), the project that opens for the selected row's type, the highest equipment number, the spec's flow state, and the `CopyEquipment` SQL call. | ForDevOnly | Read-only. Development team only |  |

Left out on purpose: labels (the "Equipment Overview" title, "-XX", "User is …", the pop-up text), pictures (logo, search icons, footer, the conveyor and platform pictures of the Add pop-up, the grey mask behind it), frames, the section toggle `ForDevCheckExtend`, the host control `EquipmentHost`, the debug tables `ShowEquipmentInput` and `QuoteTesting`, and buttons. The buttons are described below.

## How Order creates, edits and releases equipment

### The hierarchy

Every record lives in the SQL Server database `SpartaDWdata`. Saving keeps no DriveWorks spec: opened from Order, Kit Conveyor and Platform Layout cancel their spec once their rows are written. Only a release leaves a spec in DriveWorks, and the next edit starts again from the SQL row.

| Level | SQL table | Key | Written by |
| --- | --- | --- | --- |
| Client | `ClientListData` | `ClientNumber`. `ClientTeam` is the client's name, and must be the DriveWorks team its users belong to | DW Select Project, Add New Team |
| Project | `ProjectListData` | `ClientNumber` + `ProjectNumber` | Order, document `ProjectListExport` |
| Equipment | `EquipmentListData` (view `ListOfEquipments`) | `ClientNumber` + `ProjectNumber` + `EquipmentNumber`. One row per equipment, holding its latest `Revision` | The equipment project, document `EquipmentListExport` |
| Equipment values | `DWKitConveyorData` or `DWPlatformLayout` | `ClientNumber` + `ProjectNumber` + `EquipmentNumber` + `Revision` | The equipment project, macro `ExportToDB` |
| Project type lookup | `DWProjectList` | `ProjectDescription` → `DWProjectName` | Not written by any project |

New numbers are the highest existing number + 1: Select does it for projects, Order for equipment. No macro in Order raises a revision: it sends the revision of the row, which only the Development team can change.

### The buttons

| Button | Macro | What it does |
| --- | --- | --- |
| Add New Equipment (`AddNewConveyor`) | Engineering: `AddNewEquipment`. Others: `AddNewEquipmentCustomer` | Sets Mode = Add. Engineering then gets a pop-up with New Conveyor and New Platform. Other users go straight to a new Kit Conveyor, as if they had clicked New Conveyor. |
| New Conveyor, New Platform (pop-up) | `AddNewConveyor` with "DW Kit Conveyor Project" or "DW Platform Layout" | Writes the ProjectListData row, sets Equipment ID to the highest equipment number + 1, loads that project as a new spec into `EquipmentHost`, shows it, and closes the pop-up. |
| Edit Equipment | `EditEquipment` (argument Edit) | Runs `UpdateChildInfo`, which writes Project Name and E2 Project Number to ProjectListData and to every `DWKitConveyorData` row of the project. Sets Mode = Edit, loads the project named for the row's type (next section), runs the child's `ImportFromDB` and shows it. |
| Copy Equipment | `CopyEquipment` | Runs SQL stored procedure `CopyEquipment` with client, project, equipment, revision, the new equipment number (highest + 1) and the project name without spaces, for example "DWKitConveyorProject". The procedure isn't in the project files. |
| Delete Equipment, Re Activate Equipment | `DeleteEquipment`, `ReActivateEquipment` | Set the row's `Status` in EquipmentListData to Inactive or Active. Nothing is deleted. |
| Generate Selected | `ReleaseSelectedEquipment` | Sets Mode = Edit, loads the row's project without showing it, runs the child's `ImportFromDB`, then its `GenerateModel`, which exports and releases the model. The button sends an argument (TRUE for non-Engineering) that the macro doesn't use. |
| Save and Close | `SaveAndCloseProject` | Writes the ProjectListData row, runs Select's `RunFromSpartaChildClose` (hide the host, clear the selection, refresh), then cancels the Order spec. |
| Cancel and Close | `CancelAndCloseProject` | Runs Select's `RunFromSpartaChildClose`, then cancels the Order spec without writing anything. |
| Send for Quotation | `SendForQuoting` | Runs Select's quote pop-up ("Your order is being processed…"), refresh and close-host macros, then the flow transition SendForQuoteManual (see "Flow states"). |
| Refresh Table, Clear Search | `RefreshEquipmentTables`, `ClearFilter` | Re-run the queries; empty both filters. |
| Development only | | Import From DB (reloads Order's own controls from its ProjectListData row), Export To DB, Save, Release Summary, Release Proposal, Order Quote Testing (runs `SendForQuoting`), Transition From Intermittent, Send To Intermittent. |

### Which project opens

- **Adding** uses fixed names: "DW Kit Conveyor Project" (New Conveyor, and every non-Engineering add) and "DW Platform Layout" (New Platform).
- **Edit, Generate Selected and Copy** look the name up. They take the selected row's `EquipmentType` from EquipmentListData, find it in `DWProjectList.ProjectDescription`, and open `DWProjectName`. Kit Conveyor writes as its type the description of `DWProjectNumber` 2 in DWProjectList, and Platform Layout writes "Platform". So both earlier statements are right: Add names the two projects, and the others read the name from DWProjectList.
- Light Duty Conveyor also calls Order's `RunFromSpartaChildClose` and `ShowPopUp`, so it is ready to be hosted, but no Add button offers it.

### What Order sends the equipment project

The host's InputValues are the Name/Value calc table `EquipmentHostInput`:

| Name in the child | Order's value | Notes |
| --- | --- | --- |
| `InputClientNumber` | `ClientNumber` | Key. The child reads the client name from ClientListData with it |
| `InputProjectNumber` | `ProjectNumber` | Key. The child reads the project name from ProjectListData |
| `InputEquipmentNumber` | `EquipmentNumberSelected` | Key |
| `Revision` | `EquipmentRevision` | Key |
| `Mode` | `EquipmentMode` | Add for a new equipment, Edit otherwise |
| `OpennedFromOrderProject` (constant) | TRUE | Switches on the child's "opened from Order" rules |
| `E2ProjectNumber` | `E2ProjectNumber` | The child locks it |
| `ReleaseStepOnly` (constant) | TRUE for non-Engineering users | Kit Conveyor only: a customer release, with files named after the equipment name and priority 1. It doesn't last: the Kit's `GenerateModel` first sets this constant from its own macro argument, which Order leaves empty. The Kit's own rule still makes every non-Engineering release a customer release. Platform Layout has no such name and ignores it |

Then, in Edit and Generate Selected, the child's `ImportFromDB` loads its own row (`DWKitConveyorData` or `DWPlatformLayout`, by the four keys) and drives every control whose name matches a non-empty column. It runs after the host inputs, so a column with the same name as a host input wins. The Kit's form is in [kit-conveyor-inputs.md](kit-conveyor-inputs.md), and Layout's in [platform-layout-inputs.md](platform-layout-inputs.md).

### How the equipment comes back

- **Kit Conveyor's Save and Close**, when opened from Order: `ExportToDB` writes `DWKitConveyorData` (150 columns, named after the Kit's controls) and the `EquipmentListData` row (type, name, work order number, a Notes summary of width, length and angle, revision, extra notes). It then runs Order's `RunFromSpartaChildClose` and cancels its own spec.
- **Platform Layout's Save and Close** does the same with `DWPlatformLayout` and `EquipmentListData`. Its release also exports, then runs Order's `RunFromSpartaChildClose` and `ShowPopUp`.
- **Order's own reads:** the list, the highest numbers and the types come from EquipmentListData. The quote (`FullProjectQuote`) reads 39 columns of `DWKitConveyorData`, from EquipmentNumber to ExtraNotes (BeltType is listed twice). Order reads nothing from `DWPlatformLayout`.

### A possible feed from the layout app

Write one row per level: ClientListData (if the client is new), ProjectListData, EquipmentListData with an `EquipmentType` found in DWProjectList, and the equipment's own row in `DWKitConveyorData` or `DWPlatformLayout`, whose column names are the equipment form's control names. Order's Edit Equipment or Generate Selected then loads and generates it. This follows from the macros above; confirm it with a test, including what `CopyEquipment` copies.

### Flow states

An Order spec starts in CustomerInput. Save and Close and Cancel and Close both cancel it, so DriveWorks keeps it only once it is sent for quotation (or saved by a developer). Send for Quotation goes through SentForQuoteAuto to WaitingForEngineering, which releases the costing Word sheet (`OrderQuoteWord`, from `FullProjectQuote`), an email to a hard-coded application-engineer address, the Prefilled Proposal, the Order Summary PDF, and the summary email to the customer. Transitions StartReview and Approved (or PushedToApproved) then lead to EngineeringReview and DesignApproved. No Order button runs them, so they are presumably run from the specification list. `ProjectListExport` copies the current state to `ProjectListData.DWFlowState`, and Select uses it to reopen the project (see [select-inputs.md](select-inputs.md)).

## Notes and open questions

- **Who counts as a Sparta user.** Here `IsUserInEngineering` tests the Engineering team only. Kit Conveyor and Platform Layout also count Xortion Engineering. `IsUserInSparta` (Engineering or Sales) shows E2 Project Number and Show Deleted Equipment. `IsUserInDevelopement` (team "Developement") shows the ForDevOnly page and the revision picker.
- **What a non-Engineering user gets.** This is the website path, and it is live. In the sandbox group, DW Select Project, DW Order Project and DW Kit Conveyor Project are the only projects open to every team: the customer teams (Metal7, Universite de Moncton, PremierTech, AMP Robotics), TestJonathanTeam, Sales and Xortion Engineering. Order itself is hidden, so they reach it from Select. They see Project Name, the filters and the list without the Work Order column. They can add, edit, copy, delete and generate equipment, save, cancel, and send for quotation.
  - Add New Equipment opens Kit Conveyor directly: there is no platform choice. Platform Layout and the other platform projects are open only to Administrators, Developement and Engineering. So in this group, website users reach Kit Conveyor only, not the platform projects as the other tables assume.
  - E2 Project Number is hidden, so the child gets the saved number or "XXXXX".
  - Their releases are customer releases, by Kit Conveyor's own team test.
  - Xortion Engineering users get this reduced Order, then the Engineering form inside Kit Conveyor.
  - DW Start Leg, which Kit Conveyor hosts to build the legs, is open only to Administrators, Developement and Engineering. Check that a customer's release still builds the legs.
- **No default is set** for Equipment Mode. Client Number and Project Number start at 0 until Select sends them.
- **Exports.** `ProjectListExport` writes ProjectListData (name, E2 number, client team name, created and modified user and time, Status Active, `LatestDWSpecificationID`, `DWFlowState`). The document stores a SQL login. The Word and email documents are listed under "Flow states". The Excel costing sheet `OrderQuote` is never released.
- **Release all.** Macros `Approve` and `CADandSave` release every equipment of the project in a loop (`ReleaseAllEquipment`), but no button or flow step runs them. Only Generate Selected releases, one equipment at a time.
- **Looks wrong, for Sparta engineering to confirm:**
  - **The wrong project can open.** The type comes from row n of table EquipmentListData, but the visible list and the Equipment ID come from row n of view `ListOfEquipments`, which the filters narrow. Neither query has an ORDER BY. With a filter on, or a different row order, Edit, Generate and Copy may open a Kit row in Platform Layout, or the reverse.
  - **Revision default.** `EquipmentRevision` reads a "Revision" column that the list query doesn't return, so check which revision a non-developer sends.
  - **The host may stay on screen.** Order's `RunFromSpartaChildClose`, which the children call when they close, sets `DisplayEquipmentInterface`. That is Select's control name; Order's is `DisplayEquipmentHost`. The Kit's Cancel and Close doesn't call Order back at all. Check in a test how the user gets back to the list.
  - **Stale E2 and project name in Platform Layout.** `UpdateChildInfo` updates `DWKitConveyorData` but not `DWPlatformLayout`, which also has an `E2ProjectNumber` column. Because `ImportFromDB` runs after the host inputs, an E2 number changed in Order may be overwritten by the layout's old one.
  - **Missing pieces.** `ReleaseSelectedEquipmentLocal` (no button runs it) calls `ReleaseToLocal`, which Kit Conveyor has but Platform Layout doesn't. WaitingForEngineering releases email `EmailForQuotingCustomer`, which doesn't exist.
  - **Quote state not saved.** In `SendForQuoting`, the step that sets `DWFlowState` = 'WaitingForEngineering' isn't connected, so it never runs.
  - **Small text errors.** From DesignApprovedEdit, Send for Quotation writes the user's display name into `ClientEmail` instead of `ClientFullName`. The quote email subject reads "Conveyor Project Quote Request Jeff- ". The proposal's address bookmarks are fixed text ("Address", "City, State/Province", and "Version 5.25.2021Version 5.25.2021Zip/Postal Code").
  - **Number limits.** Client Number and Project Number allow 0–100. Text-box limits don't seem to be enforced (2026-10-01 platform finding), but confirm before projects pass 100.
