# DW Platform - Picking: form inputs

*Read from `DriveWorks Files/Platform/DW Platform - Picking.driveprojx` as saved 2025-09-08 13:10. Written 2026-10-01 for Bruno's pre-sales layout app, which should use the same parameters as DriveWorks.*

This table lists every input on the DW Platform - Picking form, the platform with a picking hopper (bin) that DW Platform Layout hosts once per platform, so the layout app can use the same parameter names.

- **DriveWorks Input**: the control name exactly as it appears in DriveWorks.
- **Description**: what the input is for, inferred from its caption, options and rules.
- **Group**: the form page the input sits on.
- **Limitation**: minimum, maximum, option list, or an override limit set by a rule. Empty when there is none.
- **Layout effect**: what the input changes in the platform's size or position in a layout. Empty when it changes neither.

## Inputs

Rows follow the form from top to bottom: Header (titled Customer Info), CommonInfo, PlatformSize and RailingChildForm (the frames of the main window), then the Details footer. The 12 zones F1–F3, R1–R3, B1–B3 and L1–L3 share one row per field, written with Xn. Units are in the description, and defaults are at the end of the limitation.

The form normally runs inside Platform Layout ([platform-layout-inputs.md](platform-layout-inputs.md)), which sets most inputs. "Layout: X for a new platform" means the value Layout sends in Add mode; in Edit mode Layout sends the platform's saved row. "Hidden when hosted" means the field is hidden when Layout sends a floor thickness (`PushedDownThicknessOfFloor`), which is the normal hosted case. Then the Header shows only Shipping Assembly, Assembly Number and Overwrite A Number, and it starts collapsed.

