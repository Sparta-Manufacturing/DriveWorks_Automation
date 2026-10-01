# DW HandRails: form inputs

*Read from `DriveWorks Files/HandRails/DW HandRails.driveprojx` as saved 2026-02-10 17:03. Written 2026-10-01 for Bruno's pre-sales layout app, which should use the same parameters as DriveWorks.*

This table lists every input on the DW HandRails form, the railing or kick plate along one edge zone of a platform, so the layout app can use the same parameter names.

- **DriveWorks Input**: the control name exactly as it appears in DriveWorks.
- **Description**: what the input is for, inferred from its caption, options and rules.
- **Group**: the form page the input sits on.
- **Limitation**: minimum, maximum, option list, or an override limit set by a rule. Empty when there is none.
- **Layout effect**: what the input changes in the railing's size or position in a layout. Empty when it changes neither.

## Inputs

Rows follow the form from top to bottom: the three sections that the Main Window stacks (Customer Info, Railing Inputs, Overhang Inputs), the footer, then the Extra Stuff page, which no frame shows. Left and right twins and paired controls share a row. Units are in the description, and defaults are at the end of the limitation, followed by what DW Platform Layout sends when it hosts the railing ("Layout:"). "Layout: not sent" means the hosted railing keeps this project's default.

| DriveWorks Input | Description | Group | Limitation | Layout effect |
| --- | --- | --- | --- | --- |
| `CheckBox1_NewClientProject` | Switches Client and Project to the text boxes. | Customer Info | Driven by a rule: on when Layout sends a client (`HostedClientName`), otherwise blank. The user can't change it. Layout: on |  |
| `Client`, `TextBox1_Client` | Client: picked from a list, or the text box when New Client Project is on. Goes to the drawings' Client property. | Customer Info | List: every client in the ClientProjects group table. Layout: Layout's client, in both controls |  |
| `Project`, `TextBox1_Project` | Project: picked from the client's projects, or the text box. Goes to the drawings' Project property. | Customer Info | List filtered by the chosen client (ClientProjects). Layout: Layout's project |  |
| `WOPrefix` | Work order prefix. Starts every file name (`<prefix>-<assembly>-…`) and names the output folder. | Customer Info | Default: constant `WOPrefix`, else the client's prefix in ClientProjects. Locked when constant `PushedDownShippingAssy` is set. Layout: Layout's prefix (also `HostedWOPrefix`, which drives the text) |  |
| `TextBox1_DesignerDrafter` | Designer or drafter. Nothing reads it. | Customer Info | Layout: not sent |  |
| `WorkOrder` | Work order. Goes to the drawings' WO property. | Customer Info | Default: constant `WorkOrder`, else the client's work order in ClientProjects. Layout: Layout's work order (also `HostedWorkOrderNumber`) |  |
| `AssemblyNumber` | Assembly number, for example A100A. Second part of every railing file name. | Customer Info | No default set. Layout: "A" & platform number & railing letter |  |
| `Color` | Paint colour. | Customer Info | Options from the Colors group table. Default Sparta Blue. Layout: Layout's handrail colour |  |
| `ColorCode` | Colour code. Ends the post, rail and kick plate file names, for example `<prefix>-K40-<code>`. | Customer Info | Default looked up from the Colors group table. Editable only with Custom. Layout: Layout's handrail colour code |  |
| `PaintRed`, `PaintGreen`, `PaintBlue` | RGB values of a custom colour, written to the parts' DWColor property. | Customer Info | Shown only with Custom. 0–255. Default 0. Layout: Layout's custom handrail RGB |  |
| `ColorName` | Name of a custom colour, saved to the Colors group table on release. | Customer Info | Shown only with Custom. Layout: not sent |  |
| `NoCutThroughInHandrail` | No cut-through or arrow etching on the posts and mid rail, and no cut-through on the toe board. | Railing Inputs | Default off. Forced off and locked when the posts are custom (see the next row). Layout: the platform's No Cut Through In Handrail (Layout's default is on) |  |
| `IncludedANumberInName` | "Included A Number In Post Name": names the posts after this railing (`<prefix>-<assembly>-K40-…`) instead of one shared post file per work order (`<prefix>-K40-…`). The posts also become custom with either ladder hole, either overwrite, or without side-clip holes. | Railing Inputs | Default off. Layout: not sent |  |
| `PutAllInWOFolder` | Saves the files in folder `<prefix>` instead of `<prefix>-<assembly>-Railings-DW <spec id>`. | Railing Inputs | Default off. No effect when hosted: Layout's `AssemblyNumberNoLocation` already puts the files in `<prefix>` |  |
| `EtchingType` | Etching style: arrow, or cut-through marks. | Railing Inputs | Arrow, Cut Through. No default set. Layout: Layout's Etching Type |  |
| `HandrailORKickPlate` | Builds a handrail (posts, top rail, mid rail, toe board) or a kick plate only. Most railing options and the top and mid rail overhangs show only for Handrail. | Railing Inputs | Handrail, Kick Plate. No default set. Layout: the zone's connection, "Railing" or "Kick Plate". "Railing" is not one of the options, see the notes | Handrail: the full railing. Kick Plate: one plate. Any other value deletes both models |
| `PlatformThickness` | Platform frame depth (in). The post bolt holes sit at half this depth below the platform top, and the top of the post slot 1 in higher. Kick plate tabs are depth/2 + 3 in long. | Railing Inputs | 0–100. Default 8. Layout: the platform's Platform Thickness | How far the posts and tabs reach down the platform's side face |
| `PostToPostWidth` | Railing length (in), post to post. The end posts sit (width − 0.125)/2 either side of the railing's centre. Openings = RoundUp((width − 0.125)/46), so at most 46 in each; posts = openings + 1, spaced (width − 2.125)/openings. | Railing Inputs | 6–240. The rails have post cut-outs for at most 4 posts, so the model is built for widths up to 138.125 in. Default 0, below the minimum. Layout: the zone's modelled width (`ActualWidthXn`) | Length along the platform edge, centred on the zone. Number and spacing of posts |
| `EnableMoreThan10ftTopRail` | Allows a top rail over 10 ft. Without it the box shows an error when the top rail is over 120 in. | Railing Inputs | Shown only for Handrail. Default off; forced on for any other type. Layout: never arrives, its row is misspelt `Enable<preThan10ftTopRail` |  |
| `TopRailActualTopLength` | Read-only: top rail length (in) = width − 0.125 + the top-rail overhangs. It ignores short corners. | Railing Inputs | Read-only. Shown only for Handrail | Railing length |
| `OverwriteRailingHeight` + `RailingHeight` + `ThicknessOfFloor` | Railing height. Off: the top rail is 43.25 in above the platform top (the Sparta standard, 42 in over 1.25 in grating). On: Actual Railing Height (in, above the floor) + Thickness Of Floor (in). The mid rail sits at (height − 11)/2 + 8.75 in, so 24.875 in by default. | Railing Inputs | Check box shown only for Handrail, default off. Height 30–50 in, default 0, below the minimum. Floor 0.125, 0.1875, 0.25, 0.375, 1, 1.125, 1.25, 1.5, no default set. Both shown only with the check box. On makes the posts custom. Layout: check box always off (its first row, FALSE, wins), so Layout's Railing Height is ignored; floor thickness not sent | Railing height above the platform |
| `OverwriteCustomFloorPlateThicknessGap` + `CustomFloorPlateThickness` | Toe-board gap. The toe board's `Width` is 7.5 in − gap. The gap is 0.25 in (3/16 in plate + 1/16 in) unless overwritten with plate thickness + 1/16 in. | Railing Inputs | Check box shown only for Handrail, default off. Thickness 0–100 in, default 0, shown only with the check box. On makes the posts custom. Layout: off |  |
| `ShortCornerLeft`, `ShortCornerRight` | Short corner at that end: the end post moves 2.125 in inward, and the top rail, mid rail, toe board or kick plate end with it. | Railing Inputs | Default off. Layout: on when the next zone is Platform or a Stairs type, or at a platform corner the platform's Over Write Short Corner value. Layout sends "Long" for a long inside corner, which this check box can't hold: it acts as off | That end is 2.125 in shorter |
| `HoleFor90DegLadderLeft`, `HoleFor90DegLadderRight` | Adds a hole for a 90° ladder to the left posts (the K40 part, shared by the left and middle posts) or to the right post (K41). It adds a hole, not a gap. | Railing Inputs | Shown only for Handrail. Default off; forced off for any other type. On makes the posts custom. Layout: off |  |
| `HolesForSideClips` | Side-bracket (clip) holes in the posts. | Railing Inputs | Shown only for Handrail. Default off; forced off for any other type. Off makes the posts custom. Layout: on |  |
| `OverHangTopRailLeft`, `OverHangTopRailRight` | The top rail runs past the end post by the overhang length. | Overhang Inputs | Shown only for Handrail. Default off; forced off for any other type and when constant `OverwriteOverhangCheck` is TRUE. Layout: forced off | That end of the top rail is longer |
| `OverHangMidRailLeft`, `OverHangMidRailRight` | The mid rail runs past the end post, with an end tab. | Overhang Inputs | Same as the top rail. Layout: forced off | That end of the mid rail is longer |
| `OverHangToePlateLeft`, `OverHangToePlateRight` | The toe board, or the kick plate, runs past the end post. | Overhang Inputs | Default off; forced off when `OverwriteOverhangCheck` is TRUE. Layout: forced off | That end of the toe board or kick plate is longer |
| `OverHangLengthLeft`, `OverHangLengthRight` | Overhang length (in) at that end, for every overhang checked on that side. | Overhang Inputs | Shown when an overhang on that side is on. 1–48 in. Default 0, below the minimum. Layout: not sent, and 0 since every overhang is off | How far that end reaches past the post |
| `HighPriority` | High-priority job: priority tag 3 instead of 103. | Details | Engineering only. Default off. Layout: Layout's High Priority |  |
| `DevRelease` | Releases the railing as a development test (Release Local, tag 99). | Details | Development team only. Default off. Layout: Layout's Dev Release |  |
| `CheckBox1_OutputDXFFlatState`, `CheckBox1_OutputPDF`, `CheckBox1_OutputStep`, `CheckBox1_Etching`, `OutputEASM` | Output switches: DXF flat patterns, PDF drawings, STEP files of the bent parts, etching, eDrawings assembly. | Extra Stuff | Never shown. Default off, so a railing opened on its own makes none of these. Layout: constant `OverwriteCheckAllFileOutputs` = TRUE forces the first four on and eDrawings off |  |
| `Index` | Railing number on its platform. Nothing reads it. | Extra Stuff | Never shown, and locked. 0–9999. Default 0. Layout: `SpinButton2` |  |
| `Show25LFQty` | Shows the 25LF part quantity: the work-order total from Layout, or this railing's number of posts. | Extra Stuff | Never shown |  |

