# DW Apron Project: form inputs

*Read from `DriveWorks Files/Apron/DW Apron Project.driveprojx` as saved 2026-09-28 12:12. Written 2026-10-01 for Bruno's pre-sales layout app, which should use the same parameters as DriveWorks.*

> **Changed in the 2026-10-05 export:**
> - `Elbow` is now `TopElbow`;
> - the Conveyor Options collapse is fixed in production;
> - section existence and shipping assemblies come from `SectionLayout`.
>
> The inputs themselves are unchanged. See [the 2026-10-05 review](../../../tracking/reviews/2026-10-05.md).

This table lists every input on the Apron DriveWorks form, so the layout app can use the same parameter names.

- **DriveWorks Input**: the control name exactly as it appears in DriveWorks.
- **Description**: what the input is for, inferred from its caption, options and rules.
- **Group**: the form page the input sits on.
- **Limitation**: minimum, maximum, option list, or an override limit set by a rule. Empty when there is none.
- **Layout effect**: what the input changes in the apron's size or position in a layout. Empty when it changes neither.

## Inputs

Rows follow the form from top to bottom: Customer Info, Apron Dimensions (`ConveyorSize`), Conveyor Options (`CommonSpecs`), the motor page, Settings and the footer. After them come the MaterialInfo, Notes, OutputChecks and ForDevOnly pages, which are never shown. Box and slider pairs share a row. Units are in the description, and defaults are at the end of the limitation. How the run lengths become sections is in [apron.md](../apron.md) §1–3.

