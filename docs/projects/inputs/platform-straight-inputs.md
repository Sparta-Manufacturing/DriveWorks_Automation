# DW Platform - Straight: form inputs

*Read from `DriveWorks Files/Platform/DW Platform - Straight.driveprojx` as saved 2026-04-29 10:19. Written 2026-10-01 for Bruno's pre-sales layout app, which should use the same parameters as DriveWorks.*

This table lists every input on the DW Platform - Straight form, the rectangular platform that DW Platform Layout hosts once per platform, so the layout app can use the same parameter names.

- **DriveWorks Input**: the control name exactly as it appears in DriveWorks.
- **Description**: what the input is for, inferred from its caption, options and rules.
- **Group**: the form page the input sits on.
- **Limitation**: minimum, maximum, option list, or an override limit set by a rule. Empty when there is none.
- **Layout effect**: what the input changes in the platform's size or position in a layout. Empty when it changes neither.

## Inputs

Rows follow the form from top to bottom: CustomerInfo, CommonInfo, PlatformSize, ShortCorners and RailingChildForm (the frames of the main window), then the Details footer. The 12 zones F1–F3, R1–R3, B1–B3 and L1–L3 share one row per field, written with Xn. Units are in the description, and defaults are at the end of the limitation.

The form normally runs inside Platform Layout ([platform-layout-inputs.md](platform-layout-inputs.md)), which sets most inputs. "Layout: X for a new platform" means the value Layout sends in Add mode; in Edit mode Layout sends the platform's saved row. "Hidden when hosted" means the field is hidden when Layout sends a floor thickness (`PushedDownThicknessOfFloor`), which is the normal hosted case. Then CustomerInfo shows only Shipping Assembly, Assembly Number and Overwrite A Number.

