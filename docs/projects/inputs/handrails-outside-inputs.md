# DW HandRails outside: form inputs

*Read from `DriveWorks Files/HandRails outside/DW HandRails outside.driveprojx` as saved 2025-06-03 16:18. Written 2026-10-01 for Bruno's pre-sales layout app, which should use the same parameters as DriveWorks.*

This table lists every input on the DW HandRails outside form, the guard-panel railing with a separate handrail along one edge zone of a platform, so the layout app can use the same parameter names.

- **DriveWorks Input**: the control name exactly as it appears in DriveWorks.
- **Description**: what the input is for, inferred from its caption, options and rules.
- **Group**: the form page the input sits on.
- **Limitation**: minimum, maximum, option list, or an override limit set by a rule. Empty when there is none.
- **Layout effect**: what the input changes in the railing's size or position in a layout. Empty when it changes neither.

## Inputs

Rows follow the form from top to bottom: the three sections that the Main Window stacks (Customer Info, Railing Inputs, Overhang Inputs), the footer, then the Extra Stuff and Test Form pages, which no frame shows. Left and right twins and paired controls share a row. Units are in the description, and defaults are at the end of the limitation, followed by what DW Platform Layout sends when it hosts the railing ("Layout:"). "Layout: not sent" means the hosted railing keeps this project's default.

Most of the Railing Inputs page can't be reached on its own: see "Railing Inputs is cut off" in the notes.

