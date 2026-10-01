# DW Stairs Project: form inputs

*Read from `DriveWorks Files/Stairs/DW Stairs Project.driveprojx` as saved 2026-09-21 14:37. Written 2026-09-30 for Bruno's pre-sales layout app, which should use the same parameters as DriveWorks.*

This table lists every input on the Stairs DriveWorks form, so the layout app can use the same parameter names.

- **DriveWorks Input**: the control name exactly as it appears in DriveWorks.
- **Description**: what the input is for, inferred from its caption, options and rules.
- **Group**: the form page the input sits on.
- **Limitation**: minimum, maximum, option list, or an override limit set by a rule. Empty when there is none.
- **Layout effect**: what the input changes in the stairs' size or position in a layout. Empty when it changes neither.

## Inputs

Rows follow the form from top to bottom: the five sections of the left panel, then the footer, then the Extra Stuff form, which the form never shows. Controls that do one job (a client list and a client box, three RGB boxes, read-only results) share a row. Units are in the description, and defaults are at the end of the limitation.

| DriveWorks Input | Description | Group | Limitation | Layout effect |
| --- | --- | --- | --- | --- |
| `CheckBox1_NewClientProject` | "New Client Project": switches Client and Project to free text. | Customer Info | Default off |  |
| `ComboBox1_Client`, `TextBox1_Client` | Client: picked from a list, or typed when New Client Project is on. | Customer Info | List from the ClientProjects group table |  |
| `ComboBox1_Project`, `TextBox1_Project` | Project: picked from the client's projects, or typed. | Customer Info | List filtered by the chosen client |  |
| `TextBox1_WorkOrder` | Work order number. | Customer Info | Default looked up from the ClientProjects group table (Work Order column) for the client |  |
| `TextBox1_DesignerDrafter` | Designer or drafter name. | Customer Info |  |  |
| `TXTBox_ConveyorNaming` | "WO Prefix": work-order prefix. It starts the specification name and every file name. | Customer Info | Default looked up from the ClientProjects group table (WOPrefix column) for the client |  |
| `EtchingType` | Part marking: etched arrow or cut-through. | Customer Info | Arrow, Cut through. No default set; blank acts as Cut through |  |
| `Color` | Main paint colour. Its code goes into the part file names. | Customer Info | Options from the Colors group table. Default Sparta Blue |  |
| `ColorCode` | Paint colour code (e.g. BL). | Customer Info | Editable only for Custom. Default from the Colors group table |  |
| `PaintRed`, `PaintGreen`, `PaintBlue` | Custom paint colour, RGB. | Customer Info | Shown only for Custom. 0–255. Default 0 |  |
| `ColorName` | Name of the custom paint colour. | Customer Info | Shown only for Custom |  |
| `AlternateHandRailColor` | Gives the handrails their own colour. Off means they use the paint colour. | Customer Info | Default off |  |
| `HandRailColor` | Handrail paint colour. | Customer Info | Shown only with Alternate Hand Rail Color. Options from the Colors group table. Default Galvanized, but its rule holds Sparta Yellow while the alternate colour is off |  |
| `HandRailColorCode` | Handrail colour code. | Customer Info | Shown only with Alternate Hand Rail Color. Editable only for Custom. Default from the Colors group table |  |
| `HandRailRed`, `HandRailGreen`, `HandRailBlue` | Custom handrail colour, RGB. | Customer Info | Shown only for a Custom handrail colour. 0–255. Default 0 |  |
| `HandRailColorName` | Name of the custom handrail colour. | Customer Info | Shown only for a Custom handrail colour |  |
| `StringerAssemblyNumber` | Assembly number n. The stringer assembly is A&lt;n&gt;, the left and right railings A&lt;n+1&gt; and A&lt;n+2&gt;. It goes into the specification and file names. | Customer Info | No default set |  |
| `RailingAssemblyNumber` | Read-only: the two railing assembly numbers, n+1 & n+2. | Customer Info | Read-only |  |
| `FloorToFloorHeigth` | Floor-to-floor height (in): the rise from the bottom floor to the top floor. It sets the step count: Round(height ÷ 7). | Stairs Inputs | 10–144 in. Default 0, below the minimum | Height of the stairs. With the pitch it also sets the horizontal run |
| `OverwritePitchWithTotalRun` | "Overwrite Pitch With Total Run (Horizontal Size)": enter the horizontal run instead of the pitch. | Stairs Inputs | Default off |  |
| `Pitch` | Stair angle from horizontal (deg). | Stairs Inputs | Hidden when Overwrite Pitch is on. 30–45°. Default 0, below the minimum | Incline. Horizontal run = floor-to-floor ÷ tan(pitch) + 0.25 in, plus (tread depth − step run) when the tread is deeper than the step run |
| `EnterTotalRun` | Total run (in): the horizontal size. The pitch becomes atan(floor-to-floor ÷ total run), rounded to 3 decimals. | Stairs Inputs | Shown only with Overwrite Pitch. Floor-to-floor ÷ tan(35°) to floor-to-floor ÷ tan(30°), so 30–35° only. Default 0 | Horizontal run ≈ the entered value + 0.25 in, plus (tread depth − step run) when the tread is deeper than the step run |
| `IsStairsSafetyEgress` | Safety/egress stairs. The step count is rounded up instead, so the step rise is at most 7 in. | Stairs Inputs | Default off |  |
| `ShowPitchforOverwrite`, `NumberOfSteps`, `StepRun`, `StepRise`, `NoseLengthShow` | Read-only results: pitch from the total run (deg), number of steps (rises; there is one tread fewer), step run (in), step rise = floor-to-floor ÷ steps (in), and nose length = tread depth − step run (in). | Stairs Inputs | Read-only. Step Rise shows an error above 7.75 in, asking for the safety option. Nose Length shows an error above 1.25 in or below −0.5 in; the form's note calls −0.25 to +0.75 optimal |  |
| `TypeOfStairsTread` | Tread type. | Stairs Treads Inputs | Serrated Welded Bar Grating, Safety Grating Stair Tread, from the StairTreads group table. No default set |  |
| `FinishOfStairsTread` | Tread finish. | Stairs Treads Inputs | Bar grating: Black, GALV, Bare, or blank (a few odd sizes). Safety grating: GALV. No default set |  |
| `StairTreadDepth` | Tread depth, front to back (in). With the step run it sets the nose length, so it must lie between step run − 0.5 and step run + 1.25 in. | Stairs Treads Inputs | Bar grating: 6.1875, 7.3750, 8.5625, 9.7500, 10.9375, 12.1250 (blank finish: the last three). Safety grating: 10. The form notes a standard of 10.9375. No default set | Adds (tread depth − step run) to the horizontal run when the tread is deeper than the step run |
| `StairTreadWidth` | Tread width (in). | Stairs Treads Inputs | Filtered by type, finish and depth. Mostly 24, 30, 36, 48, 60; a few combinations add 27, 31, 32, 39, 41, 42, 44 or 72. Safety grating: 24, 30, 36. The form notes a standard of 36. No default set | Width. The stringer planes sit at ± half the tread width from the centre line. The cross plate is tread width + 4.5 in |
| `StandartPlatformRailing` | "Does it go with our standard platform railing". Railing height = 43.25 in − top floor thickness − step rise, and both "does not pass" options are forced on. | Railing Inputs | Default off | Railing heights follow the platform railing |
| `RailingHeight` | Railing height along the flight (in): top rail above the tread noses. | Railing Inputs | Hidden with Standard Platform Railing. 0–100 in. Default 0 | Height of the top rail along the stairs |
| `RailingAt1stStep` | Read-only: rail height at the first step = railing height + step rise (in). | Railing Inputs | Read-only. Hidden with Standard Platform Railing |  |
| `RailingDoesNotPass1stStep` | Railing stops at the first step. The bottom rail height is then railing height + step rise. | Railing Inputs | Default off. Hidden, and forced on, with Standard Platform Railing | Sets the rail height at the bottom |
| `RailHeightBottom` | Rail height for the bottom platform (in): top rail above the bottom floor at the first post. | Railing Inputs | Hidden when Railing Does Not Pass 1st Step is on. 30–50 in. Default 0, below the minimum | Rail height at the bottom |
| `RailingDoesNotPassLastStep` | Railing stops at the last step. The top rail height is then the railing height. | Railing Inputs | Default off. Hidden, and forced on, with Standard Platform Railing | Sets the rail height at the top |
| `RailHeightTop` | Rail height for the top platform (in): top rail above the top floor at the last post. The model uses the value − 0.25 in. | Railing Inputs | Hidden when Railing Does Not Pass Last Step is on. 0–100 in. Default 0 | Highest point of the stairs: the top rail stands this high above the top floor |
| `NumberOfStepsBetweenPosts` | Steps between railing posts. Posts = RoundDown(treads ÷ 2) + 1 for 2, or RoundDown((treads + 1) ÷ 3) + 1 for 3. | Railing Inputs | 2–3. Default 3 |  |
| `TubingRailing` | Tubing railing instead of bend plate. | Railing Inputs | Always hidden. Forced off by its variable |  |
| `handrailextension` | "Add handrail extension": adds the extension features and parts to both railings. | Railing Inputs | Default off | Adds the handrail extension. No input sets its size |
| `RailingPostCutThroughDelete` | Removes the cut-through marking from the railing posts. | Railing Inputs | Default off |  |
| `TypeOfFloorTop` | Top floor the stairs land on. Cement gets anchor holes and a 5.75 in top bracket flange (5 in otherwise); plate and grating get bolts. | Connection Types | Cement Floor, Checkered Plate, Grating. No default set | Top connection: the stringer's top floor gap = floor thickness + 0.75 in (cement counts as 1 in) |
| `ThicknessOfTopFloorGrating` | Top floor grating thickness (in). | Connection Types | Shown only for Grating. 1, 1.125, 1.25, 1.5. No default set | Top floor gap, as above |
| `ThicknessOfCheckeredPlate` | Top floor checkered plate thickness (in). | Connection Types | Shown only for Checkered Plate. 0.125, 0.1875, 0.25, 0.375, 0.5. No default set | Top floor gap, as above |
| `TypeOfAnchorTop` | Anchor type at the top. Wedge Anchor adds two wedge anchors; Adhesive Anchor adds no anchor part. | Connection Types | Shown only for Cement Floor. Wedge Anchor, Adhesive Anchor. No default set |  |
| `TypeOfConnectionBottomRigth` | Bottom right connection: anchored to cement, or bolted to a steel platform. Changes the bottom right bracket (5 in wide for cement, 3 in for steel), its holes and its bolts. | Connection Types | Cement Anchor, Steel Platform. No default set |  |
| `TypeOfAnchorBottomRigth` | Anchor type at the bottom right. Not programmed yet: it changes nothing in the model and is only saved with the spec. | Connection Types | Shown only for Cement Anchor. Wedge Anchor, Adhesive Anchor. No default set |  |
| `TypeOfConnectionBottomLeft` | Bottom left connection. Changes the bottom left bracket (5 in or 3 in wide), its holes and its bolts. The bottom wedge anchors follow this side only. | Connection Types | Cement Anchor, Steel Platform. No default set |  |
| `TypeOfAnchorBottomLeft` | Anchor type at the bottom left. Wedge Anchor adds all the bottom wedge anchors; Adhesive Anchor adds none. | Connection Types | Shown only for Cement Anchor. Wedge Anchor, Adhesive Anchor. No default set |  |
| `HighPriority` | High-priority job (raises its queue priority on release). | Details | Default off. Engineering only |  |
| `DevRelease` | Releases the spec as a development test. | Details | Development team only. Default off |  |
| `CheckBox1_OutputDXFFlatState`, `CheckBox1_OutputPDF`, `CheckBox1_OutputStep`, `CheckBox1_Etching` | Output switches: DXF flat patterns, PDF drawings, STEP files of bent parts, part numbers etched on the DXFs. | Extra Stuff | Never shown: the Extra Stuff form sits in no frame. Default off. Output Etching shows only with DXF |  |

