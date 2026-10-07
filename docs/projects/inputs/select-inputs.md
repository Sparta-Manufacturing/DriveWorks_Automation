# DW Select Project: form inputs

*Read from `DriveWorks Files/DW Select Project.driveprojx` as saved 2026-05-11 08:40. Written 2026-10-02 for Bruno's pre-sales layout app, which should use the same parameters as DriveWorks.*

This table lists every input on the DW Select Project form, the list of a client's projects, so the layout app can use the same parameter names. Select isn't equipment: it is the entry point, where a user picks or creates a project, and it opens DW Order Project ([order-inputs.md](order-inputs.md)) for that project.

**Why Select and Order exist** (from the user):
- **The project information is stored in a SQL database outside DriveWorks,** not in DriveWorks specifications.
- **They give users an interface they can edit,** showing the right content for each user. Here, a customer sees only their own team's projects, while Engineering and Sales can pick any client.
- **With the data outside DriveWorks, tables and reports are easy to build** where DriveWorks can't make them.

So Select and Order are less about specific equipment and more about the user interface and data storage.

- **DriveWorks Input**: the control name exactly as it appears in DriveWorks.
- **Description**: what the input is for, inferred from its caption, options and rules.
- **Group**: the form page the input sits on.
- **Limitation**: minimum, maximum, option list, or an override limit set by a rule. Empty when there is none.
- **Layout effect**: what the input changes in the equipment's size or position in a layout. Empty when it changes neither, which is the case for every input here.

## Inputs

Rows follow the form from top to bottom: the header, the ShowTables page (the main window), then the AddNewTeam and ForDevOnly sections stacked at the bottom of the window, and the two pop-ups. Units are in the description, and defaults are at the end of the limitation.

| DriveWorks Input | Description | Group | Limitation | Layout effect |
| --- | --- | --- | --- | --- |
| `CustomerName`, `CustomerTeam` | The logged-in user name and team. The team is Administrators or Engineering when the user is in that team, else the user's whole team list. | Header | Read-only |  |
| `SelectedCustomerTeam` | "Selected Customer Team": the client whose projects are listed. Its `ClientNumber` in SQL table `ClientListData` is what Select sends to Order. | Header | Shown only to Engineering and Sales. List: every `ClientTeam` in ClientListData. Other users are forced to their own team. No default set |  |
| `FilterByProjectName` | Search box, "Filter By Project Name...". Keeps the projects whose name contains the text. Clear Search empties it. | ShowTables |  |  |
| `ListOfProjectTable` | The client's projects, read from SQL view `ListOfProjects`: Project Number, Project Name, E2 Project Number, and Status. Clicking a row picks the project for Edit, Copy and Delete. | ShowTables | Active projects only, unless Show Deleted Projects is on. E2 Project Number column for Engineering only |  |
| `ShowDeletedProjects` | Also lists deleted (inactive) projects, adds the Status column and shows the Re Activate Project button. | ShowTables | Shown only to Engineering and Sales, and forced off for others. Default off |  |
| `NewClientNumber` | Number of the new client: the highest `ClientNumber` in ClientListData + 1. | AddNewTeam | Read-only. Section shown only to Engineering and Sales |  |
| `NewClientTeam` | Name of the new client. It must be the exact name of the DriveWorks team its users log in with, because Select finds a user's projects by team name. Reset to "-" after Add New Client Team. | AddNewTeam | Default "Sparta" |  |
| `NewPreferedPaintColor` | The client's usual paint colour. Order shows it to developers; no equipment project reads it. | AddNewTeam | Options from the Colors group table. Default "Sparta Blue" |  |
| `NewClientPrefix` | Client prefix. No project reads it. | AddNewTeam | Default "SP" |  |
| `Address`, `CityStateProvince`, `ZipPostalCode` | Client contact address, city and postal code. Order prints them on the order summary. | AddNewTeam | Saved as "-" when empty |  |
| `ClientNumber` | Number of the selected client, sent to Order. | ForDevOnly | Read-only. Development team only |  |
| `SpinButtonProjectList` | Index of the selected row in the project list; 0 means none. | ForDevOnly | Development team only. Default: the row selected in the list |  |
| `ProjectNumberSelected` | Project number sent to Order. | ForDevOnly | Development team only, locked. Default: Project Number of the selected row. New Project sets it to the client's highest project number + 1 |  |
| `ProjectListMode` | Add or Edit. Set by New Project and Edit Project, but nothing reads it and it isn't sent to Order. | ForDevOnly | Development team only, locked. Add, Edit. No default set |  |
| `DisplayEquipmentInterface` | Shows the hosted Order form over the whole window. | ForDevOnly | Development team only. Default off. New Project and Edit Project turn it on |  |
| `RefreshProjectList`, `RefreshTeamList`, `RefreshEquipmentList` | Refresh counters. Each refresh lowers one by 1, which makes its SQL queries run again. The equipment counter only feeds a query nothing uses. | ForDevOnly | Development team only. −9999 to 0, default 0 |  |
| `TestCopy` | Computed: the last SQL result and the `CopyProject` call. | ForDevOnly | Read-only. Development team only |  |
| `ShowPopUpEmailSent`, `ShowPopUpEmailSentQuote` | Show the pop-ups "Request Sent. Files are being generated. It could take up to 1 hour…" and "Your order is being processed, you will be contacted by our sales department in the next 24 hours." Order turns them on; their Ok buttons turn them off. | PopUpEmailSent, PopUpQuoteSent | The check boxes are shown to the Development team only. Default off |  |