Left out on purpose: labels (the Sparta height note, and the three code notes: Canada SOR/86-304 maximum 43.3 in, New Brunswick 91-191 maximum 42.125 in, California Building Code minimum 42 in), pictures, frames, the section toggles (`…CheckExtend`), and the Close, Save and Close, and Release buttons. The pictures come from `Form Design Documents/RailingMeasurements.PNG` and `Overhangs.PNG`.

## How Platform Layout sets the railings

DW Platform Layout is the parent. It hosts this project in `RailingHostControl`, one spec per Railing or Kick Plate zone of each platform, when its Outside Railing is off. Otherwise it hosts DW HandRails outside ([handrails-outside-inputs.md](handrails-outside-inputs.md)). The loops and tables are in [platform-layout-inputs.md](platform-layout-inputs.md).

How the engine applies Layout's Name/Value table `DWCalcRailingListInput` (read from `DriveWorks.Engine.dll`: `SpecificationHostControl.GetInputs`, then `TitanDesignMaster.SetNamedItemValues`):
- names match a control or a constant, ignoring case, so `NoCutThroughinHandrail` reaches `NoCutThroughInHandrail`;
- **the first row with a given name wins**; a later row with the same name is skipped;
- a name the project doesn't have is ignored;
- the value is written as is. I found no check against the option list or the min/max.

