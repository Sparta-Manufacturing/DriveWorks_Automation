# DW Platform Layout: form inputs

*Read from `DriveWorks Files/Platform/DW Platform Layout.driveprojx` as saved 2026-05-19 11:46. Written 2026-10-01 for Bruno's pre-sales layout app, which should use the same parameters as DriveWorks.*

This table lists every input on the DW Platform Layout form, the parent project that combines platforms, their handrails and the bolts between them into one layout, so the layout app can use the same parameter names.

**A system for any reasonable shape.** Platform Layout, Straight, Picking, the two HandRails projects and Bolts work together as one system, not a fixed product. Each platform is a rectangle with up to three zones per side, and platforms join zone to zone on any side. So most reasonable shapes and sizes can be built: long runs, L, U and T shapes, mixed widths, picking stations. The limits are each platform's size, 60 platforms and 15 shipping assemblies (see [Size and position in a layout](#size-and-position-in-a-layout)).

**What this means for a layout tool.** The flexibility comes from many inputs that depend on each other. Every platform needs:
- its size and zone widths;
- a connection type for every zone;
- the assembly number of each neighbour;
- a Mating To platform;
- a shipping assembly.

One wrong neighbour number moves a platform or drops a bolt set. Asking a non-Engineering user to fill these in one platform at a time would be very complicated. A small sketching tool would be much easier: the user draws the platforms and marks railings, stairs and ladders, and the tool works out these values. The tool could then fill Layout's platform list directly (see "A possible feed from the layout app" in the notes).

- **DriveWorks Input**: the control name exactly as it appears in DriveWorks.
- **Description**: what the input is for, inferred from its caption, options and rules.
- **Group**: the form page the input sits on.
- **Limitation**: minimum, maximum, option list, or an override limit set by a rule. Empty when there is none.
- **Layout effect**: what the input changes in the size or position of the platforms in a layout. Empty when it changes neither.

## Inputs

Rows follow the form from top to bottom: Customer Info, Common Info and Configurator (the main window), the footer, the developer pages inside the For Dev frame, then the Hidden Stuff page, which no frame shows. Paired controls share a row. Units are in the description, and defaults are at the end of the limitation.

The user types only the Customer Info and Common Info values in Layout itself. Everything about one platform (length, width, zones, connections, neighbours, shipping assembly) is typed in a hosted DW Platform - Straight or DW Platform - Picking form, shown inside Layout through `SpecificationHostControl1`. Those inputs are in [platform-straight-inputs.md](platform-straight-inputs.md) and [platform-picking-inputs.md](platform-picking-inputs.md).