| DriveWorks Input | Description | Group | Limitation | Layout effect |
| --- | --- | --- | --- | --- |
| `CheckBox1_NewClientProject` | Switches Client and Project to the text boxes. | Customer Info | Driven by a rule: on when Layout sends a client (`HostedClientName`), otherwise blank. The user can't change it. Layout: on |  |
| `Client`, `TextBox1_Client` | Client: picked from a list, or the text box when New Client Project is on. Goes to the drawings' Client property. | Customer Info | List: every client in the ClientProjects group table. Layout: Layout's client, in both controls |  |
| `Project`, `TextBox1_Project` | Project: picked from the client's projects, or the text box. Goes to the drawings' Project property. | Customer Info | List filtered by the chosen client (ClientProjects). Layout: Layout's project |  |
| `WOPrefix` | Work order prefix. Starts every file name (`<prefix>-<assembly>-…`) and names the output folder. | Customer Info | Default: constant `WOPrefix`, else the client's prefix in ClientProjects. Layout: Layout's prefix (also `HostedWOPrefix`, which drives the text) |  |
| `TextBox1_DesignerDrafter` | Designer or drafter. Nothing reads it. | Customer Info | Layout: not sent |  |
| `WorkOrder` | Work order. Goes to the drawings' WO property. | Customer Info | Default: constant `WorkOrder`, which this project doesn't have, else the client's work order in ClientProjects. Layout: Layout's work order (also `HostedWorkOrderNumber`) |  |
| `AssemblyNumber` | Assembly number, for example A100A. Second part of every railing file name. | Customer Info | No default set. Layout: "A" & platform number & railing letter |  |
| `Color` | Paint colour. | Customer Info | Options from the Colors group table. Default Sparta Blue. Layout: Layout's handrail colour |  |
| `ColorCode` | Colour code. Ends the post, panel and rail file names, for example `<prefix>-K40-<code>`. | Customer Info | Default looked up from the Colors group table. Editable only with Custom. Layout: Layout's handrail colour code |  |
| `PaintRed`, `PaintGreen`, `PaintBlue` | RGB values of a custom colour, written to the parts' DWColor property. | Customer Info | Shown only with Custom. 0–255. Default 0. Layout: Layout's custom handrail RGB |  |
| `ColorName` | Name of a custom colour. Nothing reads it: this project has no Colors export. | Customer Info | Shown only with Custom. Layout: not sent |  |
| `NoCutThroughInHandrail` | No cut-through marks. Not programmed yet: it changes nothing in the model and is only saved with the spec. | Railing Inputs | Default off. Forced off and locked when the posts are custom (see the next row). Layout: the platform's No Cut Through In Handrail |  |
| `IncludedANumberInName` | "Included A Number In Post Name": names the post kits after this railing (`<prefix>-<assembly>-K40-…`) instead of one shared file per work order (`<prefix>-K40-…`). The posts also become custom with either ladder check box, the railing-height overwrite, or without side-clip holes. | Railing Inputs | Default off. Layout: not sent |  |
| `PutAllInWOFolder` | Saves the files in folder `<prefix>` instead of `<prefix>-<assembly>-Railings-DW <spec id>`. | Railing Inputs | Default off. No effect when hosted: Layout's `AssemblyNumberNoLocation` already puts the files in `<prefix>` |  |
| `EtchingType` | Etching style. Arrow adds the arrow etching to the guard posts, the middle handrail posts and the guard panel. Cut Through adds nothing here. | Railing Inputs | Arrow, Cut Through. No default set. Layout: Layout's Etching Type |  |
| `PlatformThickness` | Platform frame depth (in). The top of the guard posts' bolt slot sits depth/2 − 1 in below the platform top. | Railing Inputs | 0–100. Default 8. Layout: the platform's Platform Thickness | How far the guard posts reach down the platform's side face |
| `ThicknessOfFloor` | Floor thickness (in), added to Railing Height for the guard post height. | Railing Inputs | 0.125, 0.1875, 0.25, 0.375, 1, 1.125, 1.25, 1.5. No default set. Layout: not sent, so it stays blank | Post height above the platform top |
| `PostToPostWidth` | Railing length (in), post to post. Guard panel = width − 0.875 in (0.125 in tolerance, 0.375 in at each end), less 2 in per inside corner set to True. Openings: 1 under 46 in of panel, 2 up to 92 in, 3 from 92 in. Posts = openings + 1. | Railing Inputs | 6–240, but never more than 3 openings. Cut off on its own (see the notes). Default 0, below the minimum. Layout: the zone's modelled width (`ActualWidthXn`) | Length along the platform edge, centred on the zone. Number of posts (2 to 4) |
| `HandrailActualLength` | Read-only: width − 0.125 in. | Railing Inputs | Shown only for Handrail, which hosted Railing zones fall back to (see `HandrailORKickPlate`) | Railing length |
| `EnableMoreThan10ftTopRail` | "Enable More Than 10ft Handail": allows a top rail over 10 ft. Without it the box shows an error above 120 in. | Railing Inputs | Shown only for Handrail. Default off; forced on for Kick Plate zones. Layout: never arrives, its row is misspelt `Enable<preThan10ftTopRail` |  |
| `OverwriteRailingHeight` + `RailingHeight` | Guard rail height (in, above the floor). The guard posts stand Railing Height + Thickness Of Floor above the platform top. The guard panel is 42.25 in tall, or Railing Height − 1 with the overwrite. | Railing Inputs | Check box shown only for Handrail, and forced off for Kick Plate zones. The height box is locked without it. 35.375–43.3 in. Default 43. Layout: Railing Height, 43.25 unless Layout's is overwritten (Layout allows up to 60, and nothing here checks the 43.3 maximum); check box FALSE | Railing height |
| `OverwriteHandrailHeight` + `HandRailHeight` | Handrail height (in, above the floor). The handrail is mounted Railing Height − Hand Rail Height below the top of the guard rail: 6.25 in with Layout's defaults, 7.625 in with this project's. | Railing Inputs | Height box locked unless the check box is on. 33–43 in. Default 35.375. Check box default off. Layout: Layout's Handrail Height, 37 in unless overwritten; check box not sent | Handrail height |
| `HandrailORKickPlate` | Hidden switch copied from DW HandRails. Nothing here builds a kick plate. Unless it is "Handrail", the railing-height overwrite, the side-clip holes and both ladder boxes are hidden and forced off, More Than 10ft is forced on, and the Railing Inputs frame shrinks. | Railing Inputs | Never shown. Handrail, Kick Plate. No default set. Layout: the zone's connection, "Railing" or "Kick Plate". "Railing" isn't in the list, so the combo box falls back to its first item, Handrail | None: a Kick Plate zone gets the same full guard railing as a Railing zone, only without the Handrail-only options |
| `HoleFor90DegLadderLeft`, `HoleFor90DegLadderRight` | Holes for a 90° ladder. Right adds the hole to both guard posts. Left adds no hole; it only makes the posts custom. | Railing Inputs | Shown only for Handrail. Default off; forced off otherwise. Layout: off |  |
| `HolesForSideClips` | Side-bracket (clip) holes in the guard posts. | Railing Inputs | Shown only for Handrail. Default off; forced off for Kick Plate zones. Layout sends on, so hosted Railing zones get them. Off makes the posts custom |  |
| `OutsideCornerLeft`, `OutsideCornerRight` | "Left/Right Outside Corner Opt.": Short where the railing turns round an outside corner of the platform. That end gets the long handrail post, the guard panel loses its end tab, and the handrail is 4.0625 in shorter, or 2.4375 in when the railing letter is A, C, E, G or I. | Overhang Inputs | False, Short. No default set. Layout: "Short" when Layout's `RailingList` finds a Railing zone round that corner, otherwise FALSE | Handrail end at an outside corner |
| `ShortCornerLeft`, `ShortCornerRight` | "Left/Right Inside Corner Opt.". True: the guard panel, its end-post plane and the top rail end 2 in short, the handrail runs 2.3125 in further, and the slot pattern at that end loses one slot (except at the right end of a one-opening panel). Long: only the handrail runs 4 in further. | Overhang Inputs | False, True, Long. No default set. Layout: TRUE or FALSE from `RailingList`, or "Long" for a long inside corner | Panel end and handrail end at an inside corner |
| `OverHangLeft`, `OverHangRight` + `LeftOverHangLenght`, `RightOverHangLength` | Overhang: the top rail and the handrail run past that end by the length (in). | Overhang Inputs | Check box enabled only when both corner options on that side are False. With no default set they start blank, so it stays locked until they are set. Length 0–100 in, shown only with the check box, default 0. Check box default off. Layout: not sent | That end's rails reach past the post |
| `HighPriority` | High-priority job: priority tag 3 instead of 103. | Details | Engineering only. Default off. Layout: Layout's High Priority |  |
| `DevRelease` | Releases the railing as a development test (Release Local, tag 99). | Details | Development team only. Default off. Layout: Layout's Dev Release |  |
| `CheckBox1_OutputDXFFlatState`, `CheckBox1_OutputPDF`, `CheckBox1_OutputStep`, `CheckBox1_Etching`, `OutputEASM` | Output switches: DXF flat patterns, PDF drawings, STEP files of the bent parts, etching, eDrawings assembly. Only STEP and eDrawings reach a rule here. | Extra Stuff | Never shown. Default off. Layout: constant `OverwriteCheckAllFileOutputs` = TRUE forces the first four on and eDrawings off |  |
| `Index` | Railing number on its platform. Nothing reads it. | Extra Stuff | Never shown, and locked. 0–9999. Default 0. Layout: `SpinButton2` |  |
| `Show25LFQty` | Shows the 25LF quantity: the work-order total from Layout, or this railing's posts. The 25LF file name uses this railing's posts either way. | Extra Stuff | Never shown |  |
| `ThicknessOfFloor2` | Floor thickness (in), added to the guard posts' middle hole height. The visible Thickness Of Floor doesn't feed it. | Test Form | Never shown. Same options as Thickness Of Floor. No default set. Layout: not sent, so always blank |  |
| `PlatformThickness2` | Feeds two variables that nothing uses. | Test Form | Never shown. 0–100. Default 0 |  |
| `PostToPostWidth2`, `AssemblyNumber2`, `WOPrefix2`, `Color2`, `ColorCode2`, `PaintRed2`, `PaintGreen2`, `PaintBlue2`, `ColorName2`, `OverwriteRailingHeight2`, `GuardRailHeight2`, `OverwriteHandrailHeight2`, `HandRailHeight2`, `OutsideCornerLeft2`, `OutsideCornerRight2`, `InsideCornerLeft2`, `InsideCornerRight2`, `OverHangLeft3`, `OverHangRight2`, `LeftOverHangLenght2`, `RightOverHangLength2`, `FrontHole` | An older copy of the inputs. Nothing outside this page reads them. | Test Form | Never shown |  |