| Child input | Set from | Notes |
| --- | --- | --- |
| `PostToPostWidth` | The zone's `ActualWidthXn` | Railing length |
| `HandrailORKickPlate` | The zone's connection: "Railing" or "Kick Plate" | "Railing" is not an option here. See the notes |
| `AssemblyNumber` | "A" & platform number & letter, for example A100A |  |
| `AssemblyNumberNoLocation` (constant) | "A" & platform number | Files go to `\\192.168.0.19\Driveworks Output Files\<prefix>`. Put All In WO Folder no longer matters |
| `ShortCornerLeft`, `ShortCornerRight` | TRUE or FALSE from Layout's `RailingList`, or "Long" | "Long" acts as off in this check box |
| `OverwriteRailingHeight` | Two rows: FALSE (row 12), then Layout's Overwrite Default Railing Height (row 45) | Row 12 wins, so it is always off |
| `RailingHeight` | Layout's Railing Height, 43.25 unless overwritten | Ignored, because the overwrite is off |
| `PlatformThickness` | The platform's value | Post and kick plate holes |
| `NoCutThroughinHandrail` | The platform's value |  |
| `HolesForSideClips` | TRUE | Forced off again unless the type is Handrail |
| `HoleFor90DegLadderLeft`, `HoleFor90DegLadderRight` | FALSE |  |
| `OverwriteCustomFloorPlateThicknessGap` | FALSE |  |
| `OverwriteOverhangCheck` (constant) | TRUE | Forces all six overhang check boxes off |
| `OverwriteCheckAllFileOutputs` (constant) | TRUE | DXF, PDF, STEP and etching on; eDrawings off |
| `WorkOrder`, `WOPrefix`, `Client`, `Project` | Layout's values |  |
| `HostedClientName`, `HostedWOPrefix`, `HostedWorkOrderNumber`, `HostedProjectName` (constants) | Layout's values | They drive the Client, Project, Work Order and prefix text boxes, and turn New Client Project on |
| `Color`, `ColorCode`, `PaintRed`, `PaintGreen`, `PaintBlue` | Layout's handrail colour |  |
| `EtchingType`, `DevRelease`, `HighPriority` | Layout's inputs |  |
| `NumberOf25LFinWO` (constant) | Sum over all platforms | Quantity in the 25LF STEP file name |
| `NumberOfK40inWO`, `NumberOfK41inWO` (constants) | The platform's values | AutoQty property of the K40 and K41 post kits |
| `PushedDownClientName`, `PushedDownClientEmail` (constants) | The platform's values | Name and address of the completion email |
| `Index` | `SpinButton2` | Nothing reads it |
| `Letter`, `OutsideCornerLeft`, `OutsideCornerRight`, `HandRailHeight` | Layout's values | DW HandRails outside only. Ignored here |
| `Location`, `ShippingAssembly`, `OutsideRailing`, `Enable<preThan10ftTopRail` | Zone, the platform's SA, Layout's input, FALSE | No such names here, so ignored |