| DriveWorks Input | Description | Group | Limitation | Layout effect |
| --- | --- | --- | --- | --- |
| `CheckBox1_NewClientProject` | Switches Client and Project to free text. | Customer Info | Default off. Forced on and locked when opened from DW Order Project |  |
| `ComboBox1_Client`, `TextBox1_Client` | Client: picked from a list, or typed when New Client Project is on. Sent to every child and to the drawings' Client property. | Customer Info | List: every client in the ClientProjects group table. From DW Order Project the text box shows instead, locked, with the client team read from SQL table `ClientListData` |  |
| `TextBox1_Project` | Project name. Sent to every child and to the drawings' Project property. From DW Order Project it is read from SQL table `ProjectListData`. | Customer Info | Shown only with New Client Project, and always locked. Its project picker, `ComboBox1_Project`, is on the Hidden Stuff page |  |
| `E2ProjectNumber` | E2 project number. Work order = E2 number + "-" + work order number. The work order goes to every child and to the drawings' WO property. | Customer Info | Engineering only. Locked when opened from DW Order Project, which sends it |  |
| `WorkOrderNumber` | "Work Order Number -": the work order number. | Customer Info | Engineering only |  |
| `TXTBox_ConveyorNaming` | "Prefix": the WO prefix. It names every file: the top level `<prefix>-Platform and Railing`, the shipping assemblies `<prefix>-S100` to `-S1500`, and the output folder `\\192.168.0.19\Driveworks Output Files\<prefix>`. Sent to every child as `WOPrefix`. | Customer Info | Default looked up from the ClientProjects group table: the WO prefix of the client's first row |  |
| `ComboBox_Colors` | Paint colour of the platforms. | Customer Info | 17 options from the Colors group table, including Custom. Default Sparta Blue |  |
| `TextBox_ColorCode` | Colour code of the paint colour. | Customer Info | Default looked up from the Colors group table. Editable only with Custom |  |
| `PaintRed`, `PaintGreen`, `PaintBlue` | RGB values of a custom paint colour. | Customer Info | Shown only with Custom. 0–255. Default 0 |  |
| `ColorName` | Name of a custom paint colour, saved to the Colors group table. | Customer Info | Shown only with Custom |  |
| `AlternateHandRailColor` | Gives the handrails their own colour. Off: the handrails take the paint colour. | Customer Info | Default off |  |
| `HandRailColor` | Handrail colour. Sent to the platforms, and to every railing spec as `Color`. | Customer Info | Options from the Colors group table. Shown only with Alternate Hand Rail Color. Default Galvanized |  |
| `HandRailColorCode` | Colour code of the handrail colour. | Customer Info | Shown only with Alternate Hand Rail Color. Default looked up from the Colors group table. Editable only with Custom |  |
| `HandRailRed`, `HandRailGreen`, `HandRailBlue` | RGB values of a custom handrail colour. | Customer Info | Shown only with Alternate Hand Rail Color and Custom. 0–255. Default 0 |  |
| `HandRailColorName` | Name of a custom handrail colour, saved to the Colors group table. | Customer Info | Shown only with Alternate Hand Rail Color and Custom |  |
| `TypeOfFloor` | Floor of every platform. Sent to the platforms as `PushedDownTypeOfFloor`. | Common Info | Checkered Plate, Grating. No default set |  |
| `ThicknessOfFloor` | Floor thickness (in). Sent to the platforms as `PushedDownThicknessOfFloor`. | Common Info | Checkered Plate: 0.1875, 0.25, 0.375, 0.5, 0.75. Grating, or no floor type: 0.75, 1, 1.25, 1.5, 1.75, 2, 2.25. No default set |  |
| `PlatformThickness` | Platform frame depth (in). Straight uses it as the height of the side frame members. Sent to the platforms, the railings and the bolts. | Common Info | 0–100. Default 8 | Depth of every platform frame |
| `MomentConnectionTopBottom` | Moment-connection bolting between platforms: bottom only, or top and bottom. Sent to the platforms as `PushedDownMomentConnectionTopBottom`. | Common Info | Bottom Only, Top and Bottom. No default set |  |
| `OverwriteDefaultRailingHeight` + `RailingHeight` | Railing height (in). Sent to the platforms (`PushedDownRailingHeight`) and to every railing spec. | Common Info | 43.25 in unless the check box is on; the box shows only then. Text box with Min/Max properties 20–60, which may not be enforced. Check box default off | Railing height above the platforms |
| `NoCutThroughInHandrail` | "No Cut Through In Handrail": no cut-through marks in the handrails. Sent to the platforms, which pass it on to the railings. | Common Info | Default on |  |
| `OutsideRailing` | Outside-mounted handrails. Every railing spec becomes DW HandRails outside instead of DW HandRails. | Common Info | Default off |  |
| `OverwritehandRailHeight` + `HandrailHeight` | Outside handrail height (in). Sent to every railing spec as `HandRailHeight`, which only DW HandRails outside has. | Common Info | Shown only with Outside Railing. 37 in unless the check box is on; the box shows only then. Text box with Min/Max properties 20–60. Check box default off | Height of the outside handrails |
| `EtchingType` | Etching style on parts. Sent to the platforms and the railings. | Common Info | Arrow, Cut Through. No default set |  |
| `DataTableControl1` | "List of Saved data": the platform list (`PlatformList` table), one row per platform with all its values. Clicking a row selects that platform for Edit or Delete. | Configurator | Read-only | The whole layout: every platform's size, zones, connections and shipping assembly |
| `SpecificationHostControl1` | **Hosted form.** ADD STRAIGHT PLATFORM, ADD PICKING PLATFORM and EDIT SELECTED PLATFORM open a DW Platform - Straight or - Picking spec here, over the whole window. The user types that platform's inputs there. Closing it writes the platform's row back to the list. | Details | Shown only while a platform is being added or edited | Each platform's length, width, zones, connections, neighbours and shipping assembly |
| `HighPriority` | High-priority job. Sent to every child. | Details | Engineering only. Default off |  |
| `DevRelease` | Releases the layout and every child as a development test (local release). | Details | Development team only. Default off |  |
| `InputClientNumber`, `InputProjectNumber`, `InputEquipmentNumber`, `Revision` | Keys of the layout's rows in SQL tables `DWPlatformLayout` and `EquipmentListData`. DW Order Project sets them. | For Dev | Development team only. Client 0–100, Project and Equipment 0–10000, Revision 1–100. Default 0, which is below Revision's minimum |  |
| `BigPlatformAssembly` | Adds the spec ID to the top-level name: `<prefix>-Platform and Railing-<id>`. | For Dev | Development team only. Default off |  |
| `LoopShipping`, `LoopRailing`, `LoopOnsiteBolts` | Read-only counts: shipping assemblies, railings and bolt sets that the top level inserts. | For Dev | Development team only |  |
| `Mode` | Add or Edit: whether the hosted platform is new or an existing row. | Platform Debug | Development team only, and locked. Set by the Add and Edit buttons, the release loops and DW Order Project |  |
| `TypeOfPlatform` | Straight or Picking: which project the host opens. | Platform Debug | Development team only, and locked. Set by the Add buttons. In Edit mode it is read from the selected row |  |
| `SpinButton1` | Selected platform row; 0 means none. The release loops drive it. | Platform Debug | Development team only. 0–100. Default = the row picked in the list |  |
| `RailingHostControl` | **Hosted form.** The DW HandRails or DW HandRails outside spec being released. | Railing Debug | Development team only |  |
| `SpinButton2` | Railing row within the current platform. The railing loop drives it. | Railing Debug | Development team only. 1–100 |  |
| `BoltsHostControl` | **Hosted form.** The DW Platform Bolts spec being released. | Onsite Bolts Debug | Development team only |  |
| `SpinButton3` | Bolt-set row within the current platform. The bolts loop drives it. | Onsite Bolts Debug | Development team only. 1–100. Default 0, below the minimum |  |
| `ComboBox1_Project` | Project picker, filtered by client. | Hidden Stuff | Never shown. So Project stays blank unless DW Order Project opened the layout |  |
| `TextBox1_DesignerDrafter` | Designer or drafter. Nothing reads it. | Hidden Stuff | Never shown |  |
| `CheckBox1_OutputDXFFlatState`, `CheckBox1_OutputPDF`, `CheckBox1_OutputStep`, `OutputEASM`, `CheckBox1_Etching` | Output switches sent to every platform: DXF flat patterns, PDFs, STEP files of bent parts, eDrawings, etching. Output PDF also makes the shipping-assembly PDFs. | Hidden Stuff | Never shown, so always off |  |
| `DisplaySpecificationHostControl1` | Shows the hosted platform form. Set by the macros. | Hidden Stuff | Never shown. Default off |  |