Left out on purpose: labels (the Sparta height note, and the three code notes: Canada SOR/86-304 maximum 43.3 in, New Brunswick 91-191 maximum 42.125 in, California Building Code minimum 42 in), pictures, frames, the section toggles (`…CheckExtend`), and the Close, Save and Close, and Release buttons. The form pictures are in `HandRails outside/Form/` (`DimensionInput.png`, `OverhangOptions.png`).

## How Platform Layout sets the railings

DW Platform Layout is the parent. It hosts this project in `RailingHostControl`, one spec per Railing or Kick Plate zone of each platform, when its Outside Railing is on. Otherwise it hosts DW HandRails ([handrails-inputs.md](handrails-inputs.md)). The loops and tables are in [platform-layout-inputs.md](platform-layout-inputs.md). Only Layout uses this project: Straight and Picking's own railing route, which is inactive on purpose, names DW HandRails only.

The engine applies Layout's Name/Value table `DWCalcRailingListInput` as described in [handrails-inputs.md](handrails-inputs.md): names ignore case, the first row with a name wins, unknown names are ignored, and values are written as is. A combo box whose value isn't in its list then falls back to its first item (`SelectedItemRemovedBehavior` = SelectFirst).

| Child input | Set from | Notes |
| --- | --- | --- |
| `PostToPostWidth` | The zone's `ActualWidthXn` | Railing length |
| `HandrailORKickPlate` | The zone's connection: "Railing" or "Kick Plate" | "Railing" falls back to Handrail, so Railing zones get the Handrail-only options. "Kick Plate" stays, so those options are forced off, and the zone still gets a full guard railing |
| `AssemblyNumber` | "A" & platform number & letter, for example A100A |  |
| `Letter` (constant) | A, B, C… per railing on the platform | Sets the handrail cut at an outside corner |
| `AssemblyNumberNoLocation` (constant) | "A" & platform number | Files go to `\\192.168.0.19\Driveworks Output Files\<prefix>` |
| `ShortCornerLeft`, `ShortCornerRight` | TRUE or FALSE from `RailingList`, or "Long" | All three are options here |
| `OutsideCornerLeft`, `OutsideCornerRight` | "Short" or FALSE |  |
| `RailingHeight` | Layout's Railing Height, 43.25 unless overwritten | Drives the post height directly, although the box is locked here |
| `HandRailHeight` | Layout's Handrail Height, 37 unless overwritten |  |
| `OverwriteRailingHeight` | Two rows: FALSE (row 12), then Layout's Overwrite Default Railing Height (row 45) | Row 12 wins. It is forced off here anyway |
| `PlatformThickness` | The platform's value | Guard post slot |
| `NoCutThroughinHandrail` | The platform's value | Reaches `NoCutThroughInHandrail`, which changes nothing |
| `HolesForSideClips` | TRUE | Kept for Railing zones, which fall back to Handrail. Forced off for Kick Plate zones |
| `HoleFor90DegLadderLeft`, `HoleFor90DegLadderRight` | FALSE |  |
| `OverwriteCheckAllFileOutputs` (constant) | TRUE | STEP on and eDrawings off; the other switches do nothing here |
| `OverwriteOverhangCheck` (constant) | TRUE | Nothing here uses it. The overhangs stay off because Layout doesn't send them |
| `WorkOrder`, `WOPrefix`, `Client`, `Project` | Layout's values |  |
| `HostedClientName`, `HostedWOPrefix`, `HostedWorkOrderNumber`, `HostedProjectName` (constants) | Layout's values | They drive the Client, Project, Work Order and prefix text boxes, and turn New Client Project on |
| `Color`, `ColorCode`, `PaintRed`, `PaintGreen`, `PaintBlue` | Layout's handrail colour |  |
| `EtchingType`, `DevRelease`, `HighPriority` | Layout's inputs |  |
| `NumberOf25LFinWO` (constant) | Sum over all platforms | Only shown in the hidden `Show25LFQty` |
| `NumberOfK40inWO`, `NumberOfK41inWO`, `PushedDownClientName`, `PushedDownClientEmail` (constants) | The platform's values | The constants exist, but nothing here uses them |
| `Index` | `SpinButton2` | Nothing reads it |
| `OverwriteCustomFloorPlateThicknessGap` | FALSE | DW HandRails only. Ignored here |
| `Location`, `ShippingAssembly`, `OutsideRailing`, `Enable<preThan10ftTopRail` | Zone, the platform's SA, Layout's input, FALSE | No such names here, so ignored |

