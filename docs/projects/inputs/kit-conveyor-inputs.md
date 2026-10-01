# DW Kit Conveyor Project: form inputs

*Read from `DriveWorks Files/Kit Conveyor/DW Kit Conveyor Project.driveprojx` as saved 2026-09-23 09:32. Written 2026-09-29 for Bruno's pre-sales layout app, which should use the same parameters as DriveWorks. There is a shared copy at https://claude.ai/code/artifact/b7e4a112-0f5c-4575-ba42-379033e2a308. It is private to the owner until shared. Updated 2026-10-01: leg width and stub leg style corrected, and the legs linked to DW Start Leg.*

This table lists every input on the Kit Conveyor DriveWorks form, so the layout app can use the same parameter names.

- **DriveWorks Input**: the control name exactly as it appears in DriveWorks.
- **Description**: what the input is for, inferred from its caption, options and rules.
- **Group**: the form page the input sits on.
- **Limitation**: minimum, maximum, option list, or an override limit set by a rule. Empty when there is none.
- **Layout effect**: what the input changes in the conveyor's size or position in a layout. Empty when it changes neither.

## Inputs

Rows follow the form from top to bottom. The five legs A40–A44 share one row per field, written with A4n. Units are in the description, and defaults are at the end of the limitation.

| DriveWorks Input | Description | Group | Limitation | Layout effect |
| --- | --- | --- | --- | --- |
| `EquipmentName` | Equipment name. It becomes the file-name prefix when Conveyor Number is empty. | CustomerInfo |  |  |
| `PaintColor` | Main paint colour. The colour code shows read-only below it (`TextBox_ColorCode`, Engineering only). | CustomerInfo | Options from the Colors group table |  |
| `SafetyPartsColor` | Paint colour for safety parts. Code in `SafetyColorCode` (read-only, Engineering only). | CustomerInfo | Options from the Colors group table |  |
| `CheckBox_CustomNameToggle` | "Main ASM = Equipment Name": names the main assembly after Equipment Name. | CustomerInfo | Default off |  |
| `Client`, `ProjectName` | Client and project names, read-only. | CustomerInfo | Shown only when opened from the Order project |  |
| `ConveyorNaming` | Conveyor number. Overrides Equipment Name as the file-name prefix. | CustomerInfo | Default looked up from the ClientProjects group table |  |
| `StickerName` | Text on the conveyor sticker. | CustomerInfo | Default = file-name prefix |  |
| `E2ProjectNumber` | E2 project number. Work order = E2 number + "-" + work order number. | CustomerInfo | Locked when opened from the Order project |  |
| `WorkOrderNumber` | Work order number. | CustomerInfo |  |  |
| `DesignerDrafter` | Designer or drafter name. | CustomerInfo |  |  |
| `TextBox_Description` | Equipment description. | CustomerInfo |  |  |
| `DropDownClient`, `TextBoxClient` | Client: picked from a list, or typed when New Client Project is on. | CustomerInfo | List from the ClientProjects group table. Hidden when opened from Order |  |
| `Project`, `TextBox1_Project` | Project: picked from the client's projects, or typed. | CustomerInfo | List filtered by the chosen client |  |
| `NewClientProject` | Switches Client and Project to free text. | CustomerInfo | Default off |  |
| `MaterialType` | Material conveyed. Not programmed yet: it changes nothing in the model and is only saved with the spec. | MaterialInfo | Construction and Demolition Recycling, Single Stream Recycling, Organics, Other |  |
| `OtherTypeMaterial` | Material name when Material Type is Other. Not programmed yet: it changes nothing in the model and is only saved with the spec. | MaterialInfo | Shown only for Other |  |
| `MaterialSizeMinimum` | Smallest piece size. Not programmed yet: it changes nothing in the model and is only saved with the spec. | MaterialInfo | 0in, 2in, 5in, 8in+ |  |
| `MaterialSizeMaximum` | Largest piece size. Not programmed yet: it changes nothing in the model and is only saved with the spec. | MaterialInfo | After 0in: Under 2in, 8in, 24in, 24in+. After 2in or 5in: 8in, 24in, 24in+. After 8in+: 24in, 24in+ |  |
| `FlowTPH` | Flow rate (tons per hour). Not programmed yet: it changes nothing in the model and is only saved with the spec. | MaterialInfo | 0–500. Default 25 |  |
| `MaterialDensity` | Material density (lb/ft³). Not programmed yet: it changes nothing in the model and is only saved with the spec. | MaterialInfo | 0–500. Default 20 |  |
| `ConveyorWidth` | Belt width (in). | ConveyorSize | 18, 24, 30, 36, 42, 48, 60, 72, 84. No default set | Width. Outside of the side walls = belt width + 6.135 in. The legs are belt width + 12.52 in wide (see [DW Start Leg](start-leg-inputs.md)) |
| `Elbow` | Adds an elbow: the conveyor inclines from the tail, then bends to a flatter run up to the head. | ConveyorSize | Default off | Profile: one straight run, or an incline plus a flatter run to the head |
| `ConveyorLength` + `SLD_ConveyorLength` | Length (ft). Box and slider mirror each other. With Elbow it is the incline length only (caption "Conv Incline Length"). Model length = ft × 12 + 24 in, or + 12 in with Elbow. | ConveyorSize | Slider 9–79 ft, 1 ft steps (the box alone allows 0–100) | Length. Moves the discharge further out and, on an incline, higher |
| `ConveyorHorizontalLength` + `Slider_ConveyorHorizontalLength` | Length after the elbow (ft). Model length = ft × 12 + 12 in. | ConveyorSize | Shown only with Elbow. 6 ft to (88 − Conveyor Length) ft, so incline + horizontal ≤ 88 ft | Length after the elbow. Moves the discharge further out, and higher unless that run is level |
| `ConveyorAngle` | Incline angle from the tail (deg). | ConveyorSize | 0–32°, or 0–35° for Engineering. Default 0 | Incline. Sets the discharge height and the horizontal footprint |
| `ElbowAngle` | Elbow bend (deg). After the elbow the conveyor runs at incline angle − elbow angle, so equal angles give a horizontal head run. | ConveyorSize | Shown only with Elbow. 0–35°, default 0. Nothing checks it against the incline angle | Angle of the head run. Sets the discharge height and the footprint |
| `ConveyorTailHeight` | Conveyor height at the tail (in), measured at the Height Reference point. | ConveyorSize | 0–500 in. Default 0 | Infeed height. Raises or lowers the whole conveyor |
| `HeightReference` | Where Conveyor Height is measured: tail shaft centre or bottom of frame. Tail Shaft is converted to frame height using the angle and tail pulley size. | ConveyorSize | Tail Shaft, Bottom Frame. No default set | The point the infeed height is measured to |
| `Bidirectional` | Belt runs both ways. Removes the tail guard and makes the anti-nip guards bidirectional. | ConveyorSize | Default off |  |
| `TailPulleyDiameter` | Tail pulley diameter (in). Also changes the tail shaft height used by Height Reference. | CommonSpecs | 12, 14. Default 12 | Tail shaft height shifts slightly. It matters when Height Reference is Tail Shaft |
| `TailShaftDiameter` | Tail shaft diameter (in). | CommonSpecs | 2.4375, 2.9375. Default 2.4375 |  |
| `TailGuard` | Tail guard. | CommonSpecs | Default off. Forced off when Bidirectional |  |
| `SliderBed` | Slider bed under the belt. | CommonSpecs | Default off. Forces Impact Bed on and Idler Side Removal off |  |
| `ImpactBed` | Impact bed at the loading zone. Opens the ImpactBed section. | CommonSpecs | Default off. Forced on and locked with Slider Bed |  |
| `IdlerSideRemoval` | Idlers removable from the side. | CommonSpecs | Default off. Forced off and locked with Slider Bed |  |
| `HeadPulleyType` | Head pulley lagging. | CommonSpecs | Blank, LAGGING, LAGGING Stainless Steel, LAGGING Magnetic. Only the last two with Stainless Head Section. Default LAGGING |  |
| `HeadPulleyDiameter` | Head pulley diameter (in). With the gearbox RPM it sets the belt speed. | CommonSpecs | 12, 14, 16. Default 12 | Head shaft sits 15.06, 15.81 or 16.81 in below the top of the side wall, so the discharge point shifts slightly |
| `HeadShaftDiameter` | Head shaft diameter (in). | CommonSpecs | 2.4375, 2.9375, 3.4375. Only the two largest with a Clincher SK6282 or SK6382. Default 2.4375 |  |
| `HeadScraper` | Sparta head scraper (belt cleaner). | CommonSpecs | Default on when Belt Finish is Smooth |  |
| `StainlessHeadSection` | Stainless steel head section. | CommonSpecs | Default off. Limits Head Pulley Type |  |
| `ZeroSpeedSwitch` | Side of the zero-speed switch. | CommonSpecs | Left, Right, None. Default None |  |
| `IdlerType` | Idler roll material. | CommonSpecs | Rubber, Steel. Default Steel for Steep Climb belts, else Rubber |  |
| `AntinipGuards` | Anti-nip guards at the pinch points. | CommonSpecs | Default off |  |
| `BidirectionalAntinipGuards` | Bidirectional anti-nip guards. | CommonSpecs | Always hidden. On when Bidirectional and Antinip Guards are both on |  |
| `FullSkirting` | Full-length skirting. Off means skirting at the transition only. | CommonSpecs | Default on |  |
| `Pullcord` | E-stop pullcord. | CommonSpecs | Default off |  |
| `Simalube` | Simalube automatic lubricators. | CommonSpecs | Default off |  |
| `EtchingType` | Etching style on parts. | CommonSpecs | Arrow, Cut through. No default set |  |
| `ImpactBedThickness` | Impact bed thickness (in). | ImpactBed | 3/16, 1/4. Section shown only when Impact Bed is on |  |
| `ImpactBedActiveTailSection` | Impact bed in the tail section A01. | ImpactBed | Read-only. Always on with Impact Bed |  |
| `ImpactBedActiveMidSection1` … `16` | Impact bed per mid section: A02–A08, then A11–A19. | ImpactBed | A row shows only when its section exists. Default off. Forced off without Impact Bed |  |
| `MotorSide` | Side the drive is mounted on. | MotorAndGearBox | Left, Right, None. No default set | Side the drive sticks out on, at the head. None = no drive |
| `Horsepower` | Motor power (hp). | MotorAndGearBox | 3, 5, 7.5, 10, 15. 2 hp is added with Helical Bevel | Motor diameter and length (from the Nord motor table), so how far the drive sticks out |
| `BeltFinish` | Belt top surface. | MotorAndGearBox | Smooth, Chevron 1/4in, Steep Climb |  |
| `BeltType` | Belt carcass: plies, rating, cover. | MotorAndGearBox | Depends on Belt Finish: 5 belts for Smooth (2-ply 220 PIW to 4-ply 440 PIW), 2 each for Chevron and Steep Climb |  |
| `BeltSplice` | Belt splice or lacing. | MotorAndGearBox | Super Screw Lacing, Cold Splice, Hot Vulcanized. Plus R2 Mech. for 2-ply; R5 Mech. and R2 Hidden Lace for 3-ply; R5-1/2 Mech. for 4-ply |  |
| `NoLegs` | Build without legs. Engineering sets Number Of Legs to 0 instead. | MotorAndGearBox | Default off. Shown only to non-Engineering users | No floor supports |
| `GearboxModel` | Gearbox family. | MotorAndGearBox | Helical Bevel, Clincher | Drive size. Helical Bevel also moves the drive out by a 0–2.25 in torque-arm offset |
| `GearboxType` | Clincher gearbox size. | MotorAndGearBox | Clincher SK3282, SK4282, SK5282, SK5382, SK6282, SK6382. Clincher only | Drive size |
| `GearboxRPM` | Clincher output speed (RPM). | MotorAndGearBox | List depends on Horsepower and Gearbox Type (e.g. 3 hp SK3282: 41, 45, 53, 59, 66). Clincher only |  |
| `EnteredBeltSpeed` | Target belt speed (ft/min). DriveWorks picks a Helical Bevel gearbox from the NordGear table. | MotorAndGearBox | 0–300. Default 0. Helical Bevel only | Picks the Helical gearbox, so the drive size |
| `OnlyAGMAClass2` | Limits the Helical Bevel pick to AGMA Class 2 gearboxes. | MotorAndGearBox | Default off. Helical Bevel only | Picks the Helical gearbox, so the drive size |
| `GearboxSelected`, `ActualBeltSpeed`, `BeltSpeedFPM` | Read-only results: selected gearbox and RPM, and belt speed (ft/min). | MotorAndGearBox | Read-only |  |
| `GearboxVoltage` | Motor voltage. | MotorAndGearBox | 460V, 575V |  |
| `MotorBrand` | Motor brand. | MotorAndGearBox | NordGear, Others |  |
| `MotorAngleOffset` | Motor angle offset (deg). | MotorAndGearBox | 0–100. Default 0 | Rotates the motor around the head shaft |
| `Brake` | Motor brake. | MotorAndGearBox | Default off |  |
| `VFD` | Variable frequency drive. | MotorAndGearBox | Default off |  |
| `NemaAdapter` | NEMA motor adapter. | MotorAndGearBox | Always hidden |  |
| `NumberOfLegs` | Number of legs, A40 to A44. Each leg opens its own section and is released as its own DW Start Leg spec. | LegsSpecs | 0–5. Default 0 for Engineering. Others get RoundUp((total length − 132 in) / 300 in) + 1, or 0 with No Legs | Number of floor supports |
| `OverrideLegPosition` | Removes the leg position limits and unlocks both cantilever braces. | LegsSpecs | Default off. Engineering only | Legs can go anywhere from 0 to 1000 in |
| `NumericTextBox1_HorizontalElbowLocation`, `NumericTextBox1_HorizontalHeadLocation` | Read-only: horizontal distance (in) from the tail to the elbow and to the head. | LegsSpecs | Read-only | Read-only footprint: tail to elbow, and tail to head |
| `LegA4nPosition` + `LegA4nPositionSlider` | Leg position: horizontal distance from the tail (in). Box and slider mirror each other. | LegA40–LegA44 | A40: 48 in to 120 in (or head − 24 in). Next legs: at least 24 in after the previous one (more with braces), at most 300 in after it, and 24 in before the head. Moved 8 in clear of the elbow. Override: 0–1000 in. Non-Engineering: automatic, A40 at 48 in | Where the leg stands, measured from the tail |
| `LegA4nHeightOffset` | Height offset (in). Leg height = conveyor height at the leg − offset. | LegA40–LegA44 | −100 to 360 in. Default 0 | Floor level at that leg |
| `LegA4nActive` | Turns that leg on or off. | LegA40–LegA44 | Locked for non-Engineering users. On when the leg number ≤ Number Of Legs; A42–A44 go off within 24 in of the head | Whether that leg exists |
| `UpperCantileverBraceA4n`, `LowerCantileverBraceA4n` | Cantilever braces on the head side (upper) and tail side (lower) of the leg. | LegA40–LegA44 | Locked off under 30 in of leg height, or when the brace would reach the elbow or head (8 in clearance, 18 in more with a head scraper). Non-Engineering A40 default: upper on, lower off |  |
| `UpperBraceAngleA4n`, `LowerBraceAngleA4n` | Brace angle (deg). | LegA40–LegA44 | 30–60°. Default 45. Shown only when that brace is on |  |
| `BraceHeightA4n` | Height (in) where the braces meet the leg. | LegA40–LegA44 | Min 14 in. Max from leg height: −17 under 48 in, −27 to 120 in, ÷2 − 17 to 240 in, ÷3 − 17 above. Error when a brace is longer than 120 in. Default 36 |  |
| `StubLegStyleA4n` | Stub leg (foot) style. Sent to the leg's DW Start Leg spec. | LegA40–LegA44 | Normal, Inside, Outside | Size and side of the foot plate at the floor |
| `ExtraNotes` | Free-text notes. Sent to the costing sheet and the database. | Notes |  |  |
| `NoTail`, `NoHead`, `NoElbow` | Leave out the tail, head or elbow section. | Settings | Default off. Locked while Only Head or Only Tail is on | Removes that section, so the conveyor is shorter |
| `OnlyHead`, `OnlyTail` | Build only the head or only the tail section. | Settings | Default off. Each locks the other | Only that section is built |
| `HighPriority` | High-priority job (raises its queue priority on release). | Settings | Default off |  |
| `CheckBox1_QTSideBeltSupport`, `CheckBox1_OutputDXFFlatState`, `CheckBox1_OutputPDF`, `CheckBox1_Etching` | Output switches: side belt support quantity, DXF flat patterns, PDFs, etching. | OutputChecks | Default off. Engineering only |  |
| `DevRelease` | Releases the spec as a development test. | Details | Development team only |  |
| `Mode`, `InputClientNumber`, `InputProjectNumber`, `InputEquipmentNumber`, `Revision` | Loads a saved spec from the database, or exports one. | ForDevOnly | Development team only |  |
| `Trajectory`, `TrajectoryHeight` | Material discharge trajectory and its height (in). | ForDevOnly | Height 16–100 in. Default 16. Development only | Draws the material path past the head |
| `Testing` | Test flag. | ForDevOnly | Development only |  |