| DriveWorks Input | Description | Group | Limitation | Layout effect |
| --- | --- | --- | --- | --- |
| `CheckBox1_NewClientProject` | Switches Client and Project to free text. | CustomerInfo | Default off. Forced on when Layout sends the client (`HostedClientName`). Hidden when hosted |  |
| `Index` | This platform's row number in Layout's platform list. | CustomerInfo | Locked. 0–9999. Default 0. Set by Layout: highest index + 1 for a new platform. Hidden when hosted |  |
| `Mode` | Add or Edit. Save & Close runs `CloseAddMode` or `CloseEditMode` from it. | CustomerInfo | Add, Edit. Locked. Set by Layout. No default set, so opened on its own Save & Close has no macro to run. Hidden when hosted |  |
| `Client`, `TextBox1_Client` | Client: picked from a list, or typed when New Client Project is on. Written to the parts' Client property. | CustomerInfo | List from the ClientProjects group table. The text box shows Layout's client when hosted. Hidden when hosted |  |
| `Project`, `TextBox1_Project` | Project: picked from the client's projects, or typed. Written to the parts' Project property. | CustomerInfo | List filtered by the chosen client. The text box shows Layout's project when hosted. Hidden when hosted |  |
| `WOPrefix` | "Work Order Prefix". It starts every file name, `<prefix>-A<n>-…`, and names the output folder `\\192.168.0.19\Driveworks Output Files\<prefix>`. | CustomerInfo | Default: the WO prefix of the client's first ClientProjects row. Set by Layout: always Layout's prefix, and locked. Hidden when hosted |  |
| `DesignerDrafter` | Designer or drafter, written to the parts' DrawnBy property. | CustomerInfo | Layout doesn't send it. Hidden when hosted |  |
| `WorkOrder` | Work order, written to the parts' WO property. | CustomerInfo | Default: the work order of the client's first ClientProjects row. Set by Layout: always Layout's work order. Hidden when hosted |  |
| `AlternateHandRailColor` | Gives the handrails their own colour. Off: the handrail colour is the paint colour. | CustomerInfo | Default off. Forced on when Layout sends the SA (`PushedDownShippingAssy`), so Layout's handrail colour is kept. Hidden when hosted |  |
| `Color` | Paint colour. Its colour code goes into the part file names (`…-K1-<code>`). | CustomerInfo | Options from the Colors group table. Default Sparta Blue. Set by Layout: always Layout's colour. Hidden when hosted |  |
| `HandRailColor` | Handrail colour. The platform model doesn't use it. It goes back to Layout in the platform row. | CustomerInfo | Options from the Colors group table. Default Galvanized, but it shows Sparta Yellow while Alternate Hand Rail Color is off. Set by Layout. Hidden when hosted |  |
| `ColorCode`, `HandRailColorCode` | Colour codes of the paint and handrail colours. | CustomerInfo | Default looked up from the Colors group table. Editable only with Custom. Set by Layout. Hidden when hosted |  |
| `PaintRed`, `PaintGreen`, `PaintBlue` | RGB values of a custom paint colour. | CustomerInfo | Shown only with Custom. 0–255. Default 0. Set by Layout |  |
| `HandRailRed`, `HandRailGreen`, `HandRailBlue` | RGB values of a custom handrail colour. | CustomerInfo | Shown only with Alternate Hand Rail Color and a Custom handrail colour. 0–255. Default 0. Set by Layout |  |
| `ColorName`, `HandRailColorName` | Names of custom colours, saved to the Colors group table on release (`NewColourSpecs`). | CustomerInfo | Shown only with Custom (the handrail one also needs Alternate Hand Rail Color). Layout doesn't send them |  |
| `ShippingAssembly` | Shipping assembly (SA) this platform ships in. A neighbour whose Connected To number has the same hundreds is in the same SA, and the bolts to it are then part of this platform. | CustomerInfo | 0–100, while Layout has only SAs 1–15. Default 1. Layout: 1 for the first platform, otherwise the last row's SA | The SA the platform is placed in |
| `AssemblyNumber` | "Assembly Number": the platform's number without the A, for example 101. It names the files (`<prefix>-A101-WithBolts`), and neighbours type it in their Connected To. | CustomerInfo | Locked unless Overwrite A Number is on. Layout: 100 × SA + the platforms already in that SA, for a new platform. Reset to 100 × Shipping Assembly when the SA differs from the one Layout sent and Overwrite A Number is off. Opened on its own: 100 × SA | The platform's identity in the layout: Connected To and Mating To refer to it |
| `OverwriteANumber` | "Overwrite A Number": unlocks Assembly Number. | CustomerInfo | Default off. Layout: blank for a new platform |  |
| `TypeOfFloor` | Floor type. Grating: 1 in grating panels in one or two pieces. Checkered Plate: one or two top plates held by carriage bolts. | CommonInfo | Checkered Plate, Grating. No default set. Set by Layout: always Layout's floor type, and locked | Size limits: Grating allows 60 in wide and 120 in long, Checkered Plate 100 in and 119 in. With Grating, 36 in Platform zones grow by 0.4375 in |
| `MomentConnectionTopBottom` | Moment-connection bolting: bottom only (2 splice plates) or top and bottom (4). | CommonInfo | Bottom Only, Top and Bottom. No default set. Forced to Layout's value (`PushedDownMomentConnectionTopBottom`) |  |
| `NoStiffeners` | "No Stiffeners": leaves out the cross stiffeners. The ribs then run the full length. | CommonInfo | Default off. Layout: off for a new platform |  |
| `ThicknessOfFloor` | Floor thickness (in). It only changes the grating's Description property and the 3D preview. No model dimension reads it: the modelled grating stays 1 in thick. | CommonInfo | Checkered Plate: 0.1875, 0.25, 0.375, 0.5, 0.75. Grating: 0.75, 1, 1.25, 1.5, 1.75, 2, 2.25. No default set. Set by Layout: always Layout's value, and locked |  |
| `FinishOfGrating` | Grating finish, written to the grating parts' Description. | CommonInfo | Serrated Black, Serrated GALV. Shown only with Grating. No default set. Layout doesn't send it |  |
| `RailingHeight` | Railing height (in). Not programmed yet: it changes nothing in the model and is only saved with the spec. It isn't in the row sent back to Layout either. Layout sends its own railing height to the railing specs. | CommonInfo | Locked to Layout's railing height (`PushedDownRailingHeight`, 43.25 unless overwritten). No default set |  |
| `PlatformThickness` | Frame depth (in): the height of the frame members. Below 8 in their flanges narrow to 0.625 × depth; from 8 in they are 5 in. | CommonInfo | 0–100. Default 8. Locked except for the Development team. Set by Layout: always Layout's value | Depth of the platform frame |
| `EtchingType` | Etching style on the parts: an arrow, or a cut-through. | CommonInfo | Arrow, Cut Through. No default set. Set by Layout |  |
| `NumberOfZoneFront`, `NumberOfZoneRight`, `NumberOfZoneBack`, `NumberOfZoneLeft` | Number of zones on each side. | PlatformSize | 1–3. Default 0, below the minimum. Layout: 1 for a new platform | How many zones, and zone planes, that side has |
| `TotalWidth` | "Total Width (in)", along the Front and Back sides. | PlatformSize | 16–100 in, or 16–60 with Grating. Default 0, below the minimum. Layout: 48 for a new platform | Width. The model can be up to 0.4375 in wider per 36 in Platform zone (see below) |
| `TotalLength` | "Total Length (in)", along the Left and Right sides. | PlatformSize | 12–119 in, or 12–120 with Grating. Error when the modelled length passes 120 in. Default 0, below the minimum. Layout: 120 for a new platform, above the 119 in maximum with Checkered Plate | Length |
| `WidthXn` | "Width Zone Xn" (in). Front and Back zones count from the left, Left and Right zones from the front. Only the first one or two are typed: with one zone, zone 1 = the side's total; with two, zone 2 = total − zone 1; with three, zone 3 = total − zone 1 − zone 2. | PlatformSize | Text boxes. Zone 1: up to total − zones 2 and 3. Zone 2: up to total − zone 1. Left and right zones have a minimum of 11. Shown only when the zone exists. Layout: 24 for a new platform | Zone length along that side. Sets where the zone plane sits (the zone centre) and the railing length |
| `ConnectionXn` | "Connections": what meets that zone. | PlatformSize | Open, Platform, Railing, Kick Plate, Stairs (Sitting On Top), Stairs (Attached to Side), Rung Ladder. F1 and B1 add Platform - Moment Connection when their side has one zone. A zone that doesn't exist is forced to Open. No default set. Layout: Railing for a new platform | What the edge meets: a neighbour, a railing, a kick plate, stairs, a ladder or nothing |
| `ConnectedToXn` | "Connected To": the assembly number of the platform on that zone. It becomes R for Railing and x for anything else. | PlatformSize | Shown only for Platform and Platform - Moment Connection. Nothing checks it against real numbers. Layout: blank for a new platform | The neighbour on that zone |
| `XnLeftLongForm`, `XnRightLongForm` | "Xn Left Long", "Xn Right Long": a long inside corner at that end of the zone's railing. Only sent back to Layout, which passes "Long" to the railing spec. | PlatformSize | Shown only for Railing zones while Layout's Outside Railing is on (constant `OutsideRailing`; on when opened alone). `B3RightLongForm` skips the Outside Railing test. Default off |  |
| `MatingTo` | "Mating To": the platform this one is placed against. | PlatformSize | Options: the Connected To numbers typed on this platform, plus Origin. Error when blank or x. Forced to Origin when `DWParentRowIndex` = 1. Layout: blank for a new platform | Position: this platform is mated zone to zone to that neighbour. Origin = the layout origin |
| `OverWriteShortCornerFrontLeft`, `…FrontRight`, `…RightLeft`, `…RightRight`, `…BackLeft`, `…BackRight`, `…LeftLeft`, `…LeftRight` | "Over Write Short Corner …": a short railing corner at that platform corner. Each side has two, one per end of its railing. Only sent back to Layout, which uses them for the corner railings. | ShortCorners | Default off. Layout: off for a new platform. The section starts collapsed |  |
| `RailingSelector` | Railing row for the Child Railing Debug buttons, which are inactive on purpose. | RailingChildForm | 0–100. Default = the row picked in the railing list. The section starts collapsed |  |
| `HighPriority` | High-priority job. Here it only feeds the inactive railing inputs. | Details | Engineering only. Default off. Set by Layout |  |
| `DevRelease` | Development release: Release then releases locally instead of to Autopilot. | Details | Development team only. Default off. Set by Layout |  |