**No parent sets:** `ThicknessOfFloor`, `ThicknessOfFloor2`, `OverwriteHandrailHeight`, `IncludedANumberInName`, `PutAllInWOFolder`, `EnableMoreThan10ftTopRail`, the overhangs and `TextBox1_DesignerDrafter`. Hosted railings keep their defaults. The two floor thicknesses have no default, so the post height and the middle post hole get a blank added. `OverwriteHandrailHeight` only unlocks the box; Layout's height arrives without it.

**Who sees this form.** In Layout the host sits on the Railing Debug page inside the For Dev frame, which is 0 px high except for the Development team. So only Development ever sees a hosted railing form. On its own, the project is visible in the group, but in the sandbox only the Administrators, Developement and Engineering teams have rights to it. A non-Engineering user who releases a layout with Outside Railing on still gets these railings, because Layout's macros create the specs. Nothing here depends on the user except the visibility of High Priority and Dev Release, whose values come from Layout.

## Size and position in a layout

- **Units are inches.**
- **Placement** (from Layout): railings go into the top-level assembly, not into the shipping assemblies. Layout mates the railing assembly (`<prefix>-<assembly>-With Onsite Bolts Assy`) the same way as DW HandRails:
  - its Right plane to the zone plane, which marks the zone's centre, so the railing is centred on its zone;
  - its Front to the zone face, the platform's side face;
  - its Top to the platform's `TopRail` plane.
