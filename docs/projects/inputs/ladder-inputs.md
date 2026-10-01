# DW Ladder: form inputs

*Read from `DriveWorks Files/Ladder/DW Ladder.driveprojx` as saved 2026-05-06 11:01. Written 2026-10-01 for Bruno's pre-sales layout app, which should use the same parameters as DriveWorks.*

This table lists every input on the Ladder DriveWorks form, so the layout app can use the same parameter names.

- **DriveWorks Input**: the control name exactly as it appears in DriveWorks.
- **Description**: what the input is for, inferred from its caption, options and rules.
- **Group**: the form page the input sits on.
- **Limitation**: minimum, maximum, option list, or an override limit set by a rule. Empty when there is none.
- **Layout effect**: what the input changes in the ladder's size or position in a layout. Empty when it changes neither.

## Inputs

Rows follow the form from top to bottom: the four sections of the left panel, then the footer, then the Extra Info form, which the form never shows. Paired controls (a box and a slider that mirror each other) and controls that do one job share a row. Only Engineering users can open Customer Info (see the notes). Units are in the description, and defaults are at the end of the limitation.

| DriveWorks Input | Description | Group | Limitation | Layout effect |
| --- | --- | --- | --- | --- |
| `CheckBox1_NewClientProject` | "New Client Project": switches Client and Project to free text. | Customer Info | Default off |  |
| `ComboBox1_Client`, `TextBox1_Client` | Client: picked from a list, or typed when New Client Project is on. | Customer Info | List from the ClientProjects group table |  |
| `ComboBox1_Project`, `TextBox1_Project` | Project: picked from the client's projects, or typed. | Customer Info | List filtered by the chosen client |  |
| `TXTBox_ConveyorNaming` | "WO Prefix": work-order prefix. It starts the specification name and every file name. | Customer Info | Default looked up from the ClientProjects group table (WOPrefix column) for the client |  |
| `AssemblyNumber` | Assembly number n. The ladder assembly is A&lt;n&gt; and the cage A&lt;n+1&gt;. It goes into the specification and file names. | Customer Info | No default set |  |
| `Color` | Main paint colour: the ladder sections and rungs. Its code goes into the part file names. | Customer Info | Options from the Colors group table. Default Sparta Blue |  |
| `ColorCode` | Paint colour code (e.g. BL). | Customer Info | Editable only for Custom. Default from the Colors group table |  |
| `PaintRed`, `PaintGreen`, `PaintBlue` | Custom paint colour, RGB. | Customer Info | Shown only for Custom. 0–255. Default 0 |  |
| `ColorName` | Name of the custom paint colour. | Customer Info | Shown only for Custom |  |
| `AlternateCageColor` | Gives the cage and gate their own colour. Off means they use the paint colour. | Customer Info | Default off |  |
| `CageColor` | Cage paint colour: the cage and gate parts. | Customer Info | Shown only with Alternate Cage Color. Options from the Colors group table. No default set |  |
| `CageColorCode` | Cage colour code. | Customer Info | Shown only with Alternate Cage Color. Editable only for a Custom cage colour. Default from the Colors group table |  |
| `CageRed`, `CageGreen`, `CageBlue` | Custom cage colour, RGB. | Customer Info | Shown only for a Custom cage colour. 0–255. Default 0 |  |
| `CageColorName` | Name of the custom cage colour. | Customer Info | Its visibility rule tests `DWVariableHandRailColor` and `AlternateHandRailColor`, which don't exist in this project |  |
| `TextBox1_WorkOrder` | Work order number. | Customer Info | Default looked up from the ClientProjects group table (Work Order column) for the client |  |
| `DesignerDrafter` | Designer or drafter name. | Customer Info |  |  |
| `FloorToFloorHeight` + `FoorToFloorHeightSlider` | Floor-to-floor height (in): bottom floor to top floor surface. Box and slider mirror each other. Rungs are evenly spaced and at most 12 in apart: rungs = RoundUp((height − 0.375) ÷ 12). | Ladder Inputs | 16–357 in, slider in 0.01 in steps. No default set (box and slider default to each other) | Overall height. The ladder rails are floor-to-floor − 1 in + railing height long and stand on a 1 in bottom support, so the top of the ladder is the railing height above the top floor |
| `TopFloorThickness` | Thickness of the top floor (in). It sets the default railing height, 43.25 in − thickness. | Ladder Inputs | 3/16, 1, 1-1/4, 1-1/2. No default set; blank counts as 1 in | Default height of the ladder top above the top floor, and the platform bracket position |
| `GateSide` | Gate at the top exit, hinged on that side. | Ladder Inputs | Left, Right, None. No default set; blank gives no gate | Gate swing side at the top exit. None removes the gate assembly |
| `EtchingType` | Part marking: etched arrow or cut-through. | Ladder Inputs | Arrow, Cut Through. No default set; blank acts as Cut Through |  |
| `OverwritePlatformThickness` | "Overwrite Platform Thickness (Default is 8 in)". | Ladder Inputs | Default off |  |
| `PlatformThickness` + `PlatformThicknessSlider` | Thickness of the platform the ladder bolts to (in). Box and slider mirror each other. | Ladder Inputs | Shown only with Overwrite Platform Thickness. 4–18 in, slider in 0.25 in steps. Without the overwrite: 8 in | Height of the platform brackets: (top floor thickness + platform thickness) ÷ 2 below the top floor |
| `Cage` | "Cage Enabled": safety cage. | Cage Options | Default on. Dropped automatically when Overwrite Cage Height is off and the cage would be under 36 in, that is when floor-to-floor + railing height is under 120 in | Adds the cage, from Bottom Cage Height above the bottom floor to Top Cage Height below the top of the ladder |
| `OverwriteCageHeight` | "Overwrite Cage Height (default starts at 84 in)". | Cage Options | Shown only with Cage. Default off |  |
| `DesiredCageStartHeight` + `BottomCageSlider` | Bottom cage height (in): bottom floor to the bottom of the cage. Box and slider mirror each other. | Cage Options | Shown only with Cage and Overwrite Cage Height. 0 to floor-to-floor + railing height (the top of the ladder), slider in 1 in steps. Without the overwrite: 84 in | Where the cage starts |
| `DesiredHeightBetweenTopOfCageAndTopOfLadder` + `TopCageSlider` | Top cage height (in): gap from the top of the cage to the top of the ladder. Box and slider mirror each other. | Cage Options | Shown only with Cage and Overwrite Cage Height. 0 to floor-to-floor + railing height − bottom cage height, slider in 1 in steps. Without the overwrite: 0 | Where the cage ends |
| `OverwriteRailingHeight` | "Overwrite Railing Height (default is 43.25 − top floor thickness in)". | RailingInputs | Default off |  |
| `DesiredRailingHeight` + `DesiredRailingHeightSlider` | Railing height (in): top floor to the top of the ladder rails. Box and slider mirror each other. | RailingInputs | Shown only with Overwrite Railing Height. Box 12–80 in; slider 0–80 in, in 0.01 in steps. Without the overwrite: 43.25 in − top floor thickness | Height of the ladder top above the top floor. The ladder grows by the same amount |
| `HighPriority` | High-priority job (raises its queue priority on release). | Details | Default off. Engineering only |  |
| `DevRelease` | Releases the spec as a development test. | Details | Development team only. Default off |  |
| `OutputDXFFlatState`, `OutputPDF`, `OutputStep`, `Etching` | Output switches: DXF flat patterns, PDF drawings, STEP files of bent parts, part numbers etched on the DXFs. | Extra Info | Never shown: the Extra Info form sits in no frame. Default off. Output Etching shows only with DXF |  |