| DriveWorks Input | Description | Group | Limitation | Layout effect |
| --- | --- | --- | --- | --- |
| `CheckBox1_NewClientProject` | Switches Client and Project to free text. | Header | Default off. Forced on when Layout sends the client (`HostedClientName`). Hidden when hosted |  |
| `Index` | This platform's row number in Layout's platform list. | Header | Locked. 0–9999. Default 0. Set by Layout: highest index + 1 for a new platform. Hidden when hosted |  |
| `Mode` | Add or Edit. Save & Close runs `CloseAddMode` or `CloseEditMode` from it. | Header | Add, Edit. Locked. Set by Layout. No default set, so opened on its own Save & Close has no macro to run. Hidden when hosted |  |
| `TextBox1_Client`, `Client` | Client: typed, or picked from a list. Written to the parts' Client property. | Header | List from the ClientProjects group table. The text box shows Layout's client when hosted. The list sits at the bottom of the page, below the frame's edge unless the paint colour is Custom. Hidden when hosted |  |
| `TextBox1_Project`, `Project` | Project: typed, or picked from the client's projects. Written to the parts' Project property. | Header | List filtered by the chosen client, placed like the client list. The text box shows Layout's project when hosted. Hidden when hosted |  |
| `WOPrefix` | "Work Order Prefix". It starts every file name, `<prefix>-A<n>-…`, and names the output folder `\\192.168.0.19\Driveworks Output Files\<prefix>`. | Header | Default rule refers to a constant `WOPrefix` that this project doesn't have. Set by Layout: always Layout's prefix, and locked. Hidden when hosted |  |
| `DesignerDrafter` | Designer or drafter, written to the parts' DrawnBy property. | Header | Layout doesn't send it. Hidden when hosted |  |
| `WorkOrder` | Work order, written to the parts' WO property. | Header | Default rule refers to a constant `WorkOrder` that this project doesn't have. Set by Layout: always Layout's work order. Hidden when hosted |  |
| `AlternateHandRailColor` | Gives the handrails their own colour. Off: the handrail colour is the paint colour. | Header | Default off. Forced on when Layout sends the SA (`PushedDownShippingAssy`), so Layout's handrail colour is kept. Hidden when hosted |  |
| `Color` | Paint colour. Its colour code goes into the part file names (`…-K1-<code>`). | Header | Options from the Colors group table. Default Sparta Blue. Set by Layout: always Layout's colour. Hidden when hosted |  |
| `HandRailColor` | Handrail colour. The platform model doesn't use it. It goes back to Layout in the platform row. | Header | Options from the Colors group table. Default Galvanized, but it shows Sparta Yellow while Alternate Hand Rail Color is off. Set by Layout. Hidden when hosted |  |
| `ColorCode`, `HandRailColorCode` | Colour codes of the paint and handrail colours. | Header | Default looked up from the Colors group table. Editable only with Custom. Set by Layout. Hidden when hosted |  |
| `PaintRed`, `PaintGreen`, `PaintBlue` | RGB values of a custom paint colour. | Header | Shown only with Custom. 0–255. Default 0. Set by Layout |  |
| `HandRailRed`, `HandRailGreen`, `HandRailBlue` | RGB values of a custom handrail colour. | Header | Shown only with Alternate Hand Rail Color and a Custom handrail colour. 0–255. Default 0. Set by Layout |  |
| `ColorName`, `HandRailColorName` | Names of custom colours, saved to the Colors group table on release (`NewColourSpecs`). | Header | Shown only with Custom (the handrail one also needs Alternate Hand Rail Color). Layout doesn't send them |  |
| `ShippingAssembly` | Shipping assembly (SA) this platform ships in. A neighbour whose Connected To number has the same hundreds is in the same SA, and the bolts to it are then part of this platform. | Header | 0–100, while Layout has only SAs 1–15. Default 1. Layout: 1 for the first platform, otherwise the last row's SA | The SA the platform is placed in |
| `AssemblyNumber` | "Assembly Number": the platform's number without the A, for example 101. It names the files (`<prefix>-A101-WithBolts`), and neighbours type it in their Connected To. The bin is numbered 50 higher (A151). | Header | Locked unless Overwrite A Number is on. Layout: 100 × SA + the platforms already in that SA, for a new platform. Reset to 100 × Shipping Assembly when the SA differs from the one Layout sent and Overwrite A Number is off. Opened on its own: 100 × SA | The platform's identity in the layout: Connected To and Mating To refer to it |
| `OverwriteANumber` | "Overwrite A Number": unlocks Assembly Number. | Header | Default off. Not returned to Layout, so it is off again at every edit |  |
| `TypeOfFloor` | Floor type. Grating: 1 in grating panels in one or two pieces. Checkered Plate: one or two top plates held by carriage bolts. | CommonInfo | Checkered Plate, Grating. No default set. Set by Layout: always Layout's floor type, and locked | Unlike Straight, it doesn't change the size limits |
| `RailingHeight` | Railing height (in). Not programmed yet: it changes nothing in the model and is only saved with the spec. It isn't in the row sent back to Layout either. Layout sends its own railing height to the railing specs. | CommonInfo | Locked to Layout's railing height (`PushedDownRailingHeight`, 43.25 unless overwritten). No default set |  |
| `PlatformThickness` | Frame depth (in): the height of the frame members. Below 8 in their flanges narrow to 0.625 × depth; from 8 in they are 5 in. | CommonInfo | 0–100. Default 8. Locked except for the Development team. Set by Layout: always Layout's value | Depth of the platform frame |
| `ThicknessOfFloor` | Floor thickness (in). It only changes the grating's Description property and the 3D preview. No model dimension reads it: the modelled grating stays 1 in thick. | CommonInfo | Checkered Plate: 0.1875, 0.25, 0.375, 0.5, 0.75. Grating: 0.75, 1, 1.25, 1.5, 1.75, 2, 2.25. No default set. Set by Layout: always Layout's value, and locked |  |
| `MomentConnectionTopBottom` | Moment-connection bolting: bottom only (2 splice plates) or top and bottom (4). | CommonInfo | Bottom Only, Top and Bottom. No default set. Forced to Layout's value (`PushedDownMomentConnectionTopBottom`) |  |
| `EtchingType` | Etching style on the parts: an arrow, or a cut-through. | CommonInfo | Arrow, Cut Through. No default set. Set by Layout |  |
| `NumberOfZoneFront`, `NumberOfZoneRight`, `NumberOfZoneBack`, `NumberOfZoneLeft` | Number of zones on each side. | PlatformSize | 1–3. Default 0, below the minimum. Layout: 1 for a new platform | How many zones, and zone planes, that side has |
| `TotalWidth` | "Total Width (in)", along the Front and Back sides. | PlatformSize | 18–95 in, for both floor types. Default 0, below the minimum. Layout: 48 for a new platform | Width. The model can be up to 0.4375 in wider per 36 in Platform zone (see below) |
| `TotalLength` | "Total Length (in)", along the Left and Right sides. | PlatformSize | 24–120 in. Error when the modelled length passes 120 in. Default 0, below the minimum. Layout: 120 for a new platform | Length |
| `WidthXn` | "Width Zone Xn" (in). Front and Back zones count from the left, Left and Right zones from the front. Only the first one or two are typed: with one zone, zone 1 = the side's total; with two, zone 2 = total − zone 1; with three, zone 3 = total − zone 1 − zone 2. | PlatformSize | Text boxes. Zone 1: up to total − zones 2 and 3. Zone 2: up to total − zone 1. Left and right zones have a minimum of 11. Shown only when the zone exists. Layout: 24 for a new platform | Zone length along that side. Sets where the zone plane sits (the zone centre) and the railing length |
| `ConnectionXn` | "Connections": what meets that zone. | PlatformSize | Open, Platform, Railing, Kick Plate, Stairs (Sitting On Top), Stairs (Attached to Side), Rung Ladder. F1 and B1 add Platform - Moment Connection when their side has one zone. A zone that doesn't exist is forced to Open. No default set. Layout: Railing for a new platform | What the edge meets: a neighbour, a railing, a kick plate, stairs, a ladder or nothing |
| `ConnectedToXn` | "Connected To": the assembly number of the platform on that zone. It becomes R for Railing and x for anything else. | PlatformSize | Shown only for Platform and Platform - Moment Connection. Nothing checks it against real numbers. Layout: blank for a new platform | The neighbour on that zone |
| `MatingTo` | "Mating To": the platform this one is placed against. | PlatformSize | Options: the Connected To numbers typed on this platform, plus Origin. Error when blank or x. Forced to Origin when `DWParentRowIndex` = 1. Layout: blank for a new platform | Position: this platform is mated zone to zone to that neighbour. Origin = the layout origin |
| `BinWidth` | "Bin Width" (in): the picking hopper's width, across the platform. | PlatformSize | 12 in to 42 in, or to total width − 7.5 in when the platform is 59 in wide or less. Default 0, below the minimum. Layout: 36 for a new platform | Hopper width. Its right side is 4.3125 in from the platform's right edge |
| `FrontBinSpacing` | "Front Bin Spacing" (in): from the front edge to the hopper. | PlatformSize | 10 in to total length − 24 in. Default 0, below the minimum. Layout: 36 for a new platform | Hopper position along the length |
| `StandartBinHeight` | "Standart Bin Height": uses the standard 42 in back wall. | PlatformSize | Default off. Layout doesn't send it |  |
| `BinBackHeight` | "Bin Back Height" (in): height of the hopper's back and side walls above the floor. The front wall is fixed at 34.25 in. | PlatformSize | 30–50 in. Shown only while Standart Bin Height is off. Default 0, below the minimum. Layout: 42 for a new platform; in Edit, Layout reads a column that doesn't exist (see notes) | Height of the hopper above the floor |
| `BinLength` | "Bin Length" (in): the hopper's length, along the platform. | PlatformSize | Text box. No default set. Back Bin Spacing must stay at least 10 in. Layout: 48 for a new platform | Hopper length |
| `BackBinSpacing` | "Back Bin Spacing" (in): from the hopper to the back edge = total length − bin length − front bin spacing. | PlatformSize | Read-only. Error when under 10 in |  |
| `XnLeftLongForm`, `XnRightLongForm` | "Xn Left Long", "Xn Right Long": a long inside corner at that end of the zone's railing. Only sent back to Layout, which passes "Long" to the railing spec. | PlatformSize | Shown only for Railing zones while Layout's Outside Railing is on (constant `OutsideRailing`; on when opened alone). `B3RightLongForm` skips the Outside Railing test. Default off |  |
| `RailingSelector` | Railing row for the Child Railing Debug buttons, which are inactive on purpose. | RailingChildForm | 0–100. Default = the row picked in the railing list. The section starts collapsed |  |
| `HighPriority` | High-priority job. Here it only feeds the inactive railing inputs. | Details | Engineering only. Default off. Set by Layout |  |
| `DevRelease` | Development release: Release then releases locally instead of to Autopilot. | Details | Development team only. Default off. Set by Layout |  |