- **Distance from the platform edge:** the guard posts bolt to the platform's side face, with the top of their slot depth/2 − 1 in below the platform top. No input moves the railing in or out, and the mates are the same as for DW HandRails, so any difference between inside and outside mounting is in the SOLIDWORKS models. The handrail post flanges are fixed by rule: 2 in on the K42 post, 2.1875 in on the K43 post, 4 in on the long K46 post.
- **Length:** the guard panel spans width − 0.875 in, centred on the zone, less 2 in at an inside corner set to True. The top rail and the handrail each reach (width − 0.125)/2 either side of the centre, plus any overhang. Then at each end:
  - top rail: −2 in at a True inside corner;
  - handrail: −4.0625 or −2.4375 in at a Short outside corner, +4 in at a Long inside corner, +2.3125 in at a True inside corner.
- **Posts:** 2 to 4 guard posts, splitting the panel into equal openings, plus handrail posts at each end and in the middle. Zones from Layout are at most about 120 in, so the openings stay under 46 in.
- **Height:** the guard posts stand Railing Height + Thickness Of Floor above the platform top: 43.25 in plus a blank floor thickness when hosted. The guard panel is 42.25 in tall. The handrail sits Railing Height − Hand Rail Height below the guard rail top, 6.25 in when hosted with Layout's defaults.
- **Kick plate versus railing:** there is no kick plate here. A Kick Plate zone gets the same guard railing.
- **Corners:** Short outside corners, and True or Long inside corners, as above. At an outside corner the handrail cut alternates with the railing letter, so the two handrails meeting there differ by 1.625 in.
- **Stairs and ladders:** this project makes no gaps. Layout gives a Stairs or Rung Ladder zone no railing, and makes the next railing's inside corner True when the neighbour is Platform or a Stairs type. The ladder check boxes only drill the guard posts, and they are always off here.

## Notes and open questions

- **Who counts as a Sparta user.** The form tests `IsUserInEngineering` (Engineering or Xortion Engineering) for High Priority, and `IsUserInDevelopement` for Dev Release. `IsUserInSparta` exists but nothing uses it. No input depends on the user otherwise.
- **Railing Inputs is cut off.** The Railing Inputs frame's height comes from `HolesForSideClips` for Handrail, otherwise from `ShortCornerLeft` on the Overhang page: 98 + 25 + 10 = 133 px. `HandrailORKickPlate` is hidden with no default. Its stored design value is Handrail (`SelectedItemSource`). If it starts blank on its own, the frame is 133 px with its scroll bar hidden. Check this in DriveWorks. Everything from Post To Post Width (top 136 px) down can't be reached: the length, both heights and their overwrites. Opened on its own, a railing keeps Post To Post Width = 0. Hosted railings get their values from Layout, so this only bites when the project is opened directly.
- **"Railing" in, "Handrail" out.** Layout sends the platform zone's word, "Railing" or "Kick Plate". "Railing" isn't in this hidden switch's list, so the combo box falls back to its first item, Handrail.
  - **Railing zones:** the Handrail-only options are live, and Layout's side-clip holes are kept.
  - **Kick Plate zones:** they stay "Kick Plate". The side-clip holes, the ladder holes and the railing-height overwrite are forced off, More Than 10ft is forced on, and the posts become custom-named. The zone still gets a full guard railing, because this project has no kick plate.