Left out on purpose: the section toggles (`…CheckExtend`), the reference-picture toggle `AlternateReferenceCheckExtend`, labels (maximum step rise, nose-length notes, standard tread size), pictures, frames, buttons, and the hidden read-only fields on Extra Stuff (`StairTreadThickness`, `ShowStairTreadConfiguration`, `ShowStairTreadDescription`, `TopGapShow`).

## Notes and open questions

- **Who counts as a Sparta user.** Only two inputs test teams: High Priority (Engineering or Xortion Engineering) and Dev Release (Developement). Every other input is shown to every user. `IsUserInSparta` exists but nothing uses it. Non-Engineering users can't reach Stairs in practice: Sparta's website access lets them open only Kit Conveyor and the platform projects.
- **How Stairs is opened.** On its own. DW Order Project opens only the Kit Conveyor and Platform Layout projects, and no platform project creates a Stairs child spec. Stairs has no child-spec definitions or hosted constants either, so no parent sets any of its inputs. Platform Straight and Platform Picking offer "Stairs (Sitting On Top)" and "Stairs (Attached to Side)" per platform side, but those only change the platform's own railing; nothing is passed to Stairs.
- **Size and position for a layout.** Height = floor-to-floor. Horizontal run = floor-to-floor ÷ tan(pitch) + 0.25 in, or the entered total run + 0.25 in (plus tread depth − step run when the tread is deeper). Width is set by the tread width. Railings are always on both sides, and the top rail stands Rail Height Top above the top floor. The stringers split into 2 pieces when the slope length (floor-to-floor ÷ sin(pitch)) is over 120 in, and 3 pieces over 240 in.
- **Rules between inputs.** Steps = Round(floor-to-floor ÷ 7), or rounded up for safety stairs; step rise over 7.75 in is flagged. The tread depth must keep the nose length between −0.5 and +1.25 in. The Pitch box allows 30–45°, but the Total Run box only allows runs for 30–35°.
- **No default set** for Stringer Assembly Number, Etching Type, the four tread inputs, and every Connection Types input. Floor To Floor Heigth, Pitch and Rail Height Bottom default to 0, below their minimum. Confirm what a new spec starts with.
- **Where specs go.** There is no SQL export. On release every document is released: `NewClientProjects` writes client, project, work order and WO prefix to the ClientProjects group table, `NewColourSpecs` writes the paint and handrail colours to the Colors group table, and two emails go out. The sandbox group holds no specifications.
- **Outputs are unreachable.** The Extra Stuff form is never shown, so Output PDF, DXF, STEP and Etching stay off. The stairs, cut-list and table drawing PDFs are only saved with Output PDF on, yet the "done" email attaches the stairs PDF. Confirm whether Extra Stuff should get a frame.
- **Bottom anchors.** All bottom wedge anchors follow the left side's connection and anchor type. The right side's anchor type is not used, and Adhesive Anchor adds no part anywhere.
- **StairTreads table quirks.** The two "31.5" width treads (`8.5625 x 31.5 Bare`, `9.75 x 31.5`) have TreadWidth 32, so the stairs are built 32 in wide. The safety-grating rows carry trailing spaces in TreadDepth and TreadWidth (`10      `). The tread-type list uses `ListAll`, which returns one entry per table row (105 entries for 2 types); `ListAllDistinct` would return the 2 types.
