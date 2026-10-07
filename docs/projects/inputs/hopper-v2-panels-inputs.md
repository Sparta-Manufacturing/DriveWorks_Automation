# DW Hopper V2 - Panels: form inputs

*Read from `DriveWorks Files/Hopper/DW Hopper V2 - Panels.driveprojx` as saved 2026-09-09 13:40. Written 2026-10-02 for Bruno's pre-sales layout app, which should use the same parameters as DriveWorks.*

This table lists every input on the DW Hopper V2 - Panels form, one bolted drop-zone panel of a DW Hopper V2 hopper, so the layout app can use the same parameter names.

- **DriveWorks Input**: the control name exactly as it appears in DriveWorks.
- **Description**: what the input is for, inferred from its caption, options and rules.
- **Group**: the form page the input sits on.
- **Limitation**: minimum, maximum, option list, or an override limit set by a rule. Empty when there is none.
- **Layout effect**: what the input changes in the panel's size or position in a layout. Empty when it changes neither.

## Inputs

Rows follow the form from top to bottom: the sections the left window stacks (CustomerInfo, PanelInfo, DropZone Bolt Calcs, then the Development-only ForDevOnly), then the two check boxes beside the Release button. The MidSectionInfo, Tables and DropZoneBackInfo pages hold no inputs; the first and last of these have 0 px frames. Paired controls share a row. Units are in the description, and defaults are at the end of the limitation, followed by what DW Hopper V2 sends when it hosts the panel ("V2:"). "V2: not sent" means the hosted panel keeps this project's default.