**No parent sets:** `ThicknessOfFloor`, `CustomFloorPlateThickness`, `IncludedANumberInName`, `PutAllInWOFolder`, `EnableMoreThan10ftTopRail`, the overhang lengths and `TextBox1_DesignerDrafter`. Hosted railings keep their defaults. Floor thickness and plate thickness matter only with their overwrites, which Layout keeps off.

**The unused route.** DW Platform - Straight and DW Platform - Picking also host DW HandRails, in `HostForRailing` with table `RailingListInputs`. The user confirmed this route is inactive on purpose: railings sit outside the shipping assemblies, so Layout makes them.

**Who sees this form.** In Layout the host sits on the Railing Debug page inside the For Dev frame, which is 0 px high except for the Development team. So only Development ever sees a hosted railing form. On its own, the project is visible in the group, but in the sandbox only the Administrators, Developement and Engineering teams have rights to it. A non-Engineering user who releases a layout still gets railings: Layout's macros create the specs. Nothing here depends on the user except the visibility of High Priority and Dev Release, whose values come from Layout. So the railing is the same as for an Engineering user.

## Size and position in a layout

- **Units are inches.**
- **Placement** (from Layout): railings go into the top-level assembly, not into the shipping assemblies. Layout mates the railing assembly (`<prefix>-<assembly>-With Onsite Bolts Assy`):
  - its Right plane to the zone plane, which marks the zone's centre, so the railing is centred on its zone;
  - its Front to the zone face, the platform's side face;
  - its Top to the platform's `TopRail` plane.
