# DW Hopper Project: form inputs

*Read from `DriveWorks Files/Hopper/DW Hopper Project.driveprojx` as saved 2026-06-16 08:20. Written 2026-10-02 for Bruno's pre-sales layout app, which should use the same parameters as DriveWorks.*

This table lists every input on the original DW Hopper Project form, the loading hopper that sits on a conveyor: two side walls, with an optional tall drop zone at the back. The layout app can use the same parameter names.

- **DriveWorks Input**: the control name exactly as it appears in DriveWorks.
- **Description**: what the input is for, inferred from its caption, options and rules.
- **Group**: the form page the input sits on.
- **Limitation**: minimum, maximum, option list, or an override limit set by a rule. Empty when there is none.
- **Layout effect**: what the input changes in the hopper's size or position in a layout. Empty when it changes neither.

## Inputs

Rows follow the form from top to bottom. First come the sections the left window stacks: CustomerInfo, HopperSize, HopperOption, then CutOption, which shows only with cutouts and only to Engineering. Then come the never-shown Notes and OutputChecks pages, the two check boxes beside the buttons, and the never-shown ForDevOnly page. A box and the slider that mirrors it share a row, and so do the left and right cutout fields. Units are in the description, and defaults are at the end of the limitation.

| DriveWorks Input | Description | Group | Limitation | Layout effect |
| --- | --- | --- | --- | --- |
| `NewClientProject` | Switches Client and Project to the text boxes. | CustomerInfo | Engineering only. Default off |  |
| `DropDownClient`, `TextBoxClient` | Client: picked from a list, or typed when New Client Project is on. Goes to the drawings' Client property. | CustomerInfo | List: every client in the ClientProjects group table, shown when New Client Project is off. The text box's default is the picked client |  |
| `Project`, `TextBox1_Project` | Project: picked from the client's projects, or typed. Goes to the drawings' Project property. | CustomerInfo | List filtered by the chosen client (ClientProjects) |  |
| `Client`, `ProjectName` | Client and project names from the database, read-only. | CustomerInfo | Never shown: both are always hidden |  |
| `EquipmentName` | "Hopper Name". It becomes the file-name prefix (top level `<prefix>-Hopper`) through the hidden `ConveyorNaming`. Also the export's EquipmentName and the email subject. | CustomerInfo |  |  |
| `PaintColor` | Paint colour, written to the parts' DWcolor property. Its code shows read-only below it (`TextBox_ColorCode`, Engineering only), goes to the Color property, and ends the kit file names (`<prefix>-A33-K1-<code>-YD`). | CustomerInfo | Options from the Colors group table. No default set |  |
| `ConveyorNaming` | Caption "Apron Number**", copied from Apron. Overrides Hopper Name as the file-name prefix. | CustomerInfo | Never shown: always hidden. Default = Hopper Name |  |
| `StickerName` | Sticker name. Not programmed yet: it changes nothing in the model and is only saved with the spec. | CustomerInfo | Never shown: always hidden. Default = file-name prefix |  |
| `SafetyPartsColor`, `SafetyColorCode` | Safety parts colour and its read-only code. Not programmed yet: it changes nothing in the model and is only saved with the spec. | CustomerInfo | Options from the Colors group table. Never shown: both have height 0 |  |
| `E2ProjectNumber` | E2 project number. Work order = E2 number + "-" + work order number. | CustomerInfo | Engineering only. Locked when opened from the Order project (never here) |  |
| `WorkOrderNumber` | Work order number. The work order goes to the drawings' WO property; the export gets the number alone. | CustomerInfo | Engineering only |  |
| `DesignerDrafter` | Designer or drafter. Goes to the drawings' DrawnBy property. | CustomerInfo | Engineering only |  |
| `HopperThickness` | Plate thickness (in) of every hopper part. | HopperSize | 0.125, 0.1875, 0.25. No default set | Wall thickness |
| `HopperWidth` | "Hopper Width (in)": the belt width of the conveyor under the hopper. It also picks the plastic cover. | HopperSize | 24, 36, 48, 60, 72, 84. Hidden with Custom width. No default set | Width. Inside width at the bottom = belt width − 6 in, centred |
| `Costumewidth` | "Custom width": replaces Hopper Width with Custom Hopper Width for the walls, back and chute. | HopperSize | Default off | Width (next row) |
| `CostumeHopperWidth` | Custom inside width (in) between the side walls. The plastic cover is still picked from Hopper Width. | HopperSize | Shown only with Custom width. 0–100. Default 0 | Width: inside width at the bottom = this value |
| `AddDropzone` | "Add Drop zone": a tall loading section with straight walls at the back end, closed by a back wall (A30). | HopperSize | Shown only without Angled Hopper. Default = Angled Hopper, so it is on, and hidden, for angled hoppers | Adds the tall drop zone and the back wall |
| `AngledHopper` | Angled Hopper: the drop zone's lower side panels slope outward, and a transition panel follows the drop zone. Shows the drop-zone width, offset and angle. | HopperSize | Default off | Wider drop zone on the angled sides |
| `Angledside1` | Which drop-zone sides are angled. A rule copies it to the off-screen `Angledside` with left and right swapped, and the model reads that one. | HopperSize | Angled on both sides, Angled left, Angled right. Shown only with Angled Hopper. No default set | Which sides of the drop zone widen |
| `TransitionPanelHeight` | Height (in) of the transition panel between the drop zone and the regular side walls, on each angled side. | HopperSize | Shown only with Angled Hopper. Min = sloped-panel height (see DropZone Angle) + 3.5 in, rounded up to a whole inch. Max 48. Default 24, or sloped-panel height + 3.5 in when that is higher | Wall height just past the drop zone |
| `HopperHeight` | Side-wall height (in) along the conveyor. | HopperSize | 10–48. Default 14 | Height of the side walls |
| `HopperLengthft` + `SLD_HopperLengthft` | "Before elbow Length (ft)": hopper length from the back end to the elbow, or the whole length without Elbow, drop zone included. Box and slider mirror each other. A hidden slider (`SLD_HopperLength`) converts it to inches in the hidden `HopperLength`, which the model reads. | HopperSize | Min = the longer drop-zone length + 12 ft, + 4 ft with Elbow, so 20–28 ft. It counts even without a drop zone. Max 78 ft, 1 ft slider steps. No default set | Length. Model length = ft × 12 in, − 1 in with a drop zone |
| `DropZoneLengthft` + `Slider_HopperHorizontalLengthft` | Drop-zone length (ft) from the back wall. The caption becomes "Left DropZone Length (ft)" with asymmetric. Stored in inches in the hidden `DropZoneLength` (left side, A31). | HopperSize | Shown only with a drop zone. 8–12 ft, 1 ft steps. No default set | Length of the tall loading section. Model length = ft × 12 − 1 in |
| `asym` | "asymmetric": gives the right drop zone its own length. When off, the right side copies the left. | HopperSize | Shown only with a drop zone. Default off | Drop zones of different lengths |
| `DropZoneLengthftL` + `Slider_HopperHorizontalLengthftL` | "Right DropZone Length (ft)". Stored in inches in the hidden `DropZoneLengthl` (right side A32, and the angled back A34). | HopperSize | Shown only with asymmetric. 8–12 ft, 1 ft steps. No default set | Length of the right drop zone. Model length = ft × 12 − 1 in |
| `DropZoneHeight` + `Slider_HopperHorizontalLength3` | Drop-zone height (in), for the sides and the back wall. With Angled Hopper, the part above the sloped panel is split into two rows (2/5 and 3/5 with a single-angle cut). Without it, the part above Hopper Height is split into rows of up to 40 in. | HopperSize | Shown only with a drop zone. 48–90 in, 0.5 in slider steps. No default set | Height of the drop zone |
| `DropZonewidth` + `Slider_HopperHorizontalLength1` | "DropZone width (in)": how far each angled side panel leans out (picture `Angled Hopper3.png`). | HopperSize | Shown only with Angled Hopper. 8–20 in, 0.5 in slider steps. No default set | Width: the drop zone is wider by this much on each angled side |
| `DropZoneoffset` + `Slider_BottomHorizontalLength3` | "DropZone offset (in)": the straight height at the foot of the angled panel before it slopes out. | HopperSize | Shown only with Angled Hopper. 2.5–10 in, 0.5 in slider steps. No default set | Raises the top of the sloped panel |
| `DropZoneAngle1` | "DropZone Angle (deg)": slope of the angled panels from horizontal. The off-screen `DropZoneAngle` = 90 − this value goes to the model. Sloped-panel height = offset + width × tan(angle). Example: 2.5 + 8 × tan 60° = 16.357 in. | HopperSize | Shown only with Angled Hopper. 51–71°. Default 0, below the minimum | Height of the sloped panel |
| `Bidirectional`, `BottomHorizontalLength3`, `Length2`, `TransitionPanelHeight1` | Leftovers: Bidirectional, "Add Bottom Horizontal Section", "Add Top Horizontal Section", and a second transition height. Not programmed yet: they change nothing in the model and are only saved with the spec. | HopperSize | Always hidden |  |
| `addbackangle` | "Add back angle": tilts the back wall. The angled back A34 replaces the flat back A30 (picture `Angledback.PNG`). | HopperOption | Shown only with Angled Hopper on both sides. Default off; forced off otherwise | The back wall leans by Back angle |
| `backangle` | Back angle (deg) from vertical. | HopperOption | Shown beside Add back angle. 20–45, from its tooltip and Min/Max (text-box limits don't seem to be enforced). No default set; the model uses 30 when Add back angle is off | Lean of the back wall |
| `Elbow` | "Add Elbow": the hopper bends to follow a conveyor elbow. | HopperOption | Default off. Adds 4 ft to the Before elbow Length minimum | Profile: one straight run, or two runs with a bend |
| `ElbowAngle` | Elbow Angle (deg): the angle between the runs before and after the elbow, so 180 is straight. The run after the elbow turns down by 180 − this value (picture `Angled Hopper3.png`). | HopperOption | Shown only with Elbow. 30–180. Default 0, below the minimum | Angle of the run after the elbow |
| `HopperInclineLengthft` + `SLD_HopperLength1ft` | "After elbow Length (ft)". Box and slider mirror each other. Stored in inches in the hidden `HopperInclineLength`. | HopperOption | Shown only with Elbow. 8–75 ft, 1 ft slider steps. No default set | Length after the bend. Model length = ft × 12 in |
| `Cutouts` | "Add rectangular Cutouts": cuts an opening in the drop-zone side walls (picture `CUT1.png`). Shows the CutOption section. | HopperOption | Shown only with a drop zone. Locked while single-angle cutouts are on. Default off; forced off without a drop zone | An opening in one or both drop-zone sides |
| `SingleCutouts` | "Add single angle Cutouts(deg)": the top of the drop zone slopes down from the back wall toward the head (picture `single angle.png`). | HopperOption | Shown only with Angled Hopper. Locked while rectangular cutouts are on. Default off; forced off without Angled Hopper | The drop-zone top gets lower toward the head |
| `singlanglecut` | Slope (deg) of the single-angle cut. | HopperOption | Shown with Angled Hopper; used only when Single angle Cutouts is on. Min 0.5. Max (in the tooltip) = ATan((top row height − 3 in) / (longer drop-zone length − 1 in)); the top row is 3/5 of the drop-zone height above the sloped panel. Default 10 | Slope of the drop-zone top |
| `AddDeflector` | "Add Deflector". The model has deflector features, but this box is always off. | HopperOption | Never shown (height 0). Always off |  |
| `Addchute` | "Add chute": adds the chute assembly A33. Its plates are sized from the width and Hopper Height. | HopperOption | Default off | Adds the chute. No rule sets its length |
| `AddPlasticCover` | "Add Plastic Cover", with the chute. The cover is picked by belt width (36, 48, 60 or 72; the 48 cover for 24 and 84). Also turns on the PlasticCover features of the wall panels. | HopperOption | Shown only with Add chute. Default off; forced off without the chute |  |
| `CutSide1` | Which drop-zone side gets the opening. A rule copies it to the off-screen `CutSide` with left and right swapped. | CutOption | Engineering only. None without cutouts. With cutouts: Left only or Right only when only that side is angled, otherwise Both Side, Left, Right. Default None, which isn't in that list, so it falls back to the first item | Which side has the opening |
| `c1`, `c1l` | Point c, where the opening starts: distance (in) from the back end. `c1` is the left side (A31), `c1l` the right (A32). | CutOption | Shown for that side. Min 5. Max = the rear drop-zone panel length − 2 in (− 5 in near it); that panel is at most 47 in. Default 0, below the minimum | Where the opening starts, from the back |
| `b1`, `b1l` | Point b, where the opening ends: distance (in) from the back end. | CutOption | Min 52 in for an 8 ft drop zone; for longer ones, rear + middle panel lengths + 20 in. Max = that side's drop-zone length − 1 in. Default 0, below the minimum | Where the opening ends |
| `b2`, `b2l` | Height (in) of point b above the bottom of the wall. | CutOption | Min = sloped-panel height + 5 in (Hopper Height + 5 in without Angled Hopper). Max = c2. Default 0, below the minimum. A warning asks to change b2 or c2 when they are equal and leave a stiffener under 2 in | Height of the opening's lower edge at b |
| `c2`, `c2l` | Height (in) of point c above the bottom of the wall. | CutOption | Min = b2. Max = DropZone Height − 5 in. Default 0, below the minimum | Height of the opening's lower edge at c |
| `Pullcord` | E-stop pullcord, copied from Kit Conveyor. Not programmed yet: it changes nothing in the model and is only saved with the spec. | CutOption | Always hidden. Default off |  |
| `ExtraNotes` | Notes. Sent to the export's ExtraNotes column ("-" when empty). | Notes | Never shown: the Notes frame is off |  |
| `CheckBox1_QTSideBeltSupport`, `CheckBox1_OutputDXFFlatState`, `CheckBox1_OutputPDF`, `CheckBox1_Etching` | Output switches copied from Kit Conveyor. Not programmed yet: nothing reads them. | OutputChecks | Never shown: the frame's height is 0. Default off |  |
| `HighPriority` | High-priority job: priority tag 9 instead of 109. | Details | Default off |  |
| `DevRelease` | Releases the spec as a development test (priority tag 99). | Details | Development team only. Default off |  |
| `InputClientNumber`, `InputProjectNumber`, `InputEquipmentNumber`, `Revision` | Keys of the export row. They also feed the database lookups for the client and project names. | ForDevOnly | Never shown: the ForDevOnly frame is off. Default 0 (Revision's minimum is 1) |  |
| `Mode`, `Trajectory`, `TrajectoryHeight` | Add/Edit mode and the material trajectory, copied from Kit Conveyor. Not programmed yet: nothing reads them. | ForDevOnly | Never shown. Mode default Add; height 16–100 in, default 16 |  |

Left out on purpose: labels, pictures, frames, the section toggles (`…CheckExtend`, `HopperOptions2`), the "i" help toggle `iconveyorlength`, the cutout warning link `Errormsgr`, the hidden 3D preview, and buttons (Save & Close, Cancel & Close, Generate CAD, SaveInSpec, and ForDevOnly's Export Data Base, Load Data and Release). The off-screen helpers that rules fill (`HopperLength`, `DropZoneLength`, `DropZoneLengthl`, `HopperInclineLength`, their sliders, `Angledside`, `CutSide`, `DropZoneAngle`) are named in the rows above. The form pictures are in `DriveWorks Files/Hopper/Form Design Documents/` (`Angled Hopper*.png`, `Hopper Height.png`, `Custom Width.png`, `CUT1.png`, `CUT2.png`, `single angle.png`, `Angledback*.PNG`).

## Size and position in a layout

- **Units:** inches in the model; the lengths are typed in feet.
- **What it mounts on:** a conveyor. No input names the conveyor type. The inside width (belt − 6 in) matches V2's Kit Conveyor rule, and the plastic cover configurations are named by belt width ("Plastic Cover (BW 48)"). There are no legs or supports, no hosted child and no DW Start Leg.
- **Position on the conveyor:** no input places the hopper. The layout has to place it on the conveyor itself, with the drop zone at the back end.
- **Incline:** no input sets an incline or a height above the floor, so in a layout the hopper follows its conveyor. Only the elbow bends it.
- **Length along the conveyor:** Before elbow Length × 12 in (− 1 in with a drop zone), plus After elbow Length × 12 in with an elbow. The run after the elbow turns down by 180 − Elbow Angle. The drop zone is the first Drop Zone Length × 12 − 1 in from the back wall; left and right can differ with asymmetric. With Add back angle the back wall leans by Back angle from vertical, and no rule gives the extra length.
- **Inside width:** at the bottom, belt width − 6 in (or Custom Hopper Width), centred. On an angled side the drop-zone wall rises straight for DropZone offset, then slopes out by DropZone width. Its sloped panel tops out at offset + width × tan(DropZone Angle), so above that the drop zone is wider by DropZone width per angled side. No variable computes the outside width. The back wall's bottom panel is set to belt + 15 in (Custom Hopper Width + 21 in), plus DropZone width − 8 in per angled side.
- **Heights (above the bottom of the walls):** side walls Hopper Height (10–48 in). Drop-zone sides and back wall DropZone Height (48–90 in). With Angled Hopper, a transition panel at Transition Panel Height on each angled side, just past the drop zone. A single-angle cut lowers the drop-zone top toward the head.
- **Inlet:** the open top of the drop zone, Drop Zone Length long, closed at the back by the back wall (A30, or the angled A34). Without a drop zone there is no back wall, and the hopper is two side walls Hopper Height tall. A rectangular cutout opens part of a drop-zone side, from c1 to b1 measured from the back end. Its lower edge runs from c2 high at c to b2 high at b, and it is open to the top of the wall (picture `CUT1.png`).
- **Outlet:** the hopper is open at the bottom onto the belt, and the back wall is its only end wall. Add chute adds the chute A33. Its widest plates are belt width + 11.99 in. The top level places it with one set of mates without the elbow (`chute`) and another with it (`chuteelbow`). No rule sets the chute's length, and no discharge height is computed.

## Notes and open questions

- **Who counts as a Sparta user.** The form tests `IsUserInEngineering` (Engineering or Xortion Engineering) for the section toggles, the work-order fields, the colour code, New Client Project and the CutOption section. It tests `IsUserInDevelopement` for Dev Release and SaveInSpec. `IsUserInSparta` exists, but nothing uses it. Other users get every section expanded and no CutOption section. In practice the hoppers are Engineering-only, since other users reach only Kit Conveyor and the platform projects.
- **How it is opened.** On its own. The constant `OpennedFromOrderProject` is False. DW Order Project opens equipment by the name it reads from the SQL table DWProjectList, and neither it nor DW Select Project names any hopper. This project hosts no child.
- **Compared with DW Hopper V2** ([hopper-v2-inputs.md](hopper-v2-inputs.md)):
  - **Status.** V2 is the current one. In the sandbox group this project is hidden and `Deployed=False`, while V2 is visible. This project was last saved 2026-06-16, V2 on 2026-09-09.
  - **Separate designs.** This project uses DW09 models in `Models`; V2 uses DW09B models in `Models V2`. Neither names the other.
  - **What V2 added:** a conveyor type (Kit, Light Duty, Picking, Other), drop-zone inputs per side, a forward or backward back angle, a double transition, and bolted panel kits from the hosted DW Hopper V2 - Panels.
  - **What only this project does:** rectangular side cutouts, a working chute and plastic cover (V2's Chute and Covers do nothing yet), and Custom width.
  - **Elbow Angle differs.** Here it is the angle between the runs (180 = straight); in V2 it is the bend itself.
  - **Still used?** The files can't tell whether production still uses this project.
- **The model reads hidden helpers.** Rules fill hidden or off-screen controls from the visible ones, and the model reads only the helpers. `HopperLength`, `DropZoneLength`, `DropZoneLengthl` and `HopperInclineLength` get ft × 12. `DropZoneAngle` gets 90 − the typed angle. `Angledside` and `CutSide` get the typed side with left and right swapped. So the form's Left is A31 and its Right is A32, while the hidden controls and the rules use the opposite words. The cutout warning (`Errormsgr`) uses the rules' words, so it says "right side" for the fields labelled Left side.
- **No default is set** for Hopper Thickness, Hopper Width, Angled side, Paint Color, Client, Project and Back angle. The box/slider pairs default to each other, so Before elbow Length, After elbow Length, the drop-zone lengths, DropZone Height, width and offset have no fixed default. **Defaults below the minimum:**
  - Elbow Angle (0, min 30);
  - DropZone Angle (0, min 51);
  - the cutout dimensions (0, min 5 or more);
  - Revision (0, min 1);
  - Transition Panel Height, whose computed default can fall just under its whole-inch minimum.
- **Limits that don't fit together.** Sparta engineering should confirm the real ones.
  - Before elbow Length allows 78 ft, but the hidden `HopperLength` and `SLD_HopperLength` stop at 900 in (75 ft).
  - The sloped panel can reach 10 + 20 × tan 71° = 68.1 in. Its transition minimum (72 in) then passes the 48 in maximum, and the panel is taller than the 48 in DropZone Height minimum. Nothing checks the angled-panel inputs against either limit.
- **One angled side.** With only one side angled, the back wall A30 is deleted (its file-name rule), and no rule adds another back. Confirm what closes the back in that case.
- **Plastic cover sizes.** There are covers for belt widths 36, 48, 60 and 72 only; 24 and 84 get the 48 cover, and part `DW09-1LP` falls back to 36. Confirm that this is intended.
- **Pages that are never shown.** The Notes, MaterialInfo and ForDevOnly frames are off, and the OutputChecks frame has height 0. So Extra Notes stays empty, and the export keys (client, project and equipment numbers, revision) stay at 0 unless something outside the form sets them. Export Data Base and Load Data call macros `ExportToDB` and `ImportFromDB`, which this project doesn't have.
- **Exports.** Release sends:
  - the SQL export `EquipmentListExport`, one row in EquipmentListData;
  - an email to the user with `<prefix>-Hopper.pdf`;
  - a tracking email to an admin address.

  The export row holds the keys, EquipmentName, WorkOrderNumber, Revision, ExtraNotes and a Notes text. There is no hopper table, so the geometry is kept only in the spec. Files go to `\\192.168.0.19\Driveworks Output Files\<prefix>-Hopper Project <spec id as 0000>`.
- **Leftovers from Kit Conveyor and Apron.**
  - The export's Notes text keeps the conveyor labels. Its "Incline Length" is Hopper Length in inches labelled ft. Its "Incline Angle" is the internal DropZone Angle. Its "Horizontal Length" (angled hoppers) works out to the drop-zone length in inches + 1.
  - The EquipmentType column is looked up with `DWProjectNumber` 2, the same number as Kit Conveyor, Apron and Light Duty Conveyor, so it probably doesn't say Hopper.
  - The ForDevOnly lookups read the Kit Conveyor table DWKitConveyorData.
  - A variable named `Elbow` holds Angled Hopper.
- **Inputs with no effect:** Sticker Name, Safety Parts Color, Pullcord, Bidirectional, the two horizontal-section boxes, the second transition height, Add Deflector (always off), the four output switches, Mode and Trajectory.