Left out on purpose: labels (zone names, the `Out…` echoes of Connected To, `showpushdown`, and the note "*24in Dim inside = 32in Outside for Ladder"), pictures (including the bin diagram), frames, the section toggles (`…CheckExtend`), the 3D preview, the `HostForRailing` host and the two railing data tables, and buttons.

## How Platform Layout uses this platform

Layout opens this project in its `SpecificationHostControl1` when `TypeOfPlatform` is Picking, and sends `DWCalcSpecInputValuesWList` ([platform-layout-inputs.md](platform-layout-inputs.md) §"What Layout sends to Platform - Straight and Platform - Picking"). Checked from this side, every name in that table that this project has lands on the control or constant described above. `NoStiffeners` and the `OverWriteShortCorner…` names are ignored here.

**The `ListToPlatform` list.** On close the platform sends one pipe-separated list of 136 values, in the same order as Straight's 137 without the last one. Layout stores it as one `PlatformList` row, by position:

| Positions | Values | From |
| --- | --- | --- |
| 1 | Index | `Index` |
| 2–7 | Work order, WO prefix, client, project, paint colour, handrail colour | `WorkOrder`, `WOPrefix`, the Client and Project variables, `Color`, the handrail colour variable |
| 8–9 | Shipping assembly, assembly number | `ShippingAssembly` as typed, `AssemblyNumber` (no A) |
| 10–13 | Zones per side, in the order Front, Right, Back, Left | `NumberOfZone…` |
| 14–15 | Total length, total width | `TotalLength`, `TotalWidth` as typed |
| 16–27 | Typed zone widths, F1–F3, R1–R3, B1–B3, L1–L3 | `WidthXn` |
| 28–39 | Connections, same order | `ConnectionXn` |
| 40–51 | Connected To, same order: a number, R or x | `ConnectedToXn` |
| 52 | Mating To | `MatingTo` |
| 53–57 | Output switches | Constants sent by Layout |
| 58 | The SA Layout sent | `PushedDownShippingAssy`, not the typed SA |
| 59 | Model file | `\\192.168.0.19\Driveworks Output Files\<prefix>\<prefix>-A<n>-WithBolts.SLDASM` |
| 60–62 | Floor type, floor thickness, Layout's railing height | `TypeOfFloor`, `ThicknessOfFloor`, `PushedDownRailingHeight` |
| 63–68 | Rib and stiffener part counts of this platform, then Layout's whole-job counts | Calculated |
| 69 | FALSE | Straight's No Stiffeners position |
| 70 | Moment bolting | `MomentConnectionTopBottom` |
| 71–78 | FALSE × 8 | Straight's short-corner positions |
| 79 | "Picking" | Constant `TypeOfPlatform1` |
| 80–83 | Bin length, bin width, bin back height, front bin spacing | `BinLength`, `BinWidth`, the back height variable (42 with Standart Bin Height), `FrontBinSpacing` |
| 84–91 | Railing post and plate counts | Calculated |
| 92–103 | Modelled zone widths, F1…L3 | `ActualWidthXn` |
| 104–112 | No cut-through flag, user name and email (the constants Layout pushed), colour code, spec ID, custom RGB, frame depth | Constants and variables |
| 113–136 | The 24 long-corner flags, F1 Left, F1 Right … L3 Right | `XnLeftLongForm`, `XnRightLongForm` |