- **Distance from the platform edge:** the posts bolt to the platform's side face, with holes at half the platform depth below the top. No input moves the railing in or out. Any offset between the railing's Front plane and the posts is fixed in the SOLIDWORKS model.
- **Length:** the end posts sit (width − 0.125)/2 from the zone centre, less 2.125 in at a short corner. The top rail, mid rail, toe board and kick plate end at the end posts, plus any overhang. Hosted railings never have overhangs.
- **Posts:** at most 46 in apart. Example: a 96 in zone gives 3 openings and 4 posts, 31.292 in apart. Zones from Layout are at most about 120 in, so a hosted railing has 2 to 4 posts and stays under the 10 ft top-rail limit.
- **Height:** the top rail is 43.25 in above the platform top, and the mid rail 24.875 in. Only the Overwrite Railing Height check box changes this, and Layout can't turn it on.
- **Kick plate versus railing:** Kick Plate builds only the kick plate (`<prefix>-<assembly>-1LP-<colour>-YD`, a yard part), with the same length and short-corner rules. Its height is fixed in the model. Handrail builds the posts, top rail, mid rail and toe board.
- **Corners:** a short corner pulls that end in by 2.125 in so the railing clears the neighbour's. This project has no long-corner or outside-corner option; DW HandRails outside has both.
- **Stairs and ladders:** this project makes no gaps. Layout gives a Stairs or Rung Ladder zone no railing at all, and it makes the next railing's end short when the neighbour is Platform or a Stairs type, but not a Rung Ladder. The 90° ladder holes only drill a post, and Layout sends them off.

## Notes and open questions

- **Who counts as a Sparta user.** The form tests `IsUserInEngineering` (Engineering or Xortion Engineering) for High Priority, and `IsUserInDevelopement` for Dev Release. `IsUserInSparta` exists but nothing uses it. No input depends on the user otherwise.
- **"Railing" is not an option.** Layout sends the zone's connection, "Railing" or "Kick Plate", to `HandrailORKickPlate`, whose options are Handrail and Kick Plate. The engine writes the value as is, so a Railing zone gets "Railing". Every rule here tests for "Handrail", so for a Railing zone:
  - the railing model (`DW04-A160`) and the kick plate (`DW04-A161`) are both deleted, which leaves only the bolts assembly;
  - Holes For Side Clips is forced off, so the posts become custom-named;
  - Enable More Than 10ft is forced on.

  Kick Plate zones work. This needs a test release. Either the zone option should read Handrail, or the rules here should accept "Railing".
- **Layout's railing height never arrives.** Its table sends `OverwriteRailingHeight` twice, FALSE first. The engine keeps the first, so every hosted railing is 43.25 in tall, whatever Layout's Railing Height says.
- **No default is set** for Handrail Or Kick Plate, Etching Type, Thickness Of Floor, Assembly Number, Client and Project. **Defaults below the minimum:** Post To Post Width 0 (min 6), Actual Railing Height 0 (min 30) and the overhang lengths 0 (min 1). Layout sends Post To Post Width; the other two matter only when their check boxes are on.
- **Missing constants.** The Visible rules of Client, Project, Work Order, Work Order Prefix and New Client Project test `DWConstantPushedDownThicknessOfFloor`, and Work Order Prefix's Enabled rule tests `DWConstantPushedDownShippingAssy`. Neither constant exists in this project; they were copied from the platform projects. Check in Administrator whether these fields show.
- **Exports.** There is no SQL table. On release the flow writes the colour to the Colors group table (`NewColourSpecs`), then releases every document (`*`), which includes `NewClientProject` (client, project, work order and prefix to the ClientProjects group table). An email with the railing PDF goes to `PushedDownClientEmail`, or the current user.
- **Switched off for good:** the cut-list drawing (`If( TRUE = TRUE ,"Delete" ,…)`) and the toe board's `CutPart` feature, whose rule returns "Delete" both ways.
- **Inside versus outside.** DW HandRails builds an open railing: posts, a top rail, a mid rail at 24.875 in and a toe board, or a kick plate alone. DW HandRails outside builds a laser-cut guard panel between guard posts, with a top rail and a separate handrail on its own posts at Hand Rail Height. Other differences:
  - this project has the kick plate model, the mid and toe overhangs and the custom floor-plate gap; outside has none of them;
  - here the railing height is fixed at 43.25 in unless overwritten; outside, Railing Height drives the post height directly;
  - here a short corner is 2.125 in; outside, an inside corner set to True is 2 in, and outside also has Long inside corners and Short outside corners;
  - only this project uses `OverwriteOverhangCheck`, `NumberOfK40inWO` and `NumberOfK41inWO`; only outside uses `Letter`.
- **Sandbox registration.** DW HandRails is visible and `Deployed=True`. DW HandRails outside is `Deployed=False`, yet Layout uses it whenever Outside Railing is on.