Left out on purpose: labels, pictures (logo, colour previews), masks, frames, the section toggles (`…CheckExtend`), the debug data tables, and buttons. The buttons are described below.

## How Platform Layout builds the platforms

The user confirmed the design: Layout is the main parent. It is mainly a big table plus empty assemblies. It captures what the user does in the hosted Straight and Picking forms. At release it loops through its tables and generates each platform, each handrail, and the bolts between shipping assemblies. It then puts the platforms into their shipping assemblies (SAs) and the SAs into the top-level assembly. The project has no child specification definitions: every child comes through the three host controls below.

### Host controls

Each host's `InputValues` rule points at a Name/Value calc table. Each Name is a child control or constant, and its Value sets it, as described in [start-leg-inputs.md](start-leg-inputs.md) §"How the conveyors set the legs". Unlike Start Leg, the platform children also receive constants (the `PushedDown…`, `Hosted…` and output values). From the engine code (`SpecificationHostControl.GetInputs`, read for the HandRails table):
- names ignore case;
- when a Name appears twice, the first row wins;
- a Name that the child doesn't have is ignored;
- values are written as is, with no check against the child's option list. A child combo box whose value isn't in its list then falls back to its first item, because every combo box in these projects is set to SelectFirst.

| Host control | Where, and who sees it | Hosts | Input table |
| --- | --- | --- | --- |
| `SpecificationHostControl1` | Details page, full window, while a platform is added or edited. Everyone | DW Platform - Straight when `TypeOfPlatform` is Straight, otherwise DW Platform - Picking (macro `SetHostControl`) | `DWCalcSpecInputValuesWList` |
| `RailingHostControl` | Railing Debug, inside the For Dev frame. That frame is 0 px high except for the Development team, but the release loop still uses the host | DW HandRails outside when `OutsideRailing` is on, otherwise DW HandRails | `DWCalcRailingListInput` |
| `BoltsHostControl` | Onsite Bolts Debug, inside the For Dev frame. The same applies | DW Platform Bolts | `DWCalcBoltsListInput` |

### Tables

- **`PlatformList`** (simple table, `DwLookupPlatformList`): **one row per platform**, 137 columns. Each row is the child's `ListToPlatform` list, which Straight and Picking build in the same column order. Picking sends 136 values: it has an Overwrite A Number check box but doesn't return it. Key columns:
  - `Index`, `TypeOfPlatform` (Straight or Picking), `ShippingAssembly`, `AssemblyNumber`;
  - `TotalLength`, `TotalWidth`, `NumberOfZoneFront`/`Right`/`Back`/`Left`, `WidthXn`, `ActualWidthXn`;
  - `ConnectionXn`, `ConnectedToXn`, `MatingTo`;
  - `FullFilePathAndName`: where the child saved its assembly, `…\<prefix>-A<n>-WithBolts.SLDASM`;
  - counts (`NumberOf…`), colours, `PlatformThickness`, and the corner flags `XnLeftLongForm`, `XnRightLongForm` and `OverWriteShortCorner…`.

  Here Xn stands for the 12 zones F1–F3, R1–R3, B1–B3 and L1–L3. The saved project holds 14 rows from a past job.
- **`LayoutMates`** (calc table, 60 rows): **one row per platform**, in list order. It holds the platform's file name, the platform it mates to (`MatesTo` = `MatingTo`), the zone used on each side (`MateZonePrimary`, `MateZoneSecondary`), its SA, and the plane names for three mates.
- **`LayoutShippingAssy`** (calc table, 15 rows): **one row per SA**, S100 to S1500. It holds the SA file, the first platform in it (`AinS`), the platform and SA that this platform mates to, the mate planes, and `Enable` = `Indirect("DWVariableIsS" & n & "00used")`.
- **`RailingList`** (calc table, 12 rows): **one row per zone F1…L3 of the current platform** (`SpinButton1`). A row is enabled when the zone's connection is Railing or Kick Plate. `Index` and `Letter` count the enabled zones (A, B, C…), and `AssemblyNumber` = "A" & the platform's number & the letter, for example A100A. `PostToPostWidth` = that zone's `ActualWidthXn`. The file is `\\192.168.0.19\Driveworks Output Files\<WOPrefix>\<WOPrefix>-A<n><letter>-With Onsite Bolts Assy.SLDASM`. `RailingListCalcTableClean` keeps the enabled rows.
- **`BoltsList`** (calc table, 12 rows): **one row per zone of the current platform**. A row is enabled when all three hold:
  - the zone's connection is Platform or Platform - Moment Connection;
  - its `ConnectedTo` number is higher than this platform's assembly number, so each joint is counted once;
  - the neighbour is in another SA.

  The file is `<WOPrefix>-OnSiteBolts-Assy-A<this>-A<neighbour>.SLDASM`, and `PlatformWidth` = the zone's `ActualWidthXn`. `BoltsListCalcTableClean` keeps the enabled rows.