The list holds the typed totals, not the modelled `ActualTotalLength` and `ActualTotalWidth`. Railing Height, Designer Drafter, Etching Type, Standart Bin Height and Overwrite A Number are not in it. Layout names position 82 `BinBackWidth`; see the notes.

**The close macros.** Save & Close runs "Close" & `Mode` & "Mode":
- `CloseAddMode` runs Layout's `RunFromSpartaChildAddMode` with the list, then cancels the spec.
- `CloseEditMode` runs Layout's `RunFromSpartaChildEditMode` with the list, then cancels the spec.
- Cancel & Close runs Layout's `RunFromSpartaChildCancel`, then cancels the spec.

Unlike Straight, no debug text files are written. So this spec is never saved while it is edited: the platform exists only as Layout's row. Layout's release loop later opens it again in Edit mode and runs its `ReleaseToAutopilot`, which makes the model `<prefix>-A<n>-WithBolts`.

**Opened on its own.** The project is hidden in the group, and no project other than Layout refers to it. Opened directly:
- `Mode` is blank, so Save & Close has no macro to run, and Cancel calls a parent that isn't there.
- Every Header field shows, and floor type, thickness, railing height and WO prefix are unlocked. The client and project lists are below the frame's edge unless the paint colour is Custom.
- The assembly number is 100 × Shipping Assembly.
- Length, width, zone counts and the bin sizes start at 0, below their minimums, and no connection is set.
- Release still works, so it can make a platform model that no layout row knows about.