Left out on purpose: the section toggles (`…CheckExtend`), the "i" help-picture toggles (`i…`), the hidden 3D camera fields, and buttons.

## Notes and open questions

- **Who counts as a Sparta user.** The form tests membership of the Engineering or Xortion Engineering team. A variable `IsUserInSparta` (Engineering or Sales) exists but nothing uses it. So a Sales login sees the same reduced form as a customer.
- **What a non-Engineering user gets.** The CommonSpecs, MaterialInfo, LegsSpecs, ImpactBed and Settings sections collapse to zero height. Their inputs keep their defaults, and the legs are placed automatically.
- **The legs are a separate project.** Each leg A40–A44 is released as a `DW Start Leg` child spec, and Light Duty Conveyor uses the same legs. What the conveyor sends to each leg is in [start-leg-inputs.md](start-leg-inputs.md).
- **A possible feed from the layout app.** Every spec is written to the SQL table `DWKitConveyorData`, keyed by client, project, equipment number and revision. The Load Data button reads a spec back from that table.
- **No default is set** for Conveyor Width, Height Reference, Motor Side, Horsepower, Belt Finish, Belt Type, Belt Splice or Gearbox Model. Confirm what a new spec starts with.
- **Not covered here:** the separate Web Kit Conveyor project (website configurator, 51 controls).
- **Other equipment types in the group:** Apron, Hopper (with V2 and V2 Panels), Light Duty Conveyor, Picking Conveyor, Platform (Straight, Picking, Layout, Bolts), Stairs, Ladder, Handrails (inside and outside), Start Leg. The Order and Select projects handle orders and project selection.