Left out on purpose: labels (the "Projects Overview" title, the pop-up texts), pictures (logo, search icon, footer), frames, the section toggles (`AddNewTeamCheckExtend`, `ForDevCheckExtend`), the host control `EquipmentInterfaceHost`, the team list table `ShowClientTeamList`, and buttons. The buttons are described below. The UserInfo page is empty (height 0).

## How Select opens DW Order Project

### The hierarchy

Select works on the first two levels of the hierarchy described in [order-inputs.md](order-inputs.md): a **client** is a row of SQL table `ClientListData` (key `ClientNumber`, name `ClientTeam`), and a **project** is a row of `ProjectListData` (key `ClientNumber` + `ProjectNumber`). The equipment of a project lives one level down, in Order.

- **A client is a DriveWorks team.** For a non-Sparta user, Select takes the user's team name and looks up the `ClientNumber` whose `ClientTeam` matches. In the sandbox group the customer teams are Metal7, Universite de Moncton, PremierTech and AMP Robotics.
- Engineering and Sales users pick any client in Selected Customer Team, and can create clients in the Add New Team section.

### The buttons

| Button | Macro | What it does |
| --- | --- | --- |
| New Project (icon, tooltip "Create New Project") | `AddProject` (argument Add) | Sets Project Number to the client's highest + 1, loads a new DW Order Project spec into `EquipmentInterfaceHost`, and shows it. No SQL row is written yet: Order writes the ProjectListData row when the user adds equipment or clicks Save and Close. |
| Edit Project | `EditProject` (argument Edit) | Loads a new Order spec for the selected project. If the project's `DWFlowState` is CustomerInput, it shows it. Otherwise it runs Order's `ToIntermittentStage` in it, which stores the new spec's ID as `LatestDWSpecificationID`, then reloads that spec by ID with transition "Was" + state (for example WasEngineeringReview), and shows it. |
| Copy Project | `CopyProject` | Runs SQL stored procedure `CopyProject` with the client, the project and the new project number (highest + 1), then selects the last row. The procedure isn't in the project files. |
| Delete Project, Re Activate Project | `DeleteProject`, `ReActivateProject` | Set the project's `Status` in ProjectListData to Inactive or Active. Nothing is deleted. |
| Close | `Cancel` | Cancels the Select spec. |
| Clear Search | `ClearFilter` | Empties the filter. |
| Add New Client Team | `AddNewTeamToSQL` | Writes a new ClientListData row (document `AddNewTeamInSQL`: number, team, paint colour, prefix, address, city, postal code), then refreshes the team list. |
| Save (Development only) | `Save` | Saves the Select spec. |