**The handrail logic is inactive on purpose.** The Child Railing Debug section hosts DW HandRails in `HostForRailing`, builds one row per Railing or Kick Plate zone (`RailingList`, `RailingListInputs`), and `ReleaseAllChilds` → `ReleaseAllChildsSub` would release them. The user confirmed this is unused: the handrails must sit outside the SAs, so Layout makes them. The model's 12 railing placeholders are also switched off (`DW05-DummyForRailing-1…12` = `If(TRUE=TRUE,"Delete",…)`).

## Size and position in a layout

- **Units are inches.** Width runs along the Front and Back sides, length along the Left and Right sides. Limits: 24–120 in long and 18–95 in wide, for both floor types. The form also errors when the modelled length passes 120 in.
- **Zones.** Each side has 1–3 zones. Front and Back zones are numbered from the left, Left and Right zones from the front (`Form Design Document/PickingPlatformDimZones.PNG`). The last zone on a side takes what is left of the side's total.
- **Typed versus modelled widths (`ActualWidthXn`).**
  - A zone counts as fixed when it is Platform, Platform - Moment Connection, either Stairs type or Rung Ladder. Open, Railing and Kick Plate zones absorb any difference.
  - A zone typed as exactly 36 in becomes 36.4375 in when it is Platform or Platform - Moment Connection, or when it is the only front or back zone on a Grating platform. Unlike Straight, this applies to both floor types.
  - A side's modelled total is the sum of its zones when every zone on it is fixed, otherwise the typed total. The platform's modelled width is the larger of Front and Back, and its length the larger of Left and Right.