Left out on purpose: labels (zone names, the `Out…` echoes of Connected To, `showpushdown`, and the note "*24in Dim inside = 32in Outside for Ladder"), pictures, frames, the section toggles (`…CheckExtend`), the 3D preview, the `HostForRailing` host and the two railing data tables, and buttons. The Footer page is in no frame, so it never shows; it has no inputs.

## How Platform Layout uses this platform

Layout opens this project in its `SpecificationHostControl1` and sends `DWCalcSpecInputValuesWList` ([platform-layout-inputs.md](platform-layout-inputs.md) §"What Layout sends to Platform - Straight and Platform - Picking"). Checked from this side, every name in that table that this project has lands on the control or constant described above.

**The `ListToPlatform` list.** On close the platform sends one pipe-separated list of 137 values. Layout stores it as one `PlatformList` row, by position:

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
| 69–78 | No Stiffeners, moment bolting, then the 8 short-corner flags (FrontRight, FrontLeft, RightRight, RightLeft, BackRight, BackLeft, LeftRight, LeftLeft) | Inputs |
| 79 | "Straight" | Constant `TypeOfPlatform1` |
| 80–83 | FALSE × 4 | Placeholders for Picking's bin columns |
| 84–91 | Railing post and plate counts | Calculated |
| 92–103 | Modelled zone widths, F1…L3 | `ActualWidthXn` |
| 104–112 | No cut-through flag, user name and email, colour code, spec ID, custom RGB, frame depth | Constants and variables |
| 113–136 | The 24 long-corner flags, F1 Left, F1 Right … L3 Right | `XnLeftLongForm`, `XnRightLongForm` |
| 137 | Overwrite A Number | `OverwriteANumber` |