- **`SpecInputValuesWList`** (135 rows), **`RailingListInput`** (47 rows) and **`BoltsListInput`** (7 rows): the Name/Value tables for the three hosts. They are mapped below.
- **Simple tables `RailingList` and `BoltsList`**: every railing and every bolt set of the whole layout. They are rebuilt by `FillTableRailing` and `FillTableBolts`, which delete the rows with Enable = True, then append each platform's enabled rows. The top level reads them.
- **Unused:** the `RailingInterference` calc table and the `TestTable` simple table. The macro tasks that write to `TestTable` are not connected.

### Adding and editing a platform

1. **ADD STRAIGHT PLATFORM** or **ADD PICKING PLATFORM** runs `AddPlatform` with "Straight" or "Picking". It sets `Mode` = Add and `TypeOfPlatform`, then `MacroSetSpecificationHostControl1` sets `SpinButton1` = 0, opens a new child spec in `SpecificationHostControl1` and shows it.
2. **EDIT SELECTED PLATFORM** runs `MacroSetSpecificationHostControl1` with "Edit". The selected row's values go to the child.
3. **The child calls back into Layout** when it closes:
   - `CloseAddMode` runs Layout's `RunFromSpartaChildAddMode`;
   - `CloseEditMode` runs `RunFromSpartaChildEditMode`;
   - `Cancel` runs `RunFromSpartaChildCancel`.

   The argument is the child's `ListToPlatform` pipe list. Layout stores it in constant `ListFromChild`, turns it into CSV by replacing `|` with `,`, then appends it to `PlatformList` (Add) or replaces row `SpinButton1` (Edit).
4. **Delete Selection** deletes the row with the selected `Index`. **Purge all data in List** deletes every row.

### Release loops

**Release all CAD** runs `Release`. So do `ReleaseToAutopilot` and `GenerateModel`, which DW Order Project calls. In order:

1. `Refresh` reopens every platform in Edit mode and runs its `CloseEditMode`. So each row is recomputed by the child, with Layout's current values.
2. Only when opened from DW Order Project: `ExportToDB`, then Order's `RunFromSpartaChildClose` and `ShowPopUp`.
3. `ReleaseAllChilds`, `ReleaseAllRailing` and `ReleaseAllBolts`, in the table below. `ReleaseAllRailing` runs `Refresh` again first.
4. The layout's own release: Release Local with Dev Release, otherwise Autopilot when it is enabled.

| Macro chain | Loops over | Each pass | Child spec created |
| --- | --- | --- | --- |
| `Refresh` → `RefreshSub` | Platforms, 1 to rows − 1 of `PlatformList` | `Mode` = Edit, `SpinButton1` = n, `SetHostControl`, run the child's `CloseEditMode` | None. It rewrites row n |
| `ReleaseAllChilds` → `ReleaseAllChildsSub` | Platforms | `Mode` = Edit, `SpinButton1` = n, `SetHostControl`, run the child's `ReleaseToAutopilot` | One DW Platform - Straight or - Picking per platform |
| `ReleaseAllRailing` → `…Sub` → `…SubSub` | Platforms, then that platform's rows in `RailingListCalcTableClean` | `SpinButton1` = n, `SpinButton2` = k, host DW HandRails outside or DW HandRails, run its `ReleaseToAutopilot` | One railing spec per Railing or Kick Plate zone |
| `ReleaseAllBolts` → `…Sub` → `…SubSub` | Platforms, then that platform's rows in `BoltsListCalcTableClean` | `SpinButton1` = n, `SpinButton3` = k, host DW Platform Bolts, run its `ReleaseToAutopilot` | One bolts spec per joint with a platform in another SA |

The spec flow then waits in **Waiting For Platform Generation**. Triggered action `PlatformGenerated` waits until every platform, bolt and railing file in the lists exists. **Layout Generating** then releases the models (the SAs and the top level) and waits for the layout PDF. **Layout Generated** writes the client, project, work order and prefix to the ClientProjects group table.

Other buttons:
- **Release Selected** releases the selected platform only.
- **Release Top Level Models** runs `FillTableBolts` and `FillTableRailing`, releases every model, then runs `ExportToDB`.
- **Refresh** runs `Refresh`.

### What Layout sends to Platform - Straight and Platform - Picking

Both get the same table, `DWCalcSpecInputValuesWList`. "Edit: row" means the value from the selected `PlatformList` row (`SpinButton1`). "Add" is the value for a new platform. A row with no Add value reads row 0 in Add mode. I checked in the DriveWorks rules engine that `TableGetValue` returns blank for row 0. "(constant)" marks a child constant, not a control.