| DriveWorks Input | Description | Group | Limitation | Layout effect |
| --- | --- | --- | --- | --- |
| `NewClientProject` | Switches Client and Project to free text. Also changes the Equipment Name default to Ap10. | CustomerInfo | Engineering only. Hidden when opened from the Order project. Default off |  |
| `DropDownClient`, `TextBoxClient` | Client: picked from a list, or typed when New Client Project is on. It goes to the drawings and the ClientProjects export. | CustomerInfo | List from the ClientProjects group table. Ignored when opened from the Order project |  |
| `Project`, `ProjectName` | Project: picked from the client's projects, or typed. `ProjectName` also goes in the "done" email. | CustomerInfo | List filtered by the chosen client |  |
| `EquipmentName` | Equipment name. It is the file-name prefix of every file (`<prefix>-A01`, `00- <prefix>-Apron Conveyor Assembly`...) and the WO prefix in the ClientProjects export. It also appears in the emails. | CustomerInfo | Default: the WO prefix of the chosen project in the ClientProjects group table, or Ap10 with New Client Project |  |
| `PaintColor` | Main paint colour. The colour code shows read-only below it (`TextBox_ColorCode`, Engineering only) and goes into the kit file names (`…-K2-<code>`). | CustomerInfo | Options from the Colors group table. No default set |  |
| `SafetyPartsColor` | Paint colour for safety parts. Code in `SafetyColorCode` (read-only, Engineering only), used in the safety part names (`…-<code>-YD`). | CustomerInfo | Options from the Colors group table. No default set |  |
| `ConveyorNaming` | "Apron Number**". Not programmed yet: it changes nothing in the model and is only saved with the spec. | CustomerInfo | Never shown (zero height). Default DW10 with New Client Project, else the project's WO prefix |  |
| `StickerName` | Text on the sticker. Not programmed yet: it changes nothing in the model and is only saved with the spec. | CustomerInfo | Never shown (zero height). Default = file-name prefix |  |
| `E2ProjectNumber` | E2 project number. Work order = E2 number + "-" + work order number, on the drawings and in the ClientProjects export. | CustomerInfo | Engineering only. Locked when opened from the Order project |  |
| `WorkOrderNumber` | Work order number. | CustomerInfo | Engineering only |  |
| `DesignerDrafter` | Designer or drafter name (drawings' DrawnBy). | CustomerInfo | Engineering only |  |
| `Client` | Read-only display of the client name looked up in the database (`ClientTeamName`). | CustomerInfo | Always hidden |  |
| `ApronWidth` | "Apron Width" (in). | ConveyorSize | 36, 48, 60, 72, 84. No default set. The heavy-duty features are kept from 60 in | Width. Each section's side-plate planes sit width/2 + 4.4375 in each side, so width + 8.875 in apart |
| `Elbow` | "Top Elbow": adds the top elbow (A20) and a top run that carries the head. It switches the main assembly to `Apron Conveyor Assembly`; without it `Apron Conveyor Assembly V2` is used. | ConveyorSize | Default off | Profile: the incline bends at the top elbow into the top run |
| `BottomElbow` | "Bottom Elbow": adds the bottom elbow (A10) and a level bottom run that carries the tail. | ConveyorSize | Default off | Profile: a level bottom run, then the incline. Without it the tail is on the incline |
| `ConveyorLength` + `SLD_ConveyorLength` | Length of the inclined run (ft), measured along it. Box and slider mirror each other. Caption "Conveyor Length" when straight, "Conv Incline Length" with an elbow. It runs: straight, tail to head; Top Elbow only, tail to top elbow; Bottom Elbow only, bottom elbow to head; both, between the elbows. The 7 ft tail and 4 ft head count when they sit on this run, and mid sections fill the rest. | ConveyorSize | Slider in 1 ft steps: 14–71 ft straight, 10–108 Top Elbow only, 7–108 Bottom Elbow only, 3–108 both (the box alone allows 0–120). Above 67 ft (Top Elbow only), 94 ft (Bottom Elbow only) or 90 ft (both) the extra sections are not built. No default set | Length of the incline. With the incline angle it sets the rise, the horizontal reach, and where the head or top elbow sits |
| `TopHorizontalLength` | "Add Top Horizontal Section": adds mid sections A21–A24 between the top elbow and the head. Off, the head follows the elbow directly. | ConveyorSize | Shown only with Top Elbow. Default off | Off: the top run is the 4 ft head only |
| `ConveyorTopHorizontalLength` + `Slider_ConveyorTopHorizontalLength` | Top run length (ft), head included. Mid sections fill length − 4 ft. | ConveyorSize | Shown only with Top Elbow, and locked unless Add Top Horizontal Section is on. On: 7–60 ft in 1 ft steps (the box alone allows up to 100). Off: 4 ft (the box default is 3, below its minimum). Only 4 top sections exist, so above 44 ft the extra sections are not built. No default set | Length after the top elbow. Moves the discharge further out, and up or down when the top run slopes |
| `BottomHorizontalLength1` | "Add Bottom Horizontal Section": adds mid sections A02–A07 between the tail and the bottom elbow. | ConveyorSize | Shown only with Bottom Elbow. Default off | Off: the bottom run is the 7 ft tail only |
| `ConveyorBottomHorizontalLength` + `Slider_ConveyorBottomHorizontalLength` | Bottom run length (ft), tail included. Mid sections fill length − 7 ft. | ConveyorSize | Shown only with Bottom Elbow, and locked unless Add Bottom Horizontal Section is on. On: 10–67 ft in 1 ft steps (the box alone allows up to 100). Off: 7 ft. No default set | Length of the level run before the bottom elbow. Moves the incline and the head further out |
| `ConveyorAngle` | "Top Elbow Angle" (deg): the bend at the top elbow. The top run slopes at incline angle − top elbow angle, so equal angles give a level top run. | ConveyorSize | Shown only with Top Elbow. 10–55° in 5° steps. Default 0, below the minimum. Nothing checks it against the incline angle | Slope of the top run, so the discharge height and reach. The elbow's `TopelbowD` sketch size is 20 up to 40°, 23 at 45°, 30 at 50° and 35 at 55° |
| `ElbowAngle` | Incline angle from horizontal (deg). Caption "Conv Angle" without a bottom elbow, "Bottom Elbow Angle" with one. | ConveyorSize | 10–45° in 5° steps. Default 0, below the minimum | Incline. With Conveyor Length it sets the rise and the horizontal reach |
| `ConveyorTailHeight` | "Tail Pulley Height" (in). Not programmed yet: it changes nothing in the model and is only saved with the spec. | ConveyorSize | Always hidden. 0–500. Default 0 |  |
| `Bidirectional` | Bidirectional apron. Not programmed yet: it changes nothing in the model and is only saved with the spec. | ConveyorSize | Always hidden. Default off |  |
| `TypeBelt` | "Belt Type": the belt or chain. Combo Belt builds `DW10-A50` (with a bottom elbow) or `DW10-A50 V2`, CHAIN(Z Pan) builds `DW10-A51`, Double Beaded Chain builds `DW10-A52`, None builds none. It also sets the skirting width: 8 in, or 6 in for the two chains. See [apron.md](../apron.md) §4e. | CommonSpecs | Engineering only. None, Combo Belt, CHAIN(Z Pan), Double Beaded Chain. Default 2.4375, which is not an option. The combo box falls back to its first item, None, so no belt or chain is built until one is picked |  |
| `Thickness` | Double beaded chain plate thickness (in). It also picks the channel (C5x6.7 for 0.375, C6x8.2 for 0.25) and a part height of 5 or 6. | CommonSpecs | Shown only for Double Beaded Chain. 0.375, 0.25. Default None, which is not an option, so the combo box falls back to its first item, 0.375 |  |
| `H`, `L` | Combo belt profile: height H and leg L (in), on part `DW10-A50-2LB-NP`. A picture shows the profile. | CommonSpecs | Shown only for Combo Belt. 3–4 each. Default 4 |  |
| `OilerPosition` | Section that carries the oiler. | CommonSpecs | None, plus every section of the bottom run and of the incline when that run's first section is over 96 in. Top-run sections are never offered. The oiler is built only in a section of 96 in or more. Straight and Top Elbow only builds get a broken list (see the notes). Default None |  |
| `skimaintenance` | "Ski maintenance Position": section that gets the ski-maintenance features. | CommonSpecs | The Oiler Position list without the oiler's section. A warning shows under 96 in. Default None |  |
| `EmergencyStopPosition` | Section that gets the emergency stop. | CommonSpecs | The Oiler Position list without the oiler's section. Built only in a section of 60 in or more. Default None |  |
| `SpartaLogoPosition` | Section that gets the Sparta logo decal. | CommonSpecs | Shown only when A02, A11 or A21 is 108 in or more. The ski list without the ski section, plus the top-run sections when there is a top run. The decal is built only on a 108 or 120 in section (a warning shows otherwise). Default None |  |
| `Pullcord` | E-stop pullcord. Not programmed yet: it changes nothing in the model and is only saved with the spec. | CommonSpecs | Always hidden. Default off |  |
| `OilerPosition1` | Older copy of Oiler Position. Not programmed yet: it changes nothing in the model and is only saved with the spec. | CommonSpecs | Always hidden. Default None |  |
| `HeadShaftDiameter` | Head shaft diameter (in). Its only model rule is on a torque-arm part that is always deleted, so it changes nothing. | CommonSpecs | Always hidden. 2.4375, 2.9375, 3.4375. Default 2.4375 |  |
| `MotorSide` | Side the drive is mounted on, at the head. None keeps both motors in the main assembly, and drops the head's torque-arm assemblies. | MotorAndGearBox | Left, Right, None. No default set | Side the drive sticks out on. The motor mates (`motorPos`) are set to width/2 + 25.06 in, so the drive moves out with the width |
| `MotorBrand` | Motor brand. NordGear with Motor Side Right adds the `DW10-Nord Gearboxes` part to the head. | MotorAndGearBox | Engineering only. NordGear, Others. No default set |  |
| `Horsepower` | Motor power (hp). It changes only the motor's file name and description: every choice uses the same 10 HP SK8382 gearmotor model. | MotorAndGearBox | 7.5, 10, 15. No default set |  |
| `GearboxVoltage` | Motor voltage, in the motor description. | MotorAndGearBox | Engineering only. 460V, 575V. No default set |  |
| `GearboxModel` | Gearbox family. | MotorAndGearBox | Clincher only. No default set |  |
| `GearboxType` | Gearbox size. | MotorAndGearBox | Engineering only, shown only for Clincher. Clincher SK8382AZGB only. No default set |  |
| `GearboxRPM` | Gearbox output speed (RPM), in the motor's name and description. | MotorAndGearBox | Engineering only, shown only for Clincher. 9.3 only. No default set |  |
| `Brake`, `NemaAdapter` | Motor brake and NEMA adapter. They change the motor's name and description and the Nord gearbox configuration. | MotorAndGearBox | Always hidden. Default off |  |
| `VFD`, `MotorAngleOffset` | Variable frequency drive, and motor angle offset (deg). Not programmed yet: they change nothing in the model and are only saved with the spec. | MotorAndGearBox | Always hidden. VFD default off. Offset 0–100, default 0 |  |
| `BeltFinish`, `BeltType`, `BeltSplice` | Conveyor-belt fields left from the Kit Conveyor form. Not programmed yet: they change nothing in the model and are only saved with the spec. | MotorAndGearBox | Always hidden. Same lists as the Kit Conveyor |  |
| `EnteredBeltSpeed`, `OnlyAGMAClass2`, `GearboxSelected`, `ActualBeltSpeed`, `BeltSpeedFPM` | Helical Bevel belt-speed fields left from the Kit Conveyor form. Not programmed yet: they change nothing in the model and are only saved with the spec. | MotorAndGearBox | Always hidden. Helical Bevel is not offered |  |
| `HeadOnly`, `TailOnly`, `ElbowOnly` | Release only the head (A29), the tail (A01), or the elbows (A10, A20, or both). | Settings | Default off. Each is locked while another of these, or a No Head, No Tail or No Elbow box, is on. Without an elbow, Elbow Only releases the whole apron | Only that section is built |
| `NoHead`, `NoTail`, `NoElbow` | Leave out the head, the tail, or the elbows. | Settings | Default off. Locked while an "Only" box is on. No Elbow is also locked when there is no elbow | Removes that section. The others keep their place |
| `HighPriority` | High-priority job: raises its queue priority on release, and adds "High Priority - " to the tracking email's subject. | Settings | Default off |  |
| `DevRelease` | Releases the spec as a development test. | Details | Development team only. Default off |  |
| `MaterialType` | Material conveyed. Not programmed yet: it changes nothing in the model and is only saved with the spec. | MaterialInfo | Never shown (MaterialInfo frame hidden). Construction and Demolition Recycling, Single Stream Recycling, Organics, Other |  |
| `OtherTypeMaterial` | Material name when Material Type is Other. Not programmed yet: it changes nothing in the model and is only saved with the spec. | MaterialInfo | Never shown |  |
| `MaterialSizeMinimum` | Smallest piece size. Not programmed yet: it changes nothing in the model and is only saved with the spec. | MaterialInfo | Never shown. 0in, 2in, 5in, 8in+ |  |
| `MaterialSizeMaximum` | Largest piece size. Not programmed yet: it changes nothing in the model and is only saved with the spec. | MaterialInfo | Never shown. After 0in: Under 2in, 8in, 24in, 24in+. After 2in or 5in: 8in, 24in, 24in+. After 8in+: 24in, 24in+ |  |
| `FlowTPH` | Flow rate (tons per hour). Not programmed yet: it changes nothing in the model and is only saved with the spec. | MaterialInfo | Never shown. 0–500. Default 25 |  |
| `MaterialDensity` | Material density (lb/ft³). Not programmed yet: it changes nothing in the model and is only saved with the spec. | MaterialInfo | Never shown. 0–500. Default 20 |  |
| `ExtraNotes` | Free-text notes. Not programmed yet: it changes nothing in the model and is only saved with the spec. | Notes | Never shown (Notes frame hidden) |  |
| `CheckBox1_QTSideBeltSupport`, `CheckBox1_OutputDXFFlatState`, `CheckBox1_OutputPDF`, `CheckBox1_Etching` | Output switches: QT 100 side belt support, DXF flat patterns, PDFs, etching. Not programmed yet: they change nothing in the model and are only saved with the spec. | OutputChecks | Never shown (the OutputChecks frame has zero height). Default off |  |
| `Mode`, `InputClientNumber`, `InputProjectNumber`, `InputEquipmentNumber`, `Revision` | The spec keys the Order project fills in when it hosts an equipment spec. Only `InputClientNumber` is read, to look up the client name used when opened from Order. The others change nothing. | ForDevOnly | Never shown (ForDevOnly frame hidden). Mode Add or Edit, default Add. Client 0–100, Project and Equipment 0–10000, default 0. Revision 1–100, default 0, below the minimum |  |
| `Trajectory`, `TrajectoryHeight` | Material discharge trajectory and its height (in). Not programmed yet: they change nothing in the model and are only saved with the spec. | ForDevOnly | Never shown. Height 16–100, shown only with Trajectory, default 16 |  |

Left out on purpose: the section toggles (`…CheckExtend`), the "i" help-picture toggle (`iconveyorlength`), the `beltsup` check box (a spacer under the belt picture; no rule reads its value), the warning boxes `SkiPositionWarning` and `LogoWarning`, labels, pictures, the frames, the hidden 3D preview, and buttons.

## Notes and open questions

- **Who sees what.** The form tests the Engineering or Xortion Engineering team (`IsUserInEngineering`).
  - Engineering users get collapsible sections, one open at a time.
  - Other users see Customer Info under a "Conveyor Options" header with Client, Project, Equipment Name and the two colours. Apron Dimensions, the motor page (Motor Side, Horsepower and Gearbox Model only) and Settings are open. The Conveyor Options page has zero height, so Belt Type and the position lists keep their defaults.
  - `IsUserInSparta` exists but nothing uses it. Dev Release and the SaveInSpec button show only to the Developement team.
  - In practice the project is Engineering-only: non-Engineering users reach only Kit Conveyor and the platform projects through Sparta's website access.
- **Pages never shown.** The MaterialInfo, Notes and ForDevOnly frames are set to Visible = False, and the OutputChecks frame has zero height. Their inputs keep their defaults. All other inputs fit inside the 380 px frames.
- **Legs and supports: none.** The project has no `SpecificationHostControl`, no leg list tables, no leg or support models, and no reference to DW Start Leg. Nothing in the model reaches the floor.
- **Size and position for a layout.** The details are in [apron.md](../apron.md) §1–3 and §6. In short:
  - **Profiles.** Top Elbow and Bottom Elbow pick one of four:
    - straight: tail, mid sections and head on one incline;
    - Bottom Elbow only: a level bottom run with the tail, the bottom elbow, then an incline that ends at the head;
    - Top Elbow only: an incline that starts at the tail, the top elbow, then a top run with the head;
    - both: level bottom run, incline, top run.
  - **Length.** Each run is an input in whole feet, measured along it: Bottom Horizontal Length (tail included), Conveyor Length (the incline) and Top Horizontal Length (head included). The tail is 7 ft and the head nominally 4 ft, but four different head lengths are defined (apron.md §3). Mid sections are whole feet, at most 10 ft each.
  - **Elbows** come on top of the run lengths: no input includes them. Their size is fixed in the A10 and A20 models (`BottomelbowD` is always 20, `TopelbowD` 20–35 by angle). DriveWorks' only estimate, 47.4376 × tan(angle) in, is in variables no rule uses.
  - **Angles.** The incline rises at Conv Angle / Bottom Elbow Angle from horizontal. A bottom run is level. The top run slopes at that angle − Top Elbow Angle.
  - **Height.** No input sets a height. Tail Pulley Height is hidden and reaches no rule, and there are no supports, so the layout app has to set the elevation itself.
  - **Infeed and discharge.** The tail (A01) is the infeed and the head (A29) the discharge: at the end of the top run with a top elbow, otherwise at the top of the incline.
  - **Width.** The side-plate planes are width + 8.875 in apart. The drive sits on Motor Side at the head, mated at width/2 + 25.06 in, and it is the same 10 HP SK8382 gearmotor model for every horsepower.
  - **Capacity.** There are 6 bottom, 9 incline and 4 top section copies, so 60, 90 and 40 ft of mid sections. Longer runs lose their extra sections with no warning (apron.md §4).
  - **Shipping sections.** Today SA1–SA3, split by profile (apron.md §6). The `SectionLayout` calc table for the rework (Enable, weights, SA columns) exists, but no rule uses it yet.
  - **Maximum section length: still hard-coded.** The constant `ftMaximumSectionLength` = 10 exists, but only the three `…finallength` guards read it. The section counts (`/10`) and the carry-overs (`>10`, `−10`) in 21 variables use a literal 10. `MaximumSectionLength` = 120 is read only by the stale `A08Length`, and `ftMinimumSectionLength` = 3 and `MinimumSectionLength` = 36 are unused.
  - **Help pictures.** `Apron1.png` (both elbows), `Apron2.png` (Bottom Elbow only) and `Apron34.png` (straight) in `DriveWorks Files/Apron/Form Design Documents/` mark where each length and angle is measured.
- **How Apron is opened.** On its own. DW Order Project opens only Kit Conveyor and Platform Layout, and no other project names Apron. It hosts no child specs. In the sandbox group it is registered as not hidden and not deployed.
  - The "opened from Order" rules were copied from Kit Conveyor and are incomplete. The constant `OpennedFromOrderProject`, the ForDevOnly keys and the E2 lock are there, but the `Project` variable then reads `DWVariableProjectNameFromDB`, which doesn't exist in this project.
- **Where specs go.** There is no SQL export, so a spec is saved only in DriveWorks.
  - The Export Data Base and Load Data buttons call macros `ExportToDB` and `ImportFromDB`, which don't exist here. The variable `DataLine` still queries the Kit's `DWKitConveyorData` table, and nothing uses it.
  - When a spec completes, all documents are released: two emails, and `NewClientProjects`, which adds Client, Project, Work Order and WO prefix to the ClientProjects group table. It does this on every release, not only for new clients: the sandbox table holds 161 Apron rows, most with Work Order "-".
  - For non-Engineering users the flow also asks for an email `EmailToCustomerCAD`, which doesn't exist in this project.
- **No default is set** for Paint Color, Safety Parts Color, Apron Width, Motor Side, Motor Brand, Horsepower, Gearbox Voltage, Gearbox Model, Gearbox Type or Gearbox RPM. Belt Type (2.4375) and Thickness (None) default to values that aren't options. Both angles default to 0 with a 10° minimum, the top run box to 3 ft with a 4 ft minimum, and Revision to 0 with a minimum of 1. Confirm what a new spec starts with.
- **Looks wrong, for Sparta engineering to confirm:**
  - **Top Elbow Angle.** It is read here as the bend at the elbow (top run slope = incline − top elbow angle). That comes from the head's torque-arm rule (22.5° − (top − bottom angle) with both elbows) and the unused `TotalLength` variable. Confirm it in the profile sketch. Its maximum (55°) is above the incline maximum (45°), so the top run can slope down.
  - **Head torque arm.** Its angle follows the head's slope with a bottom elbow, but stays 22.5° for straight and Top Elbow only builds, whose heads can slope too.
  - **Top run with Add Top Horizontal Section off.** The box defaults to 3 ft, below its 4 ft minimum. If DriveWorks keeps 3, the top run is shorter than the 4 ft head. Check that it shows 4.
  - **Motor Side None** keeps a motor on both sides of the main assembly. **The Nord gearbox part** is added only for Right, although it has left-hand features.
  - **Gearbox rules.** The head's gearbox-mount rules test only the Clincher SK2282 to SK6282 sizes, but the only gearbox offered is SK8382AZGB, so they all take their fall-back values.
  - **Oiler list.** It offers every section of a run whose first section is over 96 in, but the oiler is built only in a section of 96 in or more. With a 31 ft run (10, 7, 7, 7 ft) it offers A03–A05, where no oiler is built.
  - **Oiler list in straight and Top Elbow only builds.** The list starts with `none` = `If(BottomHorizontalLength1, "None|", "None")`, but that check box is hidden and off without a bottom elbow. Once A02 is over 96 in, the list comes out as `NoneA02|A03|…|A11`: None and A02 merge into one item, and A11 is offered although these builds have no incline sections. Checked with DriveWorks' own `ListGetItems`. The ski, E-stop and logo lists are built from it. At straight 20–21 ft and Top Elbow only 16–17 ft, the logo list comes out empty. `LogoWarning.Height` then fails, and the whole left panel below Conveyor Options loses its layout. **Fixed in the sandbox on 2026-10-02:**
  - `none` = `If(DWVariableNumberOfBottomSection>0,"None|","None")`;
  - `IfError` guards on `LogoWarning.Height`/`Visible`, `SkiPositionWarning.Height` and `CommonSpecsExtend.Height`.

  The fix was verified with `DwFormEngine` (see [learnings](../../learnings.md)). Production isn't fixed yet.
  - **Warnings off by one.** The ski and logo warnings read `LengthMidSection<n>` for section A0n. For the bottom run that is the next section (`LengthMidSection2` is A03), so they check the wrong length there.
  - **Copied leftovers.** Clincher and Helical lists, conveyor-belt fields, the Kit Conveyor SQL query and the missing `ProjectNameFromDB` all come from the Kit Conveyor form.