The list holds the typed totals, not the modelled `ActualTotalLength` and `ActualTotalWidth`. Railing Height, Designer Drafter, Finish Of Grating and Etching Type are not in it.

**The close macros.** Save & Close runs "Close" & `Mode` & "Mode":
- `CloseAddMode` runs Layout's `RunFromSpartaChildAddMode` with the list, writes two debug text files to `C:\Users\oligod\OneDrive - Sparta Manufacturing\Desktop\text\`, then cancels the spec.
- `CloseEditMode` writes the same two files, runs Layout's `RunFromSpartaChildEditMode` with the list, then cancels the spec.
- Cancel & Close runs Layout's `RunFromSpartaChildCancel`, then cancels the spec.

So this spec is never saved while it is edited: the platform exists only as Layout's row. Layout's release loop later opens it again in Edit mode and runs its `ReleaseToAutopilot`, which makes the model `<prefix>-A<n>-WithBolts`.

**Opened on its own.** The project is hidden in the group, and no project other than Layout refers to it. Opened directly:
- `Mode` is blank, so Save & Close has no macro to run, and Cancel calls a parent that isn't there.
- Every CustomerInfo field shows, and floor type, thickness, railing height and WO prefix are unlocked.
- The assembly number is 100 × Shipping Assembly.
- Length, width and zone counts start at 0, below their minimums, and no connection is set.
- Release still works, so it can make a platform model that no layout row knows about.

**The handrail logic is inactive on purpose.** The Child Railing Debug section hosts DW HandRails in `HostForRailing`, builds one row per Railing or Kick Plate zone (`RailingList`, `RailingListInputs`), and `ReleaseAllChilds` → `ReleaseAllChildsSub` would release them. The user confirmed this is unused: the handrails must sit outside the SAs, so Layout makes them. The model's 12 railing placeholders are also switched off (`DW05-DummyForRailing-1…12` = `If(TRUE=TRUE,"Delete",…)`).

## Size and position in a layout

