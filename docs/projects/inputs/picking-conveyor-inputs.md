# DW Picking Conveyor Project: form inputs

*Read from `DriveWorks Files/Picking Conveyor/DW Picking Conveyor Project.driveprojx` as saved 2026-03-11 11:45. Written 2026-10-01 for Bruno's pre-sales layout app, which should use the same parameters as DriveWorks.*

This table lists every input on the Picking Conveyor DriveWorks form, so the layout app can use the same parameter names.

- **DriveWorks Input**: the control name exactly as it appears in DriveWorks.
- **Description**: what the input is for, inferred from its caption, options and rules.
- **Group**: the form page the input sits on.
- **Limitation**: minimum, maximum, option list, or an override limit set by a rule. Empty when there is none.
- **Layout effect**: what the input changes in the conveyor's size or position in a layout. Empty when it changes neither.

## Inputs

Rows follow the form from top to bottom. After them come the Extra Stuff and obsolete forms, which no frame shows. Units are in the description, and defaults are at the end of the limitation.

| DriveWorks Input | Description | Group | Limitation | Layout effect |
| --- | --- | --- | --- | --- |
| `CheckBox1_NewClientProject` | Switches Client and Project to free text. | Customer Info | Default off |  |
| `ComboBox1_Client`, `TextBox1_Client` | Client: picked from a list, or typed when New Client Project is on. Only the typed value reaches the drawings and the ClientProjects export. The list pick is used for nothing but filtering the project list. | Customer Info | List from the ClientProjects group table, hidden when New Client Project is on |  |
| `ComboBox1_Project`, `TextBox1_Project` | Project: picked from the client's projects, or typed. Only the typed value is used, as for Client. | Customer Info | List filtered by the chosen client |  |
| `TXTBox_ConveyorNaming` | "Conveyor Name": the file-name prefix. The main assembly is `00-<prefix>-Picking Conveyor` and the spec is `<prefix>-Picking Conveyor Project <id>`. | Customer Info | Default SP01 |  |
| `TXTBox_ConveyorStickerName` | Conveyor sticker name, a read-only copy of the prefix. Nothing uses it. | Customer Info | Always hidden (zero height) |  |
| `TextBox1_WorkOrder` | Work order (drawings' work-order property). | Customer Info |  |  |
| `TextBox1_DesignerDrafter` | Designer or drafter. | Customer Info |  |  |
| `ComboBox_Colors` | Main paint colour. | Customer Info | Options from the Colors group table. Default Sparta Blue |  |
| `TextBox_ColorCode` | Colour code, used in the part and kit file names. It can be edited here. | Customer Info | Default looked up from the Colors group table for the paint colour |  |
| `SafetyPartsColor` | Paint colour for safety parts. Code in `SafetyColorCode` (read-only). | Customer Info | Options from the Colors group table. No default set |  |
| `CBX_ConveyorWidth` | Belt width (in). Above 48 in it shows Tail Pulley Type. | Conveyor Specs | 24, 30, 36, 42, 48, 60, 72, 84. Default 48 | Width. The side plates sit on planes belt width + 5.75 in apart |
| `NumericTextBox1_ConveyorTailHeight` | "Conveyor Tail Height" (in): floor to the bottom of the frame at the tail (help picture). | Conveyor Specs | 0–200. Default 36 | Infeed height. Raises or lowers the whole conveyor |
| `NTB_ConveyorLength` + `SLD_ConveyorLength` | Conveyor length (ft). Box and slider mirror each other. Without Elbow it is the overall length: model length = ft × 12 in. With Elbow it is the incline run, from the tail end to the elbow (help picture). | Conveyor Specs | Slider 12–130 ft, or 16–90 ft with Elbow, 1 ft steps (the box alone allows 0–130). No default set: box and slider default to each other | Length. On an incline it also sets how high the level run sits |
| `CheckBox_AntinipGuards` | Anti-nip guards on the incline tail, incline mid sections and elbow. | Conveyor Specs | Shown only with Elbow. Default off |  |
| `ComboBox1_IdlerType` | Return idler roll material. | Conveyor Specs | Rubber, Steel. Always hidden (zero height), so it stays at the default, Rubber |  |
| `ConveyorHeight` | "Conveyor Height" (in): frame depth, the height of the side walls from bottom to top (help picture). The upper side plates are 19 in (+1 in with a 14 or 16 in head pulley, +5 in with 20 in) and the lower plates make up the rest. | Conveyor Specs | 26–42 in, 1 in steps. The minimum is 30 with a 20 in head pulley. The tooltip says Max 46. Default 10, below the minimum | Frame depth. Top of the frame = Tail Height + Conveyor Height on a level run |
| `HopperHoles` | "Add Hopper Holes": mounting holes for a hopper in the side-plate kits. | Conveyor Specs | Default off |  |
| `CheckBox_Elbow` | Adds an elbow. The conveyor inclines from the tail, then runs level to the head. | Conveyor Specs | Default off | Profile: one level run, or an incline plus a level run to the head |
| `Slider_ConveyorHorizontalLength` | Length of the level run after the elbow (ft). The caption shows the value. | Conveyor Specs | Shown only with Elbow. 10–110 ft, 1 ft steps. Default 7, below the minimum | Length of the level run, so where the head ends |
| `SpinButton_ConveyorAngle` | Incline angle from the tail to the elbow (deg). Caption "Min=10". | Conveyor Specs | Shown only with Elbow, and 0 without it. 10–45°, 0.5° steps. Default 10 | Incline. Sets the height of the level run and the horizontal footprint of the incline |
| `ComboBox_TailPulleyDiameter` | Tail pulley diameter (in). | Conveyor Options | 12, 14. Default 12 | The tail shaft height shifts slightly (dimension 7.5 or 8 in, or 8.375 or 9.25 in with Elbow) |
| `ComboBox_TailShaftDiameter` | Tail shaft diameter (in). | Conveyor Options | 2.4375, 2.9375, 3.4375. Default 2.4375 |  |
| `DrumPulleycb` | "Tail Pulley Type". It sets the hidden `DrumPulley` check box, which picks the tail pulley part. | Conveyor Options | Drum Pulley, Wing Pulley. Shown only above 48 in belts. Default Drum Pulley. Up to 48 in the list shows Drum Pulley but a wing pulley is built |  |
| `ComboBox_HeadPulleyDiameter1` | Head pulley diameter (in). With the gearbox RPM it sets the belt speed. | Conveyor Options | 12, 14, 16, 20. Default 12. 20 in raises the Conveyor Height minimum to 30 in | The head shaft centre-height dimension is 7.8125, 8, 9.75 or 11.5 in (8 and 8.75 in for 12 and 14 with Elbow), so the discharge point shifts slightly |
| `ComboBox_HeadShaftDiameter1` | Head shaft diameter (in). | Conveyor Options | 2.4375, 2.9375, 3.4375, plus 3.9375 above a 12 in head pulley. Default 2.4375. It limits the gearbox list |  |
| `ComboBox1_HeadPulleyType` | Head pulley lagging. | Conveyor Options | Blank, LAGGING, "LAGGING, Stainless Steel", "LAGGING, Magnetic". Default LAGGING |  |
| `Heavyduty` | "Heavy duty impact bed" parts (impact-bed crosses and their holes). | Conveyor Options | Always hidden (zero height). Its default rule reads a `SliderBed` variable that doesn't exist, so it most likely stays off |  |
| `Emergency_equipment` | "Add Pull cord Assembly": e-stop pull cord along the level run. | Conveyor Options | Locked off while the first level mid section is 36 in or shorter: Conveyor Length 13 ft or less, or Horizontal Length 10 ft with Elbow. Default off |  |
| `DoubleSwitch` | "Double Switch": adds a second set of pull-cord switch parts. | Conveyor Options | Shown only with the pull cord. Default off |  |
| `PullCordSide` | Side of the pull cord. | Conveyor Options | Left, Right, Both sides. Shown only with the pull cord. No default set |  |
| `PullcordSwitch` | "Pull cord Switch": the section that holds the e-stop switch. | Conveyor Options | Shown only with the pull cord. Options are the level-run mid sections (A02 onward, or A11 onward with Elbow), one per section. No default set |  |
| `Pullcord` | "Pull cord up to": the section where the cord ends at its eyelet. | Conveyor Options | Shown only with the pull cord. The same section list. No default set |  |
| `SBcut` | "Add Slider Bed cut": a cut-out in the level-run slider beds. | Conveyor Options | Default off |  |
| `AddSliderbedheight` + `Sliderbedheight` | Slider bed height (in): distance from the slider bed up to the top of the side walls (help picture). Without it the model uses 1.5 in. A larger value makes the upper side plates taller by the difference, and the lower plates shorter. | Conveyor Options | Spin shown only when the box is on. 1.5–3 in, 0.025 in steps. With Elbow the minimum is 1–2 in, from the angle, or 1.5 in with a 20 in head pulley. The tooltip says Max 4. Default off, value 0 | The belt (picking) surface sits deeper in the frame, which keeps its depth |
| `CheckBox_HeadScraper`, `CheckBox1_HDTakeupRod` | Head scraper (belt cleaner), and the heavy-duty take-up rod. | Conveyor Options | Placed outside the 400 px section frame, so nobody can reach them. They keep their defaults: head scraper on, HD take-up rod off |  |
| `CheckBox_PullCord`, `CheckBox1_ImpactBed` | "Pull Cord" and "Horiz. Section Impact Bed". Not programmed yet: they change nothing in the model and are only saved with the spec. | Conveyor Options | Outside the section frame, unreachable. Defaults on and off |  |
| `ComboBox1_MotorSide` | Side the drive is mounted on. | Motor Options | Left, Right, None. Default Left | Side the drive sticks out on, at the head. None = no drive |
| `ComboBox_Brake` | Motor brake. It adds "BRE" to the gearmotor model configuration. | Motor Options | Yes, No. No default set |  |
| `ComboBox1_MotorBrand` | Motor brand. | Motor Options | NordGear, Others. No default set | NordGear places the gearmotor model. Others, or blank, leaves it out |
| `ComboBox_NemaAdapter` | NEMA motor adapter. It adds "NEMA" to the gearmotor model configuration. | Motor Options | Yes, No. No default set |  |
| `ComboBox_VFD` | Variable frequency drive (only in the BOM description). | Motor Options | Yes, No. No default set |  |
| `ComboBox_GearboxType` | Nord Helical Bevel gearbox size. It sizes the torque arm and the head shaft end. | Motor Options | From the project's HelicalBevelNordGearbox1 table: 9012, 9016, 9022, 9032, 9042 with a 2.4375 in head shaft; plus 9052 with 2.9375 in; plus 9072 with larger shafts. 9082 is never offered. No default set | Drive size, and how far it sticks out |
| `ComboBox_GearboxVoltage` | Motor voltage (BOM description only). | Motor Options | 460V, 575V. No default set |  |
| `ComboBox_Horsepower` | Motor power (hp). With the gearbox size it picks the gearmotor model configuration. | Motor Options | The powers listed for that gearbox in the table (2, 3, 5, 7.5, 10, 15). No default set | Drive size |
| `ComboBox_GearboxRPM` | Gearbox output speed (RPM). | Motor Options | The speeds listed for that gearbox and power (e.g. 9032 at 5 hp: 69, 48, 45, 43, 36, 35). No default set |  |
| `NumericTextBox1_BeltSpeedFPM` | Read-only belt speed (ft/min) = RoundUp(RPM × (head pulley diameter + 0.75 in) × π / 12). | Motor Options | Read-only |  |
| `HeadOnly`, `TailOnly`, `ElbowOnly` | Release only the head (A29), tail (A01 with Elbow, A11 without) or elbow (A20) model. | Settings | Default off. Each locks the others, and No Head, No Tail and No Elbow lock them too. Elbow Only isn't locked when there is no elbow | Only that section is built |
| `NoHead`, `NoTail`, `NoElbow` | Leave out the head, tail or elbow section. | Settings | Default off. Locked while Head, Tail or Elbow Only is on. No Elbow is enabled only with Elbow | Removes that section, so the conveyor is shorter |
| `HighPriority` | High-priority job (raises its queue priority on release). | Settings | Default off |  |
| `DevRelease` | Releases the spec as a development test. | Details | Development team only. Default off |  |
| `CheckBox1_OutputDXFFlatState`, `CheckBox1_OutputPDF`, `CheckBox1_Etching` | Output switches: DXF flat patterns, PDFs, etched part numbers on the drawings. | Extra Stuff | Never shown: the Extra Stuff form is in no frame. Default off, so those outputs are skipped |  |
| `ComboBox_GearboxType1`, `ComboBox_GearboxRPM1` | Old Clincher gearbox lists. Nothing reads them. | obsolete | Never shown |  |

Left out on purpose: the section toggles (`…CheckExtend`), the "i" help-picture toggle (`iconveyorlength`), labels, pictures, the frames, the hidden `DrumPulley` check box (covered under `DrumPulleycb`), and buttons.

## Notes and open questions

- **Who sees what.** The form tests the Engineering or Xortion Engineering team (`IsUserInEngineering`).
  - Engineering users get collapsible sections, one open at a time.
  - Other users see Customer Info as a bare header (labelled "Conveyor Options") and every other section open, Settings included.
  - `IsUserInSparta` exists but nothing uses it. Dev Release shows only to the Developement team.
  - In practice the project is Engineering-only: non-Engineering users reach only Kit Conveyor and the platform projects through Sparta's website access.
- **Legs: none.** The project has no `SpecificationHostControl`, no `LegList` or `LegListInput` table, no leg models, and no reference to DW Start Leg. Nothing reaches the floor in the model: the conveyor is placed at Tail Height above the floor and stands on whatever supports it.
- **Size and position for a layout:**
  - **Length.** Without Elbow, overall length = Conveyor Length × 12 in. That is a 72 in tail section (A11), 120 in mid sections A12-1 to -12 with the last one shorter, and a 48 in head section (A29).
  - **Length with Elbow.** The incline run (Conveyor Length) is a 120 in tail section (A01), incline mid sections A02-1 to -8, and 36 in for the elbow. The level run (Horizontal Length) is 36 in for the elbow, mid sections, and the 48 in head.
  - **Width.** The side plates sit on planes belt width + 5.75 in apart, and the tail guard's rear panel is belt width + 5.75 in wide. The drive sticks out on the Motor Side at the head. Its size comes from the gearmotor configuration (`<hp> HP SK<size>` plus NEMA and BRE) and the torque arm.
  - **Height.** The frame bottom at the tail is at Tail Height, and the frame is Conveyor Height deep. Without Elbow the whole conveyor is level. With Elbow it rises at the Conveyor Angle up to the elbow, then runs level to the head (the belt bends by the full angle).
  - **Infeed and discharge.** The tail end is the infeed and the head end the discharge, at the same height on a level conveyor. With Elbow the head end is on the raised level run.
  - **Picking stations.** There are no picking-station or opening inputs. The only openings are Hopper Holes (hopper mounting holes) and the slider-bed cut.
  - **Block model.** Every full release also builds a one-part block, `<prefix>-Block Picking Conveyor`. Its dimensions are incline length, horizontal length, angle, width, pulley sizes, the side-plate heights, and a left or right motor. It is the closest thing to a layout envelope that DriveWorks makes.
- **Relationship to the Kit Conveyor.** A separate, older design: its own DW02 models (the Kit is DW01) and different control names.
  - **Its form was copied from an earlier Kit form.** The stacked-frame layout and team variables are the same, the header label is still named `KitConveyorConfigurator`, and there are leftovers: a `ClientTeamName` database query on an `InputClientNumber` control that doesn't exist here, and Clincher lists on the obsolete form.
  - **Main differences from the Kit:**
    - Belt widths 24–84 in (no 18).
    - 12–130 ft long (Kit 9–79 ft).
    - Level unless Elbow. The elbow always turns to a level run, so there is no Elbow Angle, and the incline is 10–45°.
    - The frame depth is an input (26–42 in); the Kit's side walls are fixed. The tail height is always taken at the frame bottom (no Height Reference).
    - Pulleys 12–14 in (tail) and 12–20 in (head); head shaft up to 3.9375 in.
    - Nord Helical Bevel gearboxes only, picked by hand. No belt-speed target: belt speed is a read-only result.
    - A pull-cord e-stop with switch and eyelet positions per section, hopper holes, a slider-bed cut and a slider-bed height.
    - No legs, material info, notes, impact-bed page or bidirectional option.
    - No SQL export, Load Data, costing sheet or Order-project link.
- **Other projects.**
  - Neither DW Platform - Picking nor any other platform project names this project, and this project names none of them. No values pass either way.
  - The DW Order Project never opens it. It opens only `DW Kit Conveyor Project`.
  - In the sandbox group the project is registered as not hidden and not deployed.
- **Where specs go.** There is no SQL export, so a spec is saved only in DriveWorks. When a spec completes, all documents are released: two emails, and `NewClientProject`, which writes the typed Client and Project to the ClientProjects group table.
- **No default is set** for Safety Parts Color, the three pull-cord lists, Motor Brand, Brake, NEMA Adapter, VFD, Gearbox Type, Gearbox Voltage, Horsepower or Gearbox RPM. Three defaults sit below their minimum: Conveyor Height 10 (minimum 26), Horizontal Length 7 (minimum 10), and Slider bed height 0. Confirm what a new spec starts with.
- **Looks wrong, for Sparta engineering to confirm:**
  - **Tail pulley type.** For belts up to 48 in the hidden `DrumPulley` flag is forced off, so a wing pulley is built while the hidden list says Drum Pulley.
  - **Unreachable controls.** Head Scraper, HD Takeup Rod, Pull Cord and Horiz. Section Impact Bed sit at x = 424–583 in a 400 px frame with no scroll bar. So the head scraper is always built and the HD take-up rod never is.
  - **Missing PDF.** The Extra Stuff output switches are never shown and default off, so no PDFs or DXF flat patterns are made. Yet the "done" email attaches `00-<prefix>-Picking Conveyor.pdf`.
  - **Heavy-duty impact bed.** `Heavyduty` is zero height, its Visible rule reads a control `ImpactBed` that doesn't exist, and its default reads a variable `SliderBed` that doesn't exist.
  - **Tooltips disagree with limits.** Conveyor Height says Max 46 (real maximum 42), and Slider bed height says Max 4 (real maximum 3).
  - **Head Pulley Type default.** It is stored as the static text `="LAGGING"`, not as a rule. Check in Administrator that LAGGING really is preselected.