### What Select sends DW Order Project

The host's InputValues are the Name/Value calc table `ProjectHostInput`:

| Name in Order | Select's value |
| --- | --- |
| `ClientNumber` | `ClientTeamNumberFromDB`: the ClientNumber of the selected team |
| `ProjectNumber` | `ProjectNumberSelected` |

That is all. Order reads the project name, E2 number and client details from SQL with these two keys, and passes them on to the equipment.

### What Order calls back

Order runs these Select macros in its host: `RunFromSpartaChildClose` (hide the host, clear the selection, refresh the project list) from Save and Close and Cancel and Close; `ShowPopUpEmailSentQuote`, `RefreshProjectTables` and `CloseHostDisplay` from Send for Quotation; `ShowPopUpEmailSent` from Order's release-all macros, which no button runs.

### SQL tables

| Table | Key | Select reads | Select writes |
| --- | --- | --- | --- |
| `ClientListData` | `ClientNumber` | The team list, the selected team's number, the highest number | New clients (document `AddNewTeamInSQL`, which stores a SQL login) |
| `ProjectListData` (view `ListOfProjects`) | `ClientNumber` + `ProjectNumber` | The project list, the highest number, `DWFlowState`, `LatestDWSpecificationID` | `Status` only. Order writes the rows |

## Notes and open questions

- **Who counts as a Sparta user.** `IsUserInSparta` (Engineering or Sales) shows Selected Customer Team, Show Deleted Projects and the Add New Team section. `IsUserInEngineering` (Engineering only, not Xortion Engineering) adds the E2 Project Number column. `IsUserInDevelopement` (team "Developement") shows the ForDevOnly section.
- **What a non-Engineering user gets.** This is the website entry point, and it is live. Select is the only one of Select, Order and Kit Conveyor that is visible in the sandbox group, and it is open to every team. A customer sees their own projects only, with a filter. They can create, edit, copy and delete projects, and close. They can't pick another client or create one.
- **How Select relates to Order.** Select owns the project list, and Order owns one project's equipment list. Select hosts Order and sends only the two keys; Order hosts the equipment and sends the four keys (client, project, equipment, revision). Both are thin: all values travel through SQL.
- **No default is set** for Selected Customer Team (its stored design value is "Development", which isn't a team name) and Project List Mode.
- **Unused variables.** Nine variables have no reference, among them `WorkOrderInDataBase`, `ProjectNameIDataBase`, `EquipmentListDataLine`, `ClientUsualColor` and `DataLine` (a `DWKitConveyorData` test query).
- **Looks wrong, for Sparta engineering to confirm:**
  - **Users in several teams, or in an unknown team.** A non-Sparta user's client is their team name, or their whole team list when they are in more than one. If that value isn't a `ClientTeam` in ClientListData, the combo box falls back to its first item (`SelectedItemRemovedBehavior` = SelectFirst), so the user would see the first client's projects. Test with a login in two teams.
  - **Team name typo.** `UserTeam` tests "Development", but the team is "Developement". So a developer who isn't in Engineering or Administrators shows their whole team list as their team.
  - **Flow state.** Edit Project branches on `ProjectListData.DWFlowState`, but in Order the step that writes WaitingForEngineering isn't connected and the macro that writes DesignApproved isn't run by any button. So the state may stay CustomerInput, and Edit Project would always open a fresh Order. A state with no "Was…" transition (CustomerInputSaved, Cancelled, CancelledEdit, SentForQuoteAuto) would fail. Check which values ProjectListData holds.
  - **Duplicate clients.** Add New Client Team doesn't check whether the team name exists. Two rows with the same `ClientTeam` would make the client lookup ambiguous.
  - **New project numbers.** Only saved projects count toward the highest number, so two users who start a new project for the same client at the same time get the same number.