- **The visible floor thickness and the hidden one.** Thickness Of Floor sets the guard post height. The hidden `ThicknessOfFloor2` sets the middle post hole. Layout sends neither, and neither has a default. Variable `ThicknessofFloorInput` also reads `ThicknessOfFloor2`, but nothing uses it.
- **Opening count gaps.** The rule returns nothing when the panel is exactly 46 in, and when Post To Post Width is 92 in or more while the panel is still under 92 in: 92 to 92.875 in without inside corners, and up to 96.875 in with both set to True. It also never goes above 3 openings, so widths over 138 in would give openings over 46 in. Constants `MaxOpeningBetweenPost` (46) and `MaxPostToPost` (118) exist, but nothing uses them.
- **Railing letters J, K and L.** The outside-corner handrail cut tests `IsOdd(HexFromString(Letter))`. I ran `HexFromString` from `DriveWorks.Engine.dll`: A→41 … I→49 are numbers, but J, K and L give 4A, 4B, 4C, and an empty letter (opened on its own) gives an empty string. A platform with ten or more railings would hit this.
- **Left and right look crossed.** A Short outside corner on the left swaps in the *Right* Handrail Post long, and the right one the *Left* post. Both guard posts take the ladder hole from the Right check box. Check whether left and right are seen from the other side, or swapped by mistake.
- **No default is set** for Etching Type, Thickness Of Floor, both corner options on each side, Handrail Or Kick Plate, Assembly Number, Client and Project. Post To Post Width defaults to 0, below its minimum of 6.
- **Missing pieces copied from DW HandRails.** The Visible rules of Client, Project, Work Order and New Client Project test `DWConstantPushedDownThicknessOfFloor`, Work Order Prefix's Enabled rule tests `DWConstantPushedDownShippingAssy`, and Work Order's default reads `DWConstantWorkOrder`. None of these constants exists here. The release flow releases document `NewColourSpecs` and macro `NewClientProject` releases document `NewClientProject`, but this project has no documents. Variable `RaillingDiff`, which reads Railing Height where Hand Rail Height was probably meant, feeds only `TopHoles`, which nothing uses.
- **STEP file names.** The STEP file-name rules of the post kits put "*" before the If, so with STEP off they return "*Delete" instead of "Delete". Check that DriveWorks still skips those files.
- **Exports.** There is no SQL table, no group-table export and no email document.
- **Inside versus outside.** DW HandRails builds an open railing: posts, a top rail, a mid rail and a toe board, or a kick plate alone. This project builds a laser-cut guard panel between guard posts (K40, K41), with a top rail, and a separate handrail on its own posts (K42–K46) at Hand Rail Height. Other differences:
  - here Railing Height drives the post height directly; DW HandRails fixes it at 43.25 in unless overwritten;
  - here an inside corner set to True is 2 in, and there are Long inside corners and Short outside corners; DW HandRails has only a 2.125 in short corner;
  - DW HandRails has the kick plate model, the mid and toe overhangs, the custom floor-plate gap, the Colors and ClientProjects exports and the completion email; this project has none of them;
  - only this project uses `Letter`; only DW HandRails uses `OverwriteOverhangCheck`, `NumberOfK40inWO` and `NumberOfK41inWO`;
  - this form has 104 controls, 25 of them on the hidden Test Form, against 81 for DW HandRails. Both have 103 variables.
- **Sandbox registration.** DW HandRails outside is visible but `Deployed=False`, yet Layout uses it whenever Outside Railing is on. DW HandRails is `Deployed=True`. Check the production group before relying on the outside railings.