| DriveWorks Input | Description | Group | Limitation | Layout effect |
| --- | --- | --- | --- | --- |
| `CheckBox1_NewClientProject` | Switches Client and Project to the text boxes. | CustomerInfo | Driven by a rule: on when V2 sends a client (`HostedClientName`), otherwise blank. V2: on |  |
| `Client`, `TextBox1_Client` | Client: picked from a list, or the text box when New Client Project is on. Goes to the drawings' Client property. | CustomerInfo | List: every client in the ClientProjects group table. The text box shows `HostedClientName` when it is set. V2: V2's client, in the list and in `HostedClientName` |  |
| `Project`, `TextBox1_Project` | Project: picked from the client's projects, or the text box. Goes to the drawings' Project property. | CustomerInfo | List filtered by the chosen client (ClientProjects). The text box shows `HostedProjectName` when it is set. V2: V2's project |  |
| `WOPrefix` | Work order prefix. Starts every file name (`<prefix>-A32-K10-…`) and names the output folder. | CustomerInfo | Default: constant `WOPrefix`, which doesn't exist here, else the client's prefix in ClientProjects. The text shows `HostedWOPrefix` when it is set. Locked when constant `PushedDownShippingAssy` (also missing) is set. V2: V2's prefix, also as `HostedWOPrefix` |  |
| `AssemblyNumber` | Assembly number without the A: 30 back, 31 left, 32 right. Second part of every file name. | CustomerInfo | No default set. Locked while constant `AssemblyNumber` is set, unless Overwrite A Number is on. V2: 30, 31 or 32 (the project has a control and a constant with this name) |  |
| `StickerName` | Sticker name. Not programmed yet: it changes nothing in the model and is only saved with the spec. | CustomerInfo | Engineering only, and can't be reached (624 px in a 450 px frame). Its default reads `PrefixClientWO`, which doesn't exist here. V2: not sent |  |
| `KitNumber` | Kit number on its wall: tens digit = column, units digit = row (0 = bottom). Third part of every file name (`…-K10-…`). Kits 10, 20 and 30 always get a horizontal bottom flange. | CustomerInfo | No default set. Locked like Assembly Number. V2: the panel's kit, 10–42 on a side, 10–32 on the back |  |
| `OverwriteANumber` | Unlocks Assembly Number and Kit Number. | CustomerInfo | Shown only when constant `AssemblyNumber` is set. Default off. V2: not sent |  |
| `SafetyPartsColor`, `SafetyColorCode` | Safety parts colour and its read-only code. Not programmed yet: it changes nothing in the model and is only saved with the spec. | CustomerInfo | Options from the Colors group table. Can't be reached (624 px in a 450 px frame). V2: not sent |  |
| `PaintColor` | Paint colour, written to the parts' DWColor property. The colour code shows read-only below it (`TextBox_ColorCode`, Engineering only) and ends the panel's file names. | CustomerInfo | Options from the Colors group table. No default set. V2: V2's paint colour; the code is looked up again here |  |
| `WorkOrder` | Work order. Goes to the drawings' WO property. | CustomerInfo | Default: constant `WorkOrder`, which doesn't exist here, else the client's work order in ClientProjects. The text shows `HostedWorkOrderNumber` when it is set. V2: V2's work order |  |
| `DesignerDrafter` | Designer or drafter. Goes to the drawings' DrawnBy and EngineeredBy properties. | CustomerInfo | V2: "DriveWorks" |  |
| `HopperThickness` | Plate thickness (in). | PanelInfo | 0.125, 0.1875, 0.25, 0.375. No default set. V2: V2's Hopper Thickness | Panel thickness |
| `PanelSideLocation` | Wall the panel belongs to: R right, L left, B back. Picks the model family and which inputs show. | PanelInfo | R, L, B. No default set. V2: R for assembly 32, L for 31, B otherwise | Which wall |
| `BackLineProfile` | Shape of the panel's back end, where it meets the back wall, 1–7 (pictures `Form Design Documents/Panel Nomenclature/BackLineProfile - n.png`). 1 is straight; the others cut it for a back angle, with or without its bottom bend and end. First digit of the nomenclature. | PanelInfo | 1–7. No default set. V2: from its back-angle inputs and the panel's height band | Shape of the panel's back end |
| `FrontLineProfile` | Cross-section of the panel (pictures `FrontViewProfile - n.png`). On a side: 1 flat, 2 with the offset, 3 with the offset and its bottom bend. On the back: how the side offsets shape its edges. | PanelInfo | 1–5. Side panel models exist only for 1–4. No default set. V2: from that side's offset inputs | Panel cross-section |
| `SideProfile`, `TopProfile` | Side panels: the panel's outline (pictures `SideProfile - n.png`): 1 rectangle, 2–5 cut by the angled top. Back panels: Top Profile 1 is a full-width back panel, 2 and 3 the two halves of a split back. | PanelInfo | 1–5 each. Side Profile hidden for B; Top Profile shown only for B. No default set. V2 sends 0 for the other wall type, which isn't in the list, so it falls back to 1; no rule reads it there | Panel outline |
| `PanelNomenclature` | Read-only: wall letter + three profile digits, for example R111 or B215. Names the panel model used, one of 147. | PanelInfo | Read-only |  |
| `GoesOnWhatTypeOfEquipment` | Conveyor type, as text. Sets where the first bottom-flange hole starts and the flange's edge distance. | PanelInfo | Text, compared with "Kit Conveyor", "Ligth Duty Conveyor" (sic), "Light Duty Conveyor" and "Picking Conveyor" (see the notes). V2: its Conveyor Type |  |
| `PanelHeight` | Panel height (in). | PanelInfo | 0–100. Default 0. V2: from the panel's corner heights; back panels get their row height − 0.001 in | Panel height |
| `PanelLength` | Panel length (in) along the conveyor. Read only by side panel models. | PanelInfo | 0–100. Default 0. V2: the panel's length; blank for back panels | Panel length |
| `BottomFlangeWidth` | Bottom flange width (in). | PanelInfo | 0–100. Default 0. V2: on bottom-row kits (10, 20, 30, 40) 5.5 (Kit, Other), 4.5 (Light Duty) or 2.875 (Picking); 2.5 on the others |  |
| `BackAngle` | Back-end angle (deg). | PanelInfo | Hidden for Back Line Profile 1. 0–100. Default 0. V2: its Back Angle, or 90 − Conveyor Angle for panels above the end of a backward back angle | Slope of the panel's back end |
| `DimForStartOfBackAngle` | Height (in) on this panel where the back angle starts. | PanelInfo | Shown for Back Line Profiles 3, 4, 5 and 7. 0–100. Default 0. V2: start height − the panel's bottom height |  |
| `DimForEndOfBackAngle` | Height (in) on this panel where the back angle ends. | PanelInfo | Shown for Back Line Profiles 3 and 5. 0–100. Default 0. V2: end height − the panel's bottom height |  |
| `ConveyorAngle` | Conveyor incline (deg), for the plumb part above the end of the back angle. | PanelInfo | Shown for Back Line Profiles 3 and 5. 0–100. Default 0. V2: its Conveyor Angle |  |
| `IsTopFlangeStartOfBackAngle`, `IsTopFlangeEndOfBackAngle`, `IsBottomFlangeStartOfBackAngle`, `IsBottomFlangeEndOfBackAngle` | Back panels: makes the top or bottom flange horizontal where the back angle starts or ends on that edge. | PanelInfo | Shown only for B. Default off. V2: worked out per kit |  |
| `OffSetAngle` | Side panels: offset slope (deg). | PanelInfo | Hidden for B. 0–100. Default 0. V2: that side's Drop Zone Angle; 0 for back panels | Offset slope |
| `DropZoneBottomBendHeight` | Side panels: height (in) of the offset's straight start. | PanelInfo | Hidden for B. 0–100. Default 0. V2: that side's bottom bend height (the back's start height on a back panel) |  |
| `DropZoneOffSetWidth` | Side panels: offset width (in). | PanelInfo | Hidden for B. 0–100. Default 0. V2: that side's offset width; 0 for back panels | How far the panel steps out |
| `TopCutAngle` | Side panels: slope (deg) of the cut top edge (picture `SideProfile - 2.png`). | PanelInfo | 0–100. Default 0. V2: that side's angled top cut degrees, even when its check box is off; 0 for back panels | Top edge slope |
| `CSideCutLength` | Height (in) of the panel's head end (the C side) when the top is cut. | PanelInfo | 0–100. Default 0. V2: the panel's head-end height; 0 for back panels | Height at the head end |
| `EtchingType` | Etching style on the parts. | PanelInfo | Arrow, Cut through. No default set. V2: its Etching Type |  |
| `PanelLengthRightSide`, `PanelLengthLeftSide` | Back panels: width (in) right and left of the hopper's centre line. | PanelInfo | Shown only for B. 0–100. Default 0. V2: that row's half inside widths, including the offsets above the bottom row; 0 for side panels | Back panel width |
| `OffSetAngleRightSide`, `OffSetAngleLeftSide` | Back panels: slope (deg) of the side offsets at its edges. | PanelInfo | Shown only for B. 0–100. Default 0. V2: Drop Zone Angle Right and Left; 0 for side panels |  |
| `DropZoneBottomBendHeightRightSide`, `DropZoneBottomBendHeightLeftSide` | Back panels: offset bottom bend height (in) at its edges. | PanelInfo | Shown only for B. 0–100. Default 0. V2: both get the left side's value on kits 20–22 and the right side's otherwise |  |
| `DropZoneOffSetWidthRightSide`, `DropZoneOffSetWidthLeftSide` | Back panels: offset widths (in) at its edges. | PanelInfo | Shown only for B. 0–100. Default 0. V2: the offset widths, or 1 when an offset width is 0 |  |
| `BoltZone1A` … `BoltZone3C` | Heights (in) of the bolt-hole bands on the edge where a side meets the back wall. Zones 1–3 follow the back wall: below the back angle, along it, above its end. A–C follow the side: bottom bend, offset slope, above the offset. FALSE when a band isn't on this panel. | DropZone Bolt Calcs | Text boxes. V2: from its `BoltZoneTable` for this kit and wall |  |
| `OutputDXFFlatState`, `OutputPDF`, `Etching` | Output switches: DXF flat patterns, PDFs, etching. Not programmed yet: nothing reads them. | ForDevOnly | Development only. Default off. V2: not sent |  |
| `HighPriority` | High-priority job: priority tag 8 instead of 108. | Details | Engineering only. Default off. V2: its High Priority |  |
| `DevRelease` | Releases the panel as a development test (priority tag 99). | Details | Development team only. Default off; forced off for others. V2: its Dev Release |  |

Left out on purpose: labels, the profile pictures, frames, the section toggles (`…CheckExtend`), and the Close, Save and Close, and Release buttons.

## How Hopper V2 sets the panels

DW Hopper V2 is the parent ([hopper-v2-inputs.md](hopper-v2-inputs.md)). When a V2 spec reaches Completed, its `ReleaseAllPanels` macro loops over every enabled drop-zone panel: it loads this project into `SinglePannelHostControl` with the Name/Value calc table `DWCalcPanelListInput` as InputValues, then runs this project's `Release` macro. So there is one Panels spec per panel, named `<prefix>-A<n>-K<kit> - Hopper Panel - <id>`. V2's top-level assembly then swaps a dummy for each panel's `<prefix>-A<n>-K<kit>-<colour code>-YD-with Onsite Bolts` assembly.

The engine applies the table as found for the other hosted projects: names match a control or a constant, ignoring case; the first row with a name wins; unknown names are ignored; values are written as is, and a combo box whose value isn't in its list falls back to its first item.

| Panels input | Set from | Notes |
| --- | --- | --- |
| `AssemblyNumber` | 32 right, 31 left, 30 back | From the panel's wall in V2's `CleanPanelListTable` |
| `KitNumber` | The panel's kit number |  |
| `PanelSideLocation` | R for assembly 32, L for 31, B otherwise |  |
| `BackLineProfile`, `FrontLineProfile`, `SideProfile`, `TopProfile` | V2's per-kit profile variables (`BackLineProfileRightK10` and so on) | Side panels get Top Profile 0, back panels Side Profile 0; both fall back to 1 and are unused there |
| `PanelHeight`, `PanelLength`, `CSideCutLength` | The panel's corner points in V2 | Panel Length is blank, and C Side Cut Length 0, for back panels |
| `BottomFlangeWidth` | V2's standard flange for the conveyor type on bottom-row kits, else 2.5 |  |
| `BackAngle`, `DimForStartOfBackAngle`, `DimForEndOfBackAngle`, `ConveyorAngle` | V2's back-angle inputs, less the panel's bottom height |  |
| `OffSetAngle`, `DropZoneBottomBendHeight`, `DropZoneOffSetWidth`, `TopCutAngle` | That side's drop-zone inputs | 0 for back panels, except Bottom Bend Height. Read through `Indirect`, so a search for the input names misses them |
| `PanelLengthRightSide`, `PanelLengthLeftSide`, `OffSetAngleRightSide`, `OffSetAngleLeftSide`, `DropZoneBottomBendHeightRightSide`, `DropZoneBottomBendHeightLeftSide`, `DropZoneOffSetWidthRightSide`, `DropZoneOffSetWidthLeftSide` | V2's half widths and offsets | Back panels only; 0 on side panels |
| `BackPanelTopWidthRight`, `BackPanelTopWidthLeft` (constants) | The next row's half widths | Back panels only. Used by about 140 model rules each |
| `IsTopFlangeStartOfBackAngle` … `IsBottomFlangeEndOfBackAngle` | V2's per-kit lambdas |  |
| `BoltZone1A` … `BoltZone3C` | V2's `BoltZoneTable` for the selected kit and side |  |
| `EndOfBackAngleOnOff` (constant) | V2's End Of Back Angle | Picks bolt zone 3 or 2 for the forward section |
| `PanelStartInWhatBoltZone` (constant) | A per-row value; on bottom-row kits 1 with the back's bottom bend, else 2 | Nothing reads it here |
| `HopperThickness`, `EtchingType`, `GoesOnWhatTypeOfEquipment`, `PaintColor` | V2's inputs | Goes On What Type Of Equipment gets V2's Conveyor Type |
| `WOPrefix`, `Client`, `Project`, `WorkOrder` | V2's values |  |
| `HostedClientName`, `HostedProjectName`, `HostedWOPrefix`, `HostedWorkOrderNumber` (constants) | V2's values | They drive the Client, Project, Work Order and prefix text boxes, and turn New Client Project on |
| `DesignerDrafter` | "DriveWorks" |  |
| `HighPriority`, `DevRelease` | V2's check boxes |  |
| `HostedSpecificationId` (constant) | V2's spec ID | Names the output folder, `<prefix>-Hopper <id>` |
| `OpennedFromHost` (constant) | TRUE | Tested by a condition in the release flow |
| `PushedDownUserName`, `PushedDownUserEmail` (constants) | V2's user name and email | Nothing reads them here |
| `Index` | V2's panel counter | No such name here, so ignored |

**No parent sets:** `StickerName`, `SafetyPartsColor`, `SafetyColorCode`, `TextBox_ColorCode` (looked up again from the paint colour), `OverwriteANumber`, and the three output switches. Hosted panels keep their defaults.

**Nothing comes back.** No macro here runs in the parent. V2 just picks up the panel files from the output folder.

## Size and position in a layout

- **Units are inches.**
- **No position input.** A panel is placed by V2: its dummy instance sits on V2's row and column planes. In a layout, use V2's overall sizes ([hopper-v2-inputs.md](hopper-v2-inputs.md)); a single panel has no meaning on its own.
- **Size:** side panels are Panel Length × Panel Height, at most 48 × 36 in from V2. Back panels are Panel Length Right Side + Left Side wide (the half widths), and Panel Height high.
- **Shape:** the back end follows the back angle, the cross-section follows the side offset, and the top edge may be cut at Top Cut Angle, down to C Side Cut Length at the head end.

## Notes and open questions

- **How it is opened.** Only as a child of DW Hopper V2. In the sandbox group it is hidden and `Deployed=False` (V2 is visible, also `Deployed=False`). V2's host sits on its Tables page, which only the Development team sees, so only Development ever sees this form. Any user's V2 release still makes every panel.
- **Who counts as a Sparta user.** The form tests `IsUserInEngineering` (Engineering or Xortion Engineering) for the colour codes, Sticker Name and High Priority, and `IsUserInDevelopement` for ForDevOnly and Dev Release. Their values come from V2 anyway.
- **Missing constants.** The Visible rules of Client, Project, the client and project text boxes, New Client Project, WO Prefix, Work Order and Designer Drafter test `DWConstantPushedDownThicknessOfFloor`. WO Prefix's Enabled rule tests `DWConstantPushedDownShippingAssy`, and the WO Prefix and Work Order defaults read `DWConstantWOPrefix` and `DWConstantWorkOrder`. None of these exist in this project; they look copied from the platform projects. Check in Administrator whether these fields show.
- **Unreachable controls.** The frames are 450 px wide with their scroll bars hidden, and Sticker Name and Safety Parts Color sit at 624 px.
- **Conveyor-type text with typos.** `BottomFlange1stHoleStartDim` tests "Ligth Duty Conveyor", so a Light Duty hopper's first flange hole starts at 6 in instead of 4.3125 in. `BottomFlangeOutsideDimFromOutsideEdge` tests "Light Duty Conveyor" twice, so a Picking hopper gets 1 in instead of the 1.0625 in that V2's own rule gives. Sparta engineering should confirm the intended values.
- **No default is set** for Hopper Thickness, Panel Side Location, the four profile lists, Etching Type, Paint Color, Assembly Number, Kit Number, Client and Project. Every numeric box defaults to 0. V2 sends all of these.
- **Models.** 147 component sets, one per panel shape: 56 right (R`bfs`), 56 left (L`bfs`) and 35 back (B`b1f`), where b = Back Line Profile, f = Front Line Profile and s = Side Profile. Each file-name rule keeps only the set that matches the panel and deletes the rest. Back panels always use middle digit 1; Top Profile only switches features and instances inside the back models.
- **Exports.** There is no SQL table. On release the flow releases every document, which includes `NewClientProjects` (client, project, work order and prefix to the ClientProjects group table), so each panel adds a ClientProjects row. Files go to `\\192.168.0.19\Driveworks Output Files\<prefix>-Hopper <HostedSpecificationId>`. V2's own folder writes the ID as four digits (`Text(id, "0000")`), so check that both point at the same folder for IDs below 1000.
