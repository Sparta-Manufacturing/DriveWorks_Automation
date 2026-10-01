# Light Duty Conveyor: form inputs

*Read from `DriveWorks Files/Light Duty Conveyor/Light Duty Conveyor.driveprojx` as saved 2026-09-23 09:47. Written 2026-10-01 for Bruno's pre-sales layout app, which should use the same parameters as DriveWorks.*

This table lists every input on the Light Duty Conveyor DriveWorks form, so the layout app can use the same parameter names.

- **DriveWorks Input**: the control name exactly as it appears in DriveWorks.
- **Description**: what the input is for, inferred from its caption, options and rules.
- **Group**: the form page the input sits on.
- **Limitation**: minimum, maximum, option list, or an override limit set by a rule. Empty when there is none.
- **Layout effect**: what the input changes in the conveyor's size or position in a layout. Empty when it changes neither.

## Inputs

Rows follow the form from top to bottom. The five legs A40–A44 share one row per field, written with A4n. Units are in the description, and defaults are at the end of the limitation.

| DriveWorks Input | Description | Group | Limitation | Layout effect |
| --- | --- | --- | --- | --- |
| `NewClientProject` | Switches Client and Project to free text. | CustomerInfo | Shown to all users. Default off |  |
| `Client`, `ProjectName` | Client and project names, read-only. | CustomerInfo | Client is always hidden. Project Name shows only when opened from the Order project |  |
| `DropDownClient`, `TextBoxClient` | Client: picked from a list, or typed when New Client Project is on. Opened from Order, the client comes from the database instead. | CustomerInfo | List from the ClientProjects group table, hidden when New Client Project is on. The text box shows only to Engineering, and not when opened from Order |  |
| `Project`, `TextBox1_Project` | Project: picked from the client's projects, or typed. | CustomerInfo | List filtered by the chosen client |  |
| `EquipmentName` | Equipment name. It becomes the file-name prefix when Conveyor Number is empty. | CustomerInfo |  |  |
| `CheckBox_CustomNameToggle` | "Main ASM = Equipment Name": names the main assembly after Equipment Name instead of "Light Duty Conveyor". | CustomerInfo | Default off |  |
| `ConveyorNaming` | Conveyor number. Overrides Equipment Name as the file-name prefix. | CustomerInfo | Engineering only. Default looked up from the ClientProjects group table |  |
| `StickerName` | Text on the conveyor sticker. | CustomerInfo | Engineering only. Default = file-name prefix |  |
| `PaintColor` | Main paint colour. The colour code shows read-only below it (`TextBox_ColorCode`, Engineering only). | CustomerInfo | Options from the Colors group table |  |
| `SafetyPartsColor` | Paint colour for safety parts. Code in `SafetyColorCode` (read-only, Engineering only). | CustomerInfo | Options from the Colors group table |  |
| `E2ProjectNumber` | E2 project number. Work order = E2 number + "-" + work order number. | CustomerInfo | Engineering only. Locked when opened from the Order project |  |
| `WorkOrderNumber` | Work order number. | CustomerInfo | Engineering only |  |
| `Textbox_Description` | Equipment description. | CustomerInfo | Engineering only |  |
| `DesignerDrafter` | Designer or drafter name. | CustomerInfo | Engineering only |  |
| `MaterialType` | Material conveyed. Not programmed yet: it changes nothing in the model and is only saved with the spec. | MaterialInfo | Construction and Demolition Recycling, Single Stream Recycling, Organics, Other |  |
| `OtherTypeMaterial` | Material name when Material Type is Other. Not programmed yet: it changes nothing in the model and is only saved with the spec. | MaterialInfo | Shown only for Other |  |
| `MaterialSizeMinimum` | Smallest piece size. Not programmed yet: it changes nothing in the model and is only saved with the spec. | MaterialInfo | 0in, 2in, 5in, 8in+ |  |
| `MaterialSizeMaximum` | Largest piece size. Not programmed yet: it changes nothing in the model and is only saved with the spec. | MaterialInfo | After 0in: Under 2in, 8in, 24in, 24in+. After 2in or 5in: 8in, 24in, 24in+. After 8in+: 24in, 24in+ |  |
| `FlowTPH` | Flow rate (tons per hour). It only feeds the trajectory maths of the Conveyor Block, which this project never builds. So it changes nothing in the model and is only saved with the spec. | MaterialInfo | 0–500. Default 25 |  |
| `MaterialDensity` | Material density (lb/ft³). Same as Flow: only the unused Conveyor Block reads it. | MaterialInfo | 0–500. Default 20 |  |
| `ConveyorWidth` | Belt width (in). Above 48 in it forces Slider Bed and Impact Bed on. From 48 in only 10 in pulleys are offered. | ConveyorSize | 18, 24, 30, 36, 42, 48, 54, 60, 72, 84. No default set | Width. Outside of the side walls = belt width + 6.135 in. The leg width sent to DW Start Leg is belt width + 12.52 in |
| `Elbow` | Adds an elbow: the conveyor inclines from the tail, then bends to a flatter run up to the head. | ConveyorSize | Default off | Profile: one straight run, or an incline plus a flatter run to the head |
| `ConveyorLength` + `SLD_ConveyorLength` | Length (ft). Box and slider mirror each other. With Elbow it is the incline length only (caption "Conv Incline Length"). Nominal length = ft × 12 + 24 in, or + 12 in with Elbow. The model's Profile sketch adds 3 in, because the 84 in tail section is really 87 in. | ConveyorSize | Slider 9–79 ft, 1 ft steps (the box alone allows 0–100) | Length. Moves the discharge further out and, on an incline, higher |
| `ConveyorHorizontalLength` + `Slider_ConveyorHorizontalLength` | Length after the elbow (ft). Model length = ft × 12 + 12 in. | ConveyorSize | Shown only with Elbow. 6 ft to (88 − Conveyor Length) ft, so incline + horizontal ≤ 88 ft | Length after the elbow. Moves the discharge further out, and higher unless that run is level |
| `ConveyorAngle` | Incline angle from the tail (deg). | ConveyorSize | 0–32°, or 0–35° for Engineering. Default 0 | Incline. Sets the discharge height and the horizontal footprint |
| `ElbowAngle` | Elbow bend (deg). After the elbow the conveyor runs at incline angle − elbow angle, so equal angles give a horizontal head run. | ConveyorSize | Shown only with Elbow. 0–35°, default 0. Nothing checks it against the incline angle | Angle of the head run. Sets the discharge height and the footprint |
| `HeightReference` | Where Conveyor Height is measured: tail shaft centre or bottom of frame. With Tail Shaft, frame height = height − (20.5 × sin(angle) + (13.20 in − tail shaft depth) × cos(angle)). | ConveyorSize | Tail Shaft, Bottom Frame. No default set | The point the infeed height is measured to |
| `ConveyorTailHeight` | Conveyor height at the tail (in), measured at the Height Reference point. | ConveyorSize | 0–500 in. Default 0 | Infeed height. Raises or lowers the whole conveyor. The side walls are 13.20 in tall |
| `Bidirectional` | Belt runs both ways. Forces Tail Guard and Antinip Guards off (and hides Antinip Guards), and changes the tail skirting. | ConveyorSize | Engineering only. Default off |  |
| `TailPulleyDiam` | Tail pulley diameter (in). Also changes the tail shaft height used by Height Reference. | CommonSpecs | 8, 10 for belts under 48 in; 10 only from 48 in. No default set | Tail shaft sits 8 in (8 in pulley) or 9 in (10 in pulley) below the top of the side wall, plus 0.375 in from 48 in belts. It matters when Height Reference is Tail Shaft |
| `TailShaftDiameter` | Tail shaft diameter (in). | CommonSpecs | 2.4375 only. No default set |  |
| `TailGuard` | Tail guard. | CommonSpecs | Default off. Forced off when Bidirectional |  |
| `DrumPulley` | "Tail Drum Pulley": a drum pulley at the tail in place of the wing pulley. | CommonSpecs | Default off | Tail shaft 0.5 in further below the top of the side wall (0.75 in from 48 in belts, 0.44 in with a 10 in pulley from 48 in). It matters when Height Reference is Tail Shaft |
| `ImpactBed` | Impact bed at the loading zone, in the tail section A01 only. | CommonSpecs | Forced on for belts wider than 48 in. Locked while Slider Bed is on. Default on if Slider Bed is on, else off |  |
| `Lightduty` | "Light duty impact bed": switches the tail impact-bed parts to their light-duty features, and leaves out part A01-K8-3LBF. | CommonSpecs | Shown only with Impact Bed. Default on if Slider Bed is on, else off |  |
| `SliderBed` | Slider bed under the belt, in place of the carrying idlers. | CommonSpecs | Forced on and locked for belts wider than 48 in. Default off. Turns idler side removal (`sideremoval`) off and locks Impact Bed |  |
| `HeadPulleyType` | Head pulley lagging. | CommonSpecs | Blank, LAGGING, LAGGING Stainless Steel, LAGGING Magnetic. Forced to LAGGING Stainless Steel with Stainless Head Section. Default LAGGING |  |
| `HeadPulleyDiam` | Head pulley diameter (in). With the gearbox RPM it sets the belt speed. | CommonSpecs | 8, 10 for belts under 48 in; 10 only from 48 in. No default set | Head shaft centre 8.75 in (8 in pulley) or 10.06 in (10 in pulley) below the top of the side wall, so the discharge point shifts slightly. See notes |
| `HeadShaftDiameter` | Head shaft diameter (in). | CommonSpecs | 2.4375, plus 2.9375 with a 10 in head pulley. No default set |  |
| `HeadScraper` | Sparta head scraper (belt cleaner). | CommonSpecs | Default on when Belt Finish is Smooth |  |
| `StainlessHeadSection` | Stainless steel head section. Some head plates also go from 3/8 to 3/16 in. | CommonSpecs | Default off. Forces Head Pulley Type |  |
| `ZeroSpeedSwitch` | Side of the zero-speed switch. | CommonSpecs | Left, Right, None. Default None |  |
| `IdlerType` | Return idler roll material. | CommonSpecs | Rubber, Steel. Default Steel for Steep Climb belts, else Rubber |  |
| `AntinipGuards` | Anti-nip guards at the pinch points. | CommonSpecs | Default off. Hidden and forced off when Bidirectional |  |
| `BidirectionalAntinipGuards` | Bidirectional anti-nip guards. | CommonSpecs | Always hidden. Meant to be on with Bidirectional and Antinip Guards, but Bidirectional forces Antinip Guards off, so it never turns on |  |
| `FullSkirting` | Full-length skirting. Off means skirting at the transition only. | CommonSpecs | Default on |  |
| `Pullcord` | E-stop pullcord. | CommonSpecs | Default off |  |
| `Simalube` | Simalube automatic lubricators at the tail and the head. | CommonSpecs | Default off |  |
| `EtchingType` | Etching style on parts. Also sent to the legs. | CommonSpecs | Arrow, Cut through. No default set |  |
| `MotorAngleOffset` | Motor angle offset (deg). | MotorAndGearBox | Engineering only. 0–100. Default 0 | Rotates the motor around the head shaft |
| `MotorSide` | Side the drive is mounted on. | MotorAndGearBox | Left, Right, None. No default set | Side the drive sticks out on, at the head. None = no drive |
| `MotorBrand` | Motor brand. | MotorAndGearBox | Engineering only. NordGear, Others. No default set | NordGear places the gearmotor model. Others, or blank, leaves it out |
| `Horsepower` | Motor power (hp). | MotorAndGearBox | 3, 5, 7.5, 10, 15. 2 hp is added with Helical Bevel. No default set | Picks the gearmotor model configuration (gearbox size + hp), so the drive size |
| `GearboxVoltage` | Motor voltage. | MotorAndGearBox | Engineering only. 460V, 575V |  |
| `Brake` | Motor brake. | MotorAndGearBox | Engineering only. Default off |  |
| `NemaAdapter` | NEMA motor adapter. | MotorAndGearBox | Always hidden |  |
| `VFD` | Variable frequency drive. | MotorAndGearBox | Engineering only. Default off |  |
| `GearboxModel` | Gearbox family. | MotorAndGearBox | Helical Bevel, Clincher. No default set. Engineering only: for other users it sits below the section's cut-off | Drive size. Helical Bevel also moves the drive out by a 0–2.25 in torque-arm offset |
| `GearboxType` | Clincher gearbox size. SK5382 and SK6382 are modelled as SK5282 and SK6282. | MotorAndGearBox | Clincher SK3282, SK4282, SK5282, SK5382, SK6382. Clincher only. Engineering only | Drive size |
| `GearboxRPM` | Clincher output speed (RPM). | MotorAndGearBox | List depends on Horsepower and Gearbox Type (e.g. 3 hp SK3282: 41, 45, 53, 59, 66). Clincher only. Engineering only |  |
| `EnteredBeltSpeed` | Target belt speed (ft/min). DriveWorks picks a Helical Bevel gearbox from the HelicalBevelNordGearbox group table, at the nearest RPM within ±9. | MotorAndGearBox | 0–300. Default 0. Helical Bevel only. Engineering only | Picks the Helical gearbox, so the drive size |
| `OnlyAGMAClass2` | Limits the Helical Bevel pick to AGMA Class 2 gearboxes. | MotorAndGearBox | Default off. Helical Bevel only. Engineering only | Picks the Helical gearbox, so the drive size |
| `GearboxSelected`, `ActualBeltSpeed`, `BeltSpeedFPM` | Read-only results: selected gearbox and RPM, and belt speed (ft/min). | MotorAndGearBox | Read-only |  |
| `BeltFinish` | Belt top surface. | MotorAndGearBox | Smooth, Chevron 1/4in, Steep Climb. No default set |  |
| `BeltType` | Belt carcass: plies, rating, cover. All are 2-ply 220 PIW. | MotorAndGearBox | Depends on Belt Finish: 1/8 or 3/16 bare back (53b, 53c) for Smooth, 140b for Chevron, 143 for Steep Climb. No default set |  |
| `BeltSplice` | Belt splice or lacing. | MotorAndGearBox | R2 Mech., Super Screw Lacing, Cold Splice, Hot Vulcanized. No default set |  |
| `NumberOfLegs` | Number of legs, A40 to A44. Each leg opens its own section and is released as its own DW Start Leg spec. | LegsSpecs | 0–5. Default 0 for Engineering. Others get RoundUp((total length − 132 in) / 300 in) + 1 | Number of floor supports |
| `NumericTextBox1_HorizontalElbowLocation`, `NumericTextBox1_HorizontalHeadLocation` | Read-only: horizontal distance (in) from the tail to the elbow and to the head. | LegsSpecs | Read-only | Read-only footprint: tail to elbow, and tail to head |
| `LegA4nActive` | Turns that leg on or off. | LegA40–LegA44 | Locked for non-Engineering users. Engineering default: on when the leg number ≤ Number Of Legs. Non-Engineering: A40 and A41 always on; A42–A44 on when the leg number ≤ Number Of Legs and the leg is more than 24 in before the head | Whether that leg's assembly is placed |
| `LegA4nPosition` + `LegA4nPositionSlider` | Leg position: horizontal distance from the tail (in). Box and slider mirror each other. | LegA40–LegA44 | A40: 48 in to 120 in (or head − 24 in). Next legs: at least 24 in after the previous one (more with braces), at most 300 in after it, and 24 in before the head. Moved 8 in clear of the elbow. Override: 0–1000 in. Non-Engineering: A40 at 48 in, the others meant to space automatically (see notes) | Where the leg stands, measured from the tail |
| `LegA4nHeightOffset` | Height offset (in). Leg height = conveyor height at the leg − offset. | LegA40–LegA44 | −100 to 360 in. Default 0 | Floor level at that leg |
| `UpperCantileverBraceA4n`, `LowerCantileverBraceA4n` | Cantilever braces on the head side (upper) and tail side (lower) of the leg. | LegA40–LegA44 | Locked off under 30 in of leg height, or when the brace would reach the elbow or head (8 in clearance, 18 in more with a head scraper). A40's lower brace also locks if it would end within 48 in of the tail. Default on when the leg is active and at least 30 in tall, except non-Engineering A40: upper on, lower off |  |
| `BraceHeightA4n` | Height (in) where the braces meet the leg. | LegA40–LegA44 | Min 14 in. Max from leg height: −17 under 48 in, −27 to 120 in, ÷2 − 17 to 240 in, ÷3 − 17 above. Error when a brace is longer than 120 in. Default 36 |  |
| `UpperBraceAngleA4n`, `LowerBraceAngleA4n` | Brace angle (deg). | LegA40–LegA44 | 30–60°. Default 45. Shown only when that brace is on |  |
| `StubLegStyleA4n` | Stub leg (foot) style. Sent to the DW Start Leg spec. | LegA40–LegA44 | Normal, Inside, Outside. No default set | Size and side of the foot plate at the floor |
| `OverrideLegPosition` | Removes the leg position limits and unlocks both cantilever braces. | LegsSpecs | Default off. Engineering only | Legs can go anywhere from 0 to 1000 in |
| `ExtraNotes` | Free-text notes. Only saved with the spec: no document, email or model reads them. | Notes | Shown to all users |  |
| `OnlyHead`, `OnlyTail` | Build only the head or only the tail section. No legs are released. | Setting | Default off. Each locks the other | Only that section is built |
| `NoTail`, `NoHead`, `NoElbow` | Leave out the tail, head or elbow section. | Setting | Default off. Locked while Only Head or Only Tail is on | Removes that section, so the conveyor is shorter |
| `HighPriority` | High-priority job (raises its queue priority on release). Also sent to the legs. | Setting | Default off |  |
| `CheckBox1_QTSideBeltSupport`, `CheckBox1_OutputDXFFlatState`, `CheckBox1_OutputPDF`, `CheckBox1_Etching` | Output switches: side belt support quantity, DXF flat patterns, PDFs, etching. | OutputChecks | Default off. Never shown: the OutputChecks frame is always 0 high |  |
| `DevRelease` | Releases the spec as a development test. | Details | Development team only |  |
| `Mode`, `InputClientNumber`, `InputProjectNumber`, `InputEquipmentNumber`, `Revision` | Load or export a spec. The client and project numbers also look up the client team and project name in the database. | ForDevOnly | Development team only. Mode: Add, Edit, default Add |  |
| `Trajectory`, `TrajectoryHeight` | Adds a material trajectory part past the head, and sets its height (in). | ForDevOnly | Height 16–100 in, shown only with Trajectory. Default 16. Development only | Draws the material path past the head |
| `BlockOnly` | Releases only the Conveyor Block model and no legs. | ForDevOnly | Development only. Default off |  |
| `sideremoval` | "Add idler side removal": idler side-access openings, plus the conveyor sticker. | ForDevOnly | Development only. Always on unless Slider Bed is on: the rule ignores clicks. Default on |  |