Left out on purpose: the section toggles (`…CheckExtend`), the Ladder Info picture toggle `LadderInfoCheckExtend`, the computed labels on Extra Info (cage section count, cage height, ladder height, cage points, section heights), pictures, the 3D preview, frames and buttons.

## Notes and open questions

- **Who counts as a Sparta user.** Three controls test teams. The Customer Info toggle and High Priority are shown only to Engineering or Xortion Engineering, and Dev Release only to Developement. `IsUserInSparta` exists but nothing uses it.
- **What a non-Engineering user gets.** They can't open Customer Info, so client, project, WO prefix, assembly number, work order and colours keep their defaults. There is no assembly number and no client, so the WO prefix lookup finds nothing, and the file names lose their prefix. The section header labels also read "Conveyor Options" for them, a leftover from the conveyor form. This path isn't used yet: Sparta's website access lets non-Engineering users reach only Kit Conveyor and the platform projects, so the Engineering/non-Engineering split here is only partly built.
- **How Ladder is opened.** On its own. DW Order Project opens only Kit Conveyor and Platform Layout. Platform Layout opens Platform Straight, Platform Picking, the two HandRails projects and Platform Bolts, and Straight and Picking open only DW HandRails. No project names DW Ladder, and Ladder has no child-spec definitions or hosted constants, so no parent sets any of its inputs. On Platform Straight and Picking, a "Rung Ladder" connection on a platform side changes only the platform: ladder connection holes in that side's frame, the grating end plates and widths, and a ladder in the platform's 3D preview. Platform Layout has `HoleFor90DegLadderLeft`/`Right` railing entries. None of these pass values to Ladder, so the layout app should copy floor-to-floor, top floor thickness and platform thickness from the platform itself.
- **Size and position for a layout.** Top of the ladder = floor-to-floor + railing height above the bottom floor (default railing height 43.25 in − top floor thickness). The bottom exit is at the floor, on a 1 in bottom support. The top exit is between the rails above the top floor, with an optional gate. The ladder bolts to the platform edge with brackets (top floor thickness + platform thickness) ÷ 2 below the top floor. The cage runs from 84 in above the bottom floor to the top of the ladder unless overwritten. The ladder ships in 1 to 4 sections, each at most 119 in long.
- **Footprint is not an input.** Ladder width, cage depth and the distance from the platform or wall are fixed in the model. The 3D preview puts the side rails at ±12 in from the centre line, and the platform forms note "24in Dim inside = 32in Outside for Ladder". Sparta engineering should confirm the outside width and the cage depth.
- **No default set** for Assembly Number, Cage Color, Top Floor Thickness, Gate Side and Etching Type. Floor-to-floor and the overwrite boxes default to their paired slider, so they have no fixed default either. Confirm what a new spec starts with.
- **Where specs go.** There is no SQL export. On release every document is released: `NewClientProjects` writes client, project, work order and WO prefix to the ClientProjects group table, `NewColourSpecs` writes the paint and cage colours to the Colors group table, and two emails go out. A 3D viewer document feeds the form's preview. The sandbox group holds no specifications.
- **Outputs are unreachable.** The Extra Info form is never shown, so Output PDF, DXF, STEP and Etching stay off. Every drawing PDF, including the main ladder drawing, is saved only with Output PDF on, yet the "done" email attaches that PDF. Confirm whether Extra Info should get a frame.