- **Units are inches.** Width runs along the Front and Back sides, length along the Left and Right sides. Limits: 12–119 in long and 16–100 in wide with Checkered Plate; 12–120 in long and 16–60 in wide with Grating. The form also errors when the modelled length passes 120 in.
- **Zones.** Each side has 1–3 zones. Front and Back zones are numbered from the left, Left and Right zones from the front (`Form Design Document/Strait Zone Pic.PNG`). The last zone on a side takes what is left of the side's total.
- **Typed versus modelled widths (`ActualWidthXn`).**
  - A zone counts as fixed when it is Platform, Platform - Moment Connection, either Stairs type or Rung Ladder. Open, Railing and Kick Plate zones absorb any difference.
  - With Grating, a zone typed as exactly 36 in becomes 36.4375 in when it is Platform or Platform - Moment Connection, or when it is the only zone on the front or back. With Checkered Plate, 36 in stays 36 in.
  - A side's modelled total is the sum of its zones when every zone on it is fixed, otherwise the typed total. The platform's modelled width is the larger of Front and Back, and its length the larger of Left and Right.
  - When every zone on the opposite side is fixed, a non-fixed zone 1 also grows by 0.4375 in per 36 in Platform zone over there.
- **Zone planes: confirmed as zone centres.** `DW05-A100.SLDASM` has reference planes F1–F3, R1–R3, B1–B3 and L1–L3. Zone 2 and 3 planes are deleted when the side has fewer zones. Each plane has a matching dimension `DistanceXn@Zones` = `HalfWidthZoneXn`: zone 1's width ÷ 2, zone 1 + zone 2 ÷ 2, zone 1 + zone 2 + zone 3 ÷ 2, all modelled widths. So each plane sits at its zone's centre, measured from the start of the side. The capture doesn't show what each plane is built on, but the side members use the same values in a sketch named `Center Of Zones` (`CenterOfL1@Center Of Zones` = `HalfWidthZoneL1` in `DW05-A100-K1-1LBF`). The faces and centre planes that Layout mates to (`RightFace`, `Center L-R`, `Top`…) have no rules: they are fixed in the model.
- **Overall size in the model:** `TotalWidth@Zones` and the plate width = `ActualTotalWidth`; `TotalLength@Zones` and the plate length = `ActualTotalLength`.
- **Frame depth:** `PlatformThickness`, default 8 in. It is the height of the side members (`DW05-A100-K1-1LBF`); the other frame members, ribs and stiffeners are 0.4375 in less.
- **Floor:**
  - Checkered Plate: one top plate up to 60 in wide. Above that, two plates: the first 60 in (or width − 12 in up to 72 in), the second the rest. Carriage bolts along the sides are at most 24 in apart.
  - Grating: one panel up to 36.4375 in wide, otherwise two panels of 36 in + the rest (31 in + the rest under 41 in). Panel length = platform length − 0.375 in. Grating end plates are added on a back side with Stairs (Attached to Side), Rung Ladder or Open, and on a front side with Stairs (Attached to Side) or Rung Ladder.
- **Ribs and stiffeners:** ribs at most 24 in apart. Cross stiffeners are added where a left or right zone boundary meets a Platform zone (after zone 1, and before the last zone), unless No Stiffeners is on.
- **Railing and Kick Plate zones:** the frame gets railing connection holes at both ends and along the zone, one opening per 46 in. Layout then makes one railing spec per such zone, with length = that zone's `ActualWidthXn`. This project doesn't place railings.
- **Platform zones:** platform connection holes. The bolts to that neighbour are inserted here only when it is in the same SA, and only on zones F1–F3, R1–R3 and B1. Joints between SAs are left to DW Platform Bolts, which Layout runs.
- **Platform - Moment Connection** (F1 or B1, one zone on that side): moment holes and cut-outs in the corner members. The moment splice plates (`DW05-4LP-BL`) are inserted only for a front moment connection: 2 with Bottom Only, 4 with Top and Bottom.
- **Stairs and ladder zones:**
  - Stairs (Attached to Side): stair connection holes along the zone, zone width − 3 in apart (0.4375 in less on a 36.4375 in zone).
  - Rung Ladder: ladder connection holes.
  - Stairs (Sitting On Top): no feature on the platform. The zone only keeps its typed width.
  - No project opens DW Stairs or DW Ladder for these zones. `Zone Length Reference.docx` gives the zone lengths to type: 32 in for a standard 24 in ladder; stair width + 0.25 in for stairs attached to the side; for stairs sitting on top, stair width + 0.375 in for end zones and + 0.25 in for a middle zone.