| Child input | Set from | Notes |
| --- | --- | --- |
| `Index` | Edit: row. Add: highest `Index` + 1 |  |
| `Mode` | Layout's `Mode` (Add or Edit) |  |
| `WorkOrder` | `DWVariableWorkOrder` = `E2ProjectNumber` & "-" & `WorkOrderNumber` | Always Layout's value, also in Edit |
| `WOPrefix` | `DWVariablePrefixClientWO` (Prefix) | Always Layout's |
| `Client`, `Project` | `DWVariableClient`, `DWVariableProject` | Always Layout's |
| `Color`, `ColorCode`, `PaintRed`, `PaintGreen`, `PaintBlue` | `DWVariableColor`, `DWVariableColorCode`, `DWVariableCustomRed`/`Green`/`Blue` | Always Layout's |
| `HandRailColor`, `HandRailColorCode`, `HandRailRed`, `HandRailGreen`, `HandRailBlue` | `DWVariableHandRailColor`, `…HandRailColorCode`, `…CustomHandRailRed`/`Green`/`Blue` | The paint colour unless Alternate Hand Rail Color is on |
| `ShippingAssembly` | Edit: row. Add: 1 for the first platform, otherwise the SA of the last row |  |
| `PushedDownShippingAssy` (constant) | Edit: row. Add: the same value as `ShippingAssembly` |  |
| `AssemblyNumber` | Edit: row. Add: 100 × SA + the number of platforms already in that SA | The counters exist only for SAs 1–9. SAs 10–15 always get 100 × SA + 1 |
| `NumberOfZoneFront`, `…Right`, `…Back`, `…Left` | Edit: row. Add: 1 |  |
| `TotalLength` | Edit: row. Add: 120 | Above Straight's maximum of 119 with Checkered Plate |
| `TotalWidth` | Edit: row. Add: 48 |  |
| `WidthXn` (12) | Edit: row. Add: 24 |  |
| `ConnectionXn` (12) | Edit: row. Add: "Railing" |  |
| `ConnectedToXn` (12), `MatingTo` | Row. Blank in Add |  |
| `XnLeftLongForm`, `XnRightLongForm` (24) | Row. Blank in Add |  |
| `OverwriteANumber` | Row. Blank in Add | Picking never returns it, so it is blank for Picking rows |
| `MomentConnectionTopBottom` | Edit: row. Add: "Bottom Only" |  |
| `PushedDownMomentConnectionTopBottom` (constant) | Layout's `MomentConnectionTopBottom` |  |
| `NoStiffeners` | Edit: row. Add: "False" | Straight only |
| `OverWriteShortCornerFrontRight`, `…FrontLeft`, `…RightRight`, `…RightLeft`, `…BackRight`, `…BackLeft`, `…LeftRight`, `…LeftLeft` | Edit: row. Add: "False" | Straight only |
| `BinLength`, `BinWidth`, `BinBackHeight`, `FrontBinSpacing` | Edit: row. Add: 48, 36, 42, 36 | Picking only. In Edit, `BinBackHeight` looks for a column of that name, but the `PlatformList` column is `BinBackWidth`. The engine's `TableGetColumnIndexByName` returns NaN for a missing name |
| `PlatformThickness` | `DWVariablePlatformThickness` (Layout's input) | Always Layout's |
| `EtchingType`, `DevRelease`, `HighPriority` | Layout's inputs |  |
| `PushedDownTypeOfFloor`, `PushedDownThicknessOfFloor` (constants) | Layout's `TypeOfFloor`, `ThicknessOfFloor` |  |
| `PushedDownRailingHeight` (constant) | `RailingHeightReturn`: 43.25 unless overwritten |  |
| `NoCutThroughInHandrail`, `OutsideRailing` (constants) | Layout's inputs |  |
| `OutputEASM`, `OutputPDF`, `OutputStepFileBendParts`, `OutputDXFFlatState`, `DXFPNEtching` (constants) | The Hidden Stuff check boxes | Always off |
| `PushedDownNumberOf1LF`, `…2LBF`, `…3LF` (constants) | Sums of `NumberOf1LF`, `NumberOf2LBF`, `NumberOf3LF` over all rows | Whole-job counts |
| `NumberOf25LFinWO`, `PushedDownNumberOf35LP`, `PushedDownNumberOf35LPYD`, `NumberOfK40inWO`, `NumberOfK41inWO` (constants) | Sums of `NumberOf25LFinAssembly`, `NumberOf35LP`, `NumberOf35LPYD`, `NumberOfK40inAssembly`, `NumberOfK41inAssembly` over all rows | Whole-job counts |
| `PushedDownClientName`, `PushedDownClientEmail` (constants) | `DWVariableClientFullName`, `DWVariableClientEmail`: the current user's name and email |  |
| `HostedClientName`, `HostedWOPrefix`, `HostedWorkOrderNumber`, `HostedProjectName` (constants) | Client, Prefix, work order, Project |  |
| `FullFilePathAndName`, `NumberOf1LF`, `NumberOf2LBF`, `NumberOf3LF`, `TypeOfPlatform` | Row | Neither child has an input of that name, so they are ignored |

### What Layout sends to DW HandRails and DW HandRails outside

One railing is one enabled zone row of `RailingList` for the current platform (`SpinButton1`), picked with `SpinButton2`. Both projects get the same table, `DWCalcRailingListInput`. During release `Mode` is always Edit, so "row" means the current platform's `PlatformList` row. The HandRails inputs are in [handrails-inputs.md](handrails-inputs.md) and [handrails-outside-inputs.md](handrails-outside-inputs.md).

| Child input | Set from | Notes |
| --- | --- | --- |
| `Index` | `SpinButton2`: the railing's number on this platform |  |
| `Letter` (constant) | A, B, C… per railing on the platform | Outside only |
| `AssemblyNumber` | "A" & platform number & letter, for example A100A |  |
| `AssemblyNumberNoLocation` (constant) | "A" & platform number |  |
| `PostToPostWidth` | The zone's `ActualWidthXn` | Railing length (in) |
| `HandrailORKickPlate` | The zone's connection, raw: "Railing" or "Kick Plate" (`RailingList` column `RailingOrKickPlate`) | The platform's word is "Railing", the railing projects' word is "Handrail". "Railing" isn't in their list, so the combo box falls back to its first item, Handrail (`SelectedItemRemovedBehavior` = SelectFirst), and the railing is built. This works only while Handrail is listed first. DW HandRails outside has no kick plate, so there a Kick Plate zone gets a full guard railing |
| `ShortCornerLeft`, `ShortCornerRight` | "Long" when the platform's `XnLeftLongForm` or `XnRightLongForm` is on. Otherwise from `RailingList`: at a corner zone, the platform's `OverWriteShortCorner…` value; between zones, TRUE when the neighbouring zone is Platform or a Stairs type | "Long" is an option only in DW HandRails outside. In DW HandRails' check box it acts as off |
| `OutsideCornerLeft`, `OutsideCornerRight` | "Short" when `RailingList` finds a Railing zone around that corner, otherwise FALSE | Outside only |
| `RailingHeight` | `RailingHeightReturn`: 43.25 unless overwritten |  |
| `HandRailHeight` | `HandrailHeightReturn`: 37 unless overwritten | Outside only |
| `OverwriteRailingHeight` | Sent twice: FALSE, then Layout's `OverwriteDefaultRailingHeight` | The first row wins (engine code), so it is always FALSE. DW HandRails railings are therefore always 43.25 in. DW HandRails outside takes `RailingHeight` directly, so Layout's overwrite does reach outside railings |
| `PlatformThickness` | The row's `PlatformThickness` (8 in Add mode) |  |
| `NoCutThroughinHandrail` | The row's `NoCutThroughInHandrail` |  |
| `WorkOrder`, `WOPrefix`, `Client`, `Project` | Layout's values |  |
| `Color`, `ColorCode`, `PaintRed`, `PaintGreen`, `PaintBlue` | `DWVariableHandRailColor`, `…HandRailColorCode`, `…CustomHandRailRed`/`Green`/`Blue` |  |
| `EtchingType`, `DevRelease`, `HighPriority` | Layout's inputs |  |
| `HostedClientName`, `HostedWOPrefix`, `HostedWorkOrderNumber`, `HostedProjectName` (constants) | Layout's values |  |
| `NumberOf25LFinWO` (constant) | Sum over all platforms |  |
| `PushedDownClientName`, `PushedDownClientEmail`, `NumberOfK40inWO`, `NumberOfK41inWO` (constants) | The row's values | Used by DW HandRails only. Outside has the constants but nothing reads them |
| `OverwriteCheckAllFileOutputs`, `OverwriteOverhangCheck` (constants) | TRUE | DW HandRails: outputs on, overhangs forced off. Outside: only the STEP and eDrawings outputs reach a rule, and nothing reads the overhang check |
| `HolesForSideClips` | TRUE |  |
| `HoleFor90DegLadderLeft`, `HoleFor90DegLadderRight` | FALSE |  |
| `OverwriteCustomFloorPlateThicknessGap` | FALSE | DW HandRails only |
| `Location`, `ShippingAssembly`, `OutsideRailing`, `Enable<preThan10ftTopRail` | Zone, the platform's SA, Layout's input, FALSE | Neither project has these names, so they are ignored |

### What Layout sends to DW Platform Bolts

One bolt set is one enabled zone row of `BoltsList` for the current platform, picked with `SpinButton3`. See [platform-bolts-inputs.md](platform-bolts-inputs.md).

| Child input | Set from | Notes |
| --- | --- | --- |
| `WOPrefix` | Prefix |  |
| `ShippingAssembly1` | `AssemblyNumberPrimary`: this platform's assembly number | An assembly number, not an SA number, despite the name |
| `ShippingAssembly2` | `AssemblyNumberSecondary`: the zone's `ConnectedTo` number | The neighbour's assembly number |
| `PlatformWidth` | The zone's `ActualWidthXn` (in) |  |
| `PlatformThickness` | Layout's `PlatformThickness` |  |
| `DevRelease`, `HighPriority` | Layout's inputs |  |

### How the shipping assemblies are formed

- **Which SA a platform goes in:** its `ShippingAssembly` value, typed in the hosted form. A new platform starts in SA 1 if it is the first, otherwise in the SA of the last platform in the list.
- **SA files:** 15 component sets, S1 to S15, built from `DW05-ShippingAssyDummy.SLDASM` and named `<prefix>-S<n>00`. A set is deleted unless some platform's assembly number is between n00 and n99 (`IsS<n>00used`), and also, from S2 up, unless n is at most the highest SA number in use.
- **Filling an SA:** each SA is generated once per platform in the list (its loop count is the number of platforms). Pass k inserts platform k's `FullFilePathAndName` only if that platform's SA is n. Then three coincident mates come from `LayoutMates`.
- **The first platform in an SA** (the first row, or a row whose SA differs from the row above): Center L-R to the SA's Right plane, Center F-B to its Front plane, Top to its Top plane.
- **Every other platform:**
  - Its zone that connects to its `MatingTo` platform is found, searching R1–R3, F1–F3, L1–L3, then B1–B3.
  - That zone is mated to the zone of the `MatingTo` platform that connects back to it.
  - The two zone planes are coincident, the zone faces (`RightFace`, `LeftFace`, `FrontFace`, `BackFace`) touch, and the Top planes are coincident.
  - These rules assume that the list is grouped by SA, and that a platform's `MatingTo` is in the same SA.

### How the bolts between SAs are found

`BoltsList` is evaluated for each platform. A joint gets a DW Platform Bolts spec when the zone is Platform or Platform - Moment Connection and the neighbour is in another SA. The spec is created from the side of the lower-numbered platform. Joints inside one SA are not sent to Platform Bolts. Straight's own moment-connection bolt instances test `SameShippingAssy…` variables instead. In the top level, the bolt set's Top is mated to that platform's Top, its Front to the zone face, and its Right plane to the zone plane.

### How the handrails are placed outside the SAs

Railings are inserted into the top-level assembly, not into the SAs. Each railing is placed on its platform as follows:
- its Right plane is mated to the zone plane;
- its Front is mated to the zone face;
- its Top is mated to the platform's `TopRail` plane.

The user confirmed that the handrail logic still inside Straight and Picking (host `HostForRailing`, a `ReleaseAllChildsSub` loop that releases DW HandRails) is **intentionally inactive**. The handrails must sit outside the SAs, so Layout makes them.

### How the SAs go into the top-level assembly

The `DW05-MasterLayoutAssembly` set is named `<prefix>-Platform and Railing`. Its loop count is the number of SAs + bolt sets + railings (`NumberOfGenerationLoop`). In order:
1. **The SA passes** insert each enabled SA from `LayoutShippingAssy`:
   - SA 1's first platform: Center L-R to the layout's Right plane, Center F-B to Front, Top to Top.
   - Each other SA: its first platform's zone is mated to the zone of the platform it mates to in another SA, with the same three mates.
2. **The bolt passes** insert the bolt sets.
3. **The railing passes** insert the railings.

The drawing `<prefix>-Platform and Railing - <id>` is always saved as a PDF.

## Size and position in a layout

- **Units are inches.** Layout itself has no size or position input. Each platform's size is set in its hosted form:
  - `TotalLength` runs along the Left and Right sides, and `TotalWidth` along the Front and Back sides.
  - Each side has 1–3 zones (`NumberOfZone…`, `WidthXn`). Front and Back zones are numbered 1→3 from the left, and Left and Right zones 1→3 from the front (`Form Design Document/Strait Zone Pic.PNG`). In all 14 saved rows the Front and Back zones add up to `TotalWidth`, and the Left and Right zones to `TotalLength`.
  - Straight allows a length of 12–119 in (120 with Grating) and a width of 16–100 in (60 with Grating). Picking allows 24–120 by 18–95 in.
- **Position comes only from connections. There are no X/Y offsets.**
  - The first platform in the list sits at the layout origin, with its centre planes on the origin planes.
  - Every other platform is placed against its `MatingTo` platform: the two connected zones are set face to face, with their zone planes coincident. Straight and Picking drive each zone plane with a `HalfWidthZone…` value (`DistanceXn@Zones`), so the planes mark each zone's centre (confirmed from the child side), and the two zones are centred on each other.
  - The offset along a shared side therefore comes from the zone widths.
  - Any side can meet any side, so a platform can be turned 90° or 180° relative to its neighbour.
- **Connection types** (from the children's option list): Open, Platform, Railing, Kick Plate, Stairs (Sitting On Top), Stairs (Attached to Side), Rung Ladder, plus Platform - Moment Connection on a front or back side with one zone. `ConnectedToXn` holds the neighbour's assembly number. Markers such as `x` and `R` in the saved rows mean no neighbour.
- **Elevation:** every platform's Top plane is mated to its SA's Top plane, and each SA to the layout's Top plane. So all platforms in a layout share one top level. Layout has no elevation, leg or support input. What it does set is the frame depth (`PlatformThickness`) and the railing heights (`RailingHeight`, `HandrailHeight`) above the platforms.
- **Overall footprint:** Layout doesn't compute one. The layout app has to work it out from the platform sizes and the connections.
- **Stairs and ladders:** a zone can be marked Stairs (Sitting On Top), Stairs (Attached to Side) or Rung Ladder. Layout creates no DW Stairs or DW Ladder spec, and no railing or bolts at those zones. It uses the Stairs types only to make the neighbouring railing corner short, and it sends `HoleFor90DegLadderLeft`/`Right` = FALSE to every railing. This confirms, from Layout's side, that no project opens DW Ladder or DW Stairs ([ladder-inputs.md](ladder-inputs.md), [stairs-inputs.md](stairs-inputs.md)). `Zone Length Reference.docx` gives the zone lengths for them:
  - a standard 24 in ladder needs a 32 in opening;
  - stairs attached to the side need zones of stair width + 0.25 in;
  - stairs sitting on top need end zones (Z1, Z3) of stair width + 0.375 in and a middle zone (Z2) of stair width + 0.25 in.
- **Limits:**
  - `LayoutMates` has 60 rows, so at most 60 platforms get mates.
  - There are 15 SAs.
  - Each platform can have at most 12 railings or bolt sets, one per zone.

## Notes and open questions

- **Who counts as a Sparta user.** The form tests `IsUserInEngineering` (Engineering or Xortion Engineering) for E2 Project Number, Work Order Number and High Priority. It tests `IsUserInDevelopement` for Dev Release and the For Dev frame. `IsUserInSparta` exists but nothing uses it.
- **What a non-Engineering user gets.** The user says this path is live, and that website users reach the platform projects. The sandbox group's security tables disagree: there, Platform Layout and its children are open only to Administrators, Developement and Engineering, and Order's Add button sends non-Engineering users straight to Kit Conveyor ([order-inputs.md](order-inputs.md)). Confirm against production. They see Customer Info, Common Info and the Configurator in full. They can add, edit, delete and release platforms, and release all CAD. Problems on this path:
  - Without E2 Project Number and Work Order Number the work order is "-", or "<E2>-" when DW Order Project sends the E2 number. It goes to every child, to the drawings' WO property and to the ClientProjects table.
  - Opened on its own, the client list shows all 74 clients in the ClientProjects table. Layout is hidden in the group, so website users probably arrive through DW Order Project, where the client is locked.
  - Opened on its own, Project can't be set at all: the text box is always locked and the picker is on a page no frame shows.
  - The output switches are off for everyone, Engineering included.
- **No default is set** for Type Of Floor, Thickness Of Floor, Moment Connection Top/Bottom, Etching Type, Client, Project, E2 Project Number and Work Order Number. Confirm what a new layout starts with.
- **A possible feed from the layout app.** `ExportToDB` writes SQL table `DWPlatformLayout`, keyed by client, project, equipment number and revision. It holds the common inputs plus the whole `PlatformList` as CSV. It also writes an `EquipmentListData` row (type "Platform", name = Prefix, "Platform Count = n"). DW Order Project's Edit and Release equipment macros run Layout's `ImportFromDB`, which rebuilds the form and the list from that row, then run `GenerateModel`. Because every release starts with `Refresh`, the children recompute their calculated columns. So a layout app may only need to fill the input columns of `PlatformList` and the common inputs. Confirm with a test.
- **Other exports:**
  - Every Autopilot release writes the paint and handrail colours to the Colors group table (`NewColourSpecs`).
  - "Layout Generated" writes the ClientProjects row.
  - Two emails go out, to the user and to a hard-coded admin address.
- **DW Order Project.** Its `NewPlatform` button runs `AddNewConveyor` with "DW Platform Layout" and hosts Layout in its `EquipmentHost`. Its `EquipmentHostInput` table sends:
  - `InputClientNumber`, `InputProjectNumber`, `InputEquipmentNumber`, `Revision`;
  - `Mode` (Add for new equipment, Edit for edits and releases; see [order-inputs.md](order-inputs.md));
  - constant `OpennedFromOrderProject` = TRUE;
  - `E2ProjectNumber`.

  It also sends `ReleaseStepOnly`, which Layout doesn't have. Layout calls back Order's `RunFromSpartaChildClose` and `ShowPopUp`. Layout uses the same `Mode` input for its own Add/Edit platform state.
- **The children in the sandbox group.** Straight, Picking, Bolts and Layout are hidden and deployed. DW HandRails is deployed. **DW HandRails outside is `Deployed=False`**, yet Layout hosts it whenever Outside Railing is on.
- **Looks wrong, for Sparta engineering to confirm:**
  - **Railing zones rely on a fallback.** Layout sends `HandrailORKickPlate` = "Railing", which isn't in the railing projects' list "Handrail|Kick Plate". The combo box falls back to its first item, Handrail, so the railing is built. If Kick Plate were ever listed first, every Railing zone would become a kick plate. Sending "Handrail" would remove that dependency ([handrails-inputs.md](handrails-inputs.md)).
  - **Layout's railing-height overwrite never reaches inside railings.** `OverwriteRailingHeight` is sent twice and the first row, FALSE, wins, so DW HandRails railings are always 43.25 in.
  - **Assembly numbers past SA 9.** New platforms in SAs 10–15 all get 100 × SA + 1, unless Overwrite A Number is used. Duplicate numbers would break the mate lookups, which search by assembly number. The 14 saved rows already contain two platforms numbered 1101 in SA 11.
  - **The list must be grouped by SA.** A platform counts as first in its SA when its SA differs from the row above. A list such as SA 1, 2, 1 would put the third platform on the SA origin.
  - **Bin Back Height.** It looks for column `BinBackHeight`, but the column is `BinBackWidth`. Since every release refreshes every platform in Edit mode, Picking platforms may lose that value.
  - **New Straight platforms start above the length maximum.** The Add default length of 120 in is above Straight's 119 in maximum with Checkered Plate.
  - **Debug exports.** `ReleaseAllRailingSub` and `…SubSub` write text files to `C:\Users\oligod\OneDrive - Sparta Manufacturing\Desktop\text\` during every release, and Straight's close macros do the same.
  - **Loop counter overwritten.** `ReleaseAllRailingSubSub` overwrites its own loop counter constant with "inside" or "outside" on each pass.
  - **Email sent too early.** The "layout is generated" email, which attaches the layout PDF, is sent on entering Waiting For Platform Generation, before the layout PDF is made.
  - **Missing macro.** Order's `ReleaseSelectedEquipmentLocal` runs `ReleaseToLocal` in Layout, but Layout has no macro of that name.
  - **Commas break the CSV.** The child's list becomes CSV by swapping `|` for `,`, so a comma inside a value (a client or project name, for example) would shift the columns.
  - **Stray zeros.** Client Number allows only 0–100. Opened on its own, Release Top Level Models exports a SQL row with all keys 0. `SetOnsiteBoltsHost`, which no button runs, puts Platform Bolts into the railing host.