- **Zone planes: confirmed as zone centres.** `DW05-A101.SLDASM` has reference planes F1–F3, R1–R3, B1–B3 and L1–L3, with matching dimensions `DistanceXn@Zones` = `HalfWidthZoneXn`: zone 1's width ÷ 2, zone 1 + zone 2 ÷ 2, zone 1 + zone 2 + zone 3 ÷ 2, all modelled widths. So each plane sits at its zone's centre, measured from the start of the side. The side members use the same values in a sketch named `Center Of Zones` (`CenterOfR1@Center Of Zones` in `DW05-A101-K2-1LBF`). The faces and centre planes that Layout mates to have no rules: they are fixed in the model.
- **Overall size in the model:** `TotalWidth@Zones` and the plate width = `ActualTotalWidth`; `TotalLength@Zones` and the plate length = `ActualTotalLength`.
- **Frame depth:** `PlatformThickness`, default 8 in, as in Straight.
- **Picking hopper (bin)** (`Form Design Document/PickingPlatformDimBox.PNG`):
  - It stands on the floor over a hole of bin length + 0.75 in by bin width + 0.25 in. The hole's right side is 4.3125 in from the platform's right edge, and it starts 0.375 in before Front Bin Spacing, measured from the front edge.
  - Back and side walls are Bin Back Height tall (30–50 in, 42 standard), the front wall 34.25 in. The side walls are bin length + 5 in long.
  - It is its own assembly, `<prefix>-A<n+50>`, with yard-assembled (`-YD`) kits.
  - For a layout it is the tallest part of the platform after the railings: up to 50 in above the floor.
- **Floor:**
  - Checkered Plate: one top plate up to 60 in wide. Above that, two plates: the first 60 in (or width − 12 in up to 72 in), the second the rest.
  - Grating: one panel up to 36 in wide, otherwise 36 in + the rest. Panel length = platform length − 0.125 in. Grating end plates are added on a front side with either Stairs type, Rung Ladder or Open, and on a back side with Stairs (Attached to Side), Rung Ladder or Open.
- **Ribs and stiffeners:** both cross stiffeners are always there, 3/16 in before the hopper's front and back edges. Ribs are at most 24 in apart; ribs beside the hopper are added only when more than 18 in is left (width − bin width − 6.5 in).
- **Railing and Kick Plate zones:** the frame gets railing connection holes at both ends and along the zone, one opening per 46 in. Layout then makes one railing spec per such zone, with length = that zone's `ActualWidthXn`. This project doesn't place railings.
- **Platform zones:** platform connection holes. The bolts to that neighbour are inserted here only when it is in the same SA, and only on zones F1–F3, R1–R3 and B1. Joints between SAs are left to DW Platform Bolts, which Layout runs.
- **Platform - Moment Connection** (F1 or B1, one zone on that side): moment holes and cut-outs in the corner members. The moment splice plates are inserted only for a front moment connection: 2 with Bottom Only, 4 with Top and Bottom.
- **Stairs and ladder zones:** the same as Straight. Stairs (Attached to Side) adds stair connection holes, Rung Ladder adds ladder connection holes, and Stairs (Sitting On Top) adds nothing but keeps the zone's typed width. No project opens DW Stairs or DW Ladder for them. `Zone Length Reference.docx`: 32 in for a standard 24 in ladder; stair width + 0.25 in for stairs attached to the side; for stairs sitting on top, stair width + 0.375 in for end zones and + 0.25 in for a middle zone.
- **Elevation:** none. The platform has no height, leg or support input; Layout sets all platforms on one top level.

## Notes and open questions