- **Elevation:** none. The platform has no height, leg or support input; Layout sets all platforms on one top level.

## Notes and open questions

- **Who counts as a Sparta user.** `IsUserInEngineering` (Engineering or Xortion Engineering) shows only High Priority. `IsUserInDevelopement` shows Dev Release and Save Dev and unlocks Platform Thickness. `IsUserInSparta` exists but nothing uses it.
- **What a non-Engineering user gets.** This path is live. Inside Layout they see the same hosted form as Engineering, without High Priority, and with Platform Thickness locked to Layout's value. Problems on this path:
  - The Child Railing Debug section, with Open Railing, Release All Railing and Save Specification, is shown to everyone. Release All Railing would still release DW HandRails specs from inside the platform, the route Layout replaced.
  - The Release button in the hosted form releases this platform on its own. It doesn't run the close macros, so Layout's row isn't updated.
  - Connected To and Mating To are free text. Nothing checks them against real assembly numbers, yet Layout's mates and bolts depend on them.
  - Changing Shipping Assembly resets Assembly Number to 100 × SA, so two platforms moved into one SA both become n00 unless Overwrite A Number is used.
  - The text boxes carry Min/Max properties, for example 0–100 on Assembly Number and Connected To. Layout's 14 saved rows hold numbers such as 101 and 1101, so DriveWorks doesn't appear to enforce them on text boxes. Treat the zone-width limits as advisory.
- **No default is set** for Type Of Floor, Thickness Of Floor, Moment Connection Top/Bottom, Finish Of Grating, Etching Type, the connections and Mode. Length, width and zone counts default to 0, below their minimums. Hosted, Layout supplies all of these except Finish Of Grating.
- **Exports.** No SQL table. The data is Layout's `PlatformList` row, which Layout writes to SQL table `DWPlatformLayout`. On release, the triggered action `PlatformGenerated` waits for `<prefix>-A<n>-WithBolts <spec id>.pdf`, and an email with that PDF goes to the user Layout sends (`PushedDownClientEmail`). Custom colours go to the Colors group table.
- **Children.** None in use. Platform Bolts, the handrails, stairs and ladders are all handled by Layout or not at all.
- **Differences from DW Platform - Picking** ([platform-picking-inputs.md](platform-picking-inputs.md)):
  - Picking has a picking hopper (bin) with `BinLength`, `BinWidth`, `BinBackHeight`, `StandartBinHeight` and `FrontBinSpacing`. Straight sends FALSE in those four list positions.
  - Picking has no No Stiffeners, Finish Of Grating or short-corner inputs: its stiffeners always sit at the bin's front and back edges, and its short corners come only from neighbouring Platform zones.
  - Picking doesn't return Overwrite A Number, although it has the check box.
  - Limits: Picking allows 24–120 in long and 18–95 in wide, with no Grating limit. Straight allows 12–119 (120) by 16–100 (60).
  - With Grating, Picking's 36 in Platform zones always grow to 36.4375 in, and it splits the grating above 36 in, not 36.4375 in.
  - Straight returns the current user's name and email in positions 105–106, Picking returns the constants Layout pushed.
- **Looks wrong, for Sparta engineering to confirm:**
  - New platforms start at 120 in long, above the 119 in maximum with Checkered Plate (also reported from Layout's side).
  - The front grating end-plate test looks for "Openn", so an Open front gets no end plate while an Open back does.
  - Floor thickness drives no model dimension, and Railing Height drives nothing (the variable is fixed at 43.25 by `OverwriteRailingHeight` = FALSE).
  - `MatingTo` is forced to Origin when `DWParentRowIndex` = 1. It isn't clear when that holds for a hosted spec; Layout places the first platform at the origin anyway.
  - `B3RightLongForm` shows even with inside railings.
  - Every Save & Close writes two debug text files to a personal OneDrive folder (also reported from Layout's side).