Left out on purpose: the section toggles (`…CheckExtend`), the "i" help-picture toggles (`i…`), the hidden 3D camera fields, the hidden `TailSideWallHeight` and `SpinButton1` fields, the `SpecificationHostLegs` host control, and buttons.

## Notes and open questions

- **Who counts as a Sparta user.** The form tests membership of the Engineering or Xortion Engineering team (`IsUserInEngineering`). A variable `IsUserInSparta` (Engineering or Sales) exists but nothing uses it. So a Sales login sees the same reduced form as a customer. The Developement team also sees ForDevOnly and Dev Release.
- **What a non-Engineering user gets.** The MaterialInfo, CommonSpecs, LegsSpecs and Setting sections collapse to zero height. Their inputs keep their defaults, and leg A40 goes at 48 in. In the motor section only Motor Side, Horsepower, Belt Finish, Belt Type and Belt Splice fit above the 183 px cut-off. Gearbox Model and Motor Brand are hidden and have no default, so no gearbox, torque arm or gearmotor model is picked.
- **A non-Engineering release builds nothing.** For non-Engineering users (and with Block Only) the release generates only the `DW08-Conveyor Block` model and skips the legs. But that model's file-name rule is `If( TRUE=TRUE,"Delete",…)`, so it is never built. This path isn't live: Sparta's website access lets non-Engineering users reach only Kit Conveyor and the platform projects, so the Engineering/non-Engineering split here is only partly built and will be revisited.
- **No spec export to feed the layout app.** Both release macros run `ExportToDB`, which releases the documents `DWKitConveyorData` and `EquipmentListExport`. Neither exists in this project. The Load Data button reads the Kit Conveyor's `DWKitConveyorData` SQL table. So Light Duty specs are saved only in DriveWorks.
- **No default is set** for Conveyor Width, Height Reference, both pulley and shaft diameters, Etching Type, Motor Side, Motor Brand, Horsepower, Gearbox Model, Belt Finish, Belt Type, Belt Splice or Stub Leg Style. Confirm what a new spec starts with.
- **Other projects.** Each leg is a child spec of `DW Start Leg`, released in a loop from 1 to Number Of Legs. Its height, angle, width, braces, stub style, colour, etching and priority come from the `LegList` and `LegListInput` calculation tables. Each active leg's `<prefix>-A4n-Legs` assembly is then placed in the main assembly. The full mapping, the same as the Kit's except for the tail-shaft height in Leg Height, is in [start-leg-inputs.md](start-leg-inputs.md). The DW Order Project never names this project; it opens `DW Kit Conveyor Project`. The Light Duty Conveyor is also not deployed in the sandbox group, so the "opened from Order" rules can't apply yet.
- **Differences from the Kit Conveyor.** The form is a copy, with these changes:
  - 54 in belts added.
  - Smaller pulleys: 8 or 10 in (Kit: 12–16 in). The tail shaft is 2.4375 in only.
  - Side walls 13.20 in tall (Kit: 20.47 in).
  - 2-ply belts only.
  - No ImpactBed page: the impact bed is at the tail only, with a new Light duty option. Belts wider than 48 in force Slider Bed and Impact Bed on.
  - New Tail Drum Pulley option.
  - Idler side removal moved to ForDevOnly (`sideremoval`) and follows Slider Bed.
  - No `NoLegs` and no `Testing`. Clincher SK6282 removed.
  - Client fields shown to all users.
  - Shipping split at 40 ft (Kit: 50 ft incline, 48 ft after the elbow).
  - The Conveyor Block is never built, and there is no SQL export or costing sheet.
- **Looks wrong, for Sparta engineering to confirm:**
  - **Belt speed with a 10 in head pulley.** `HeadpulleyActualDiameter` gives 9.3125 in for an 8 in pulley, but a 10 in pulley falls through to 16.8125 in, a value left over from the Kit's 16 in pulley. So the belt speed and the Helical gearbox pick are off for 10 in pulleys.
  - **Head shaft height.** The head section places the shaft by pulley size: 8.75 or 10.06 in. The main assembly's `HeadShaftHeight@Profile` uses belt width instead: 8.75 in under 48 in, 10.06 in from 48 in. The two disagree for a 10 in pulley on a belt under 48 in.
  - **Non-Engineering leg spacing.** The automatic spacing for legs A41–A44 is gated by `iconveyorlengthReturn > 1`. That is a help-picture check box, so it may never trigger.
  - **Leftover option.** The Gearbox RPM list still has a 7.5 hp SK6282 case, which can't be chosen any more.