- **Who counts as a Sparta user.** `IsUserInEngineering` (Engineering or Xortion Engineering) shows only High Priority. `IsUserInDevelopement` shows Dev Release and unlocks Platform Thickness. `IsUserInSparta` exists but nothing uses it.
- **What a non-Engineering user gets.** This path is live. Inside Layout they see the same hosted form as Engineering, without High Priority, and with Platform Thickness locked to Layout's value. Problems on this path:
  - The Child Railing Debug section, with Open Railing and Release All Railing, is shown to everyone. Release All Railing would still release DW HandRails specs from inside the platform, the route Layout replaced.
  - The Release button in the hosted form releases this platform on its own. It doesn't run the close macros, so Layout's row isn't updated.
  - Connected To and Mating To are free text. Nothing checks them against real assembly numbers, yet Layout's mates and bolts depend on them.
  - Changing Shipping Assembly resets Assembly Number to 100 × SA, so two platforms moved into one SA both become n00. Overwrite A Number fixes it only until the next edit, because the check box isn't returned to Layout.
  - The Header starts collapsed, so Shipping Assembly is hidden until the user opens Customer Info.
  - The text boxes carry Min/Max properties, for example 0–100 on Assembly Number and Connected To. Layout's 14 saved rows hold numbers such as 101 and 1101, so DriveWorks doesn't appear to enforce them on text boxes.
- **No default is set** for Type Of Floor, Thickness Of Floor, Moment Connection Top/Bottom, Etching Type, the connections, Bin Length and Mode. Length, width, zone counts, Bin Width, Bin Back Height and Front Bin Spacing default to 0, below their minimums. Hosted, Layout supplies all of these for a new platform.
- **Exports.** No SQL table. The data is Layout's `PlatformList` row, which Layout writes to SQL table `DWPlatformLayout`. On release, the triggered action `PlatformGenerated` waits for `<prefix>-A<n>-WithBolts <spec id>.pdf`. Custom colours go to the Colors group table.
- **Children.** None in use. Platform Bolts, the handrails, stairs and ladders are all handled by Layout or not at all.
- **Differences from DW Platform - Straight** ([platform-straight-inputs.md](platform-straight-inputs.md)):
  - Picking adds the picking hopper inputs. Straight sends FALSE in list positions 80–83.
  - Picking has no No Stiffeners, Finish Of Grating or short-corner inputs. Its stiffeners always sit at the hopper's front and back edges, and in the (inactive) railing table its short corners come only from neighbouring Platform zones.
  - Picking has Overwrite A Number but doesn't return it; Straight does, in position 137.
  - Limits: Picking allows 24–120 in long and 18–95 in wide whatever the floor. Straight allows 12–119 by 16–100 with Checkered Plate, and 12–120 by 16–60 with Grating.
  - Picking grows 36 in Platform zones to 36.4375 in on both floors, splits the grating above 36 in instead of 36.4375 in, and cuts the grating 0.125 in short instead of 0.375 in.
  - Picking returns the user name and email that Layout pushed; Straight returns its own variables.
  - Picking has no Save Dev or Save Specification button, and its close macros write no debug files.
- **Looks wrong, for Sparta engineering to confirm:**
  - **Bin Back Height is lost in Edit.** This side sends the back height in position 82, which Layout names `BinBackWidth`. Layout's Edit value looks for a column `BinBackHeight`, which doesn't exist, so every Refresh sends no valid back height (also reported from Layout's side). Since Standart Bin Height isn't sent either, the wall height then has no valid value.
  - **Defaults refer to missing constants.** `WOPrefix` and `WorkOrder` defaults use constants `WOPrefix` and `WorkOrder`, which only Straight has. Hosted, Layout's values override them.
  - **Email attachment name.** The "platform is generated" email attaches `<prefix>-A<n>-WithRailings <id>.pdf`, while the triggered action waits for `-WithBolts`. Straight attaches `-WithBolts`.
  - **No Grating width limit.** Straight stops Grating at 60 in wide; Picking allows 95 in with any floor.
  - Floor thickness drives no model dimension, and Railing Height drives nothing (fixed at 43.25 by `OverwriteRailingHeight` = FALSE).
  - `MatingTo` is forced to Origin when `DWParentRowIndex` = 1. It isn't clear when that holds for a hosted spec.
  - `B3RightLongForm` shows even with inside railings.
