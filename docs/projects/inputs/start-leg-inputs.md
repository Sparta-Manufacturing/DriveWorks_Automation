# DW Start Leg: form inputs

*Read from `DriveWorks Files/Start Leg/DW Start Leg.driveprojx` as saved 2026-09-21 16:46. Written 2026-10-01 for Bruno's pre-sales layout app, which should use the same parameters as DriveWorks.*

This table lists every input on the DW Start Leg form, the Legs project that builds one conveyor leg, so the layout app can use the same parameter names.

- **DriveWorks Input**: the control name exactly as it appears in DriveWorks.
- **Description**: what the input is for, inferred from its caption, options and rules.
- **Group**: the form page the input sits on.
- **Limitation**: minimum, maximum, option list, or an override limit set by a rule. Empty when there is none.
- **Layout effect**: what the input changes in the leg's size or position in a layout. Empty when it changes neither.

## Inputs

Rows follow the form from top to bottom: Customer Informations, Legs Inputs, the footer, then the Hidden and Obselete forms, which no frame shows. Upper and lower brace fields share one row. Units are in the description, and defaults are at the end of the limitation.

| DriveWorks Input | Description | Group | Limitation | Layout effect |
| --- | --- | --- | --- | --- |
| `CheckBox1_NewClientProject` | Switches Client and Project to free text. | Customer Informations | Default off. Forced on when Conveyor Path is filled, so always on when a conveyor hosts the leg |  |
| `ComboBox1_Client`, `TextBox1_Client` | Client: picked from a list, or typed when New Client Project is on. Goes to the drawings' Client property. | Customer Informations | List from the ClientProjects group table, hidden when New Client Project is on |  |
| `ComboBox1_Project`, `TextBox1_Project` | Project: picked from the client's projects, or typed. | Customer Informations | List filtered by the chosen client |  |
| `TXTBox_legNaming` | "Prefix": the file-name prefix. Leg files are named `<prefix>-A<n>-…`. | Customer Informations | No default set |  |
| `AssemblyNumber` | Assembly number n. The main assembly is `<prefix>-A<n>-Legs` and the spec is `<prefix>- Leg-A<n>-DW <id>`. Conveyor legs are 40 to 44. | Customer Informations | No default set |  |
| `TextBox1_WorkOrder` | Work order (drawings' WO property). | Customer Informations |  |  |
| `ComboBox_Colors` | Paint colour. | Customer Informations | Options from the Colors group table. Default Sparta Blue |  |
| `TextBox_ColorCode` | Colour code, used in the kit file names (`…-K1-<code>`). | Customer Informations | Default looked up from the Colors group table for the paint colour |  |
| `DesignerDrafter` | Designer or drafter (drawings' DrawnBy property). | Customer Informations |  |  |
| `EtchingType` | Etching style on parts. | Customer Informations | Arrow, Cut through. No default set; blank acts as Cut through |  |
| `LegHeightOffset` | Height offset (in). It changes nothing in this project, because the conveyor already subtracts it from Leg Height. It is only saved with the spec. | Legs Inputs | −100 to 360. Default 0 |  |
| `LegHeight` | Leg height (in), from the floor to the top of the leg, where the conveyor sits (help picture). Above 124.375 in the leg is built in two pieces, and above 244.375 in in three. Up to 48 in it gets a small fixed stub leg instead of the adjustable one. At 36 in or less there is no X-brace. | Legs Inputs | Text box. The caption says Max 360, but the Maximum property is 300. The member rules stop at 360. No default set | Leg height |
| `LegWidth` | "Width": width across the two leg columns (in), outside to outside in the help picture. The columns sit Width/2 either side of the centre, and the X-braces are Width − 0.5 in. | Legs Inputs | Text box, Min/Max properties 20–100. No default set | Leg footprint across the conveyor |
| `AddAngle` | Tilts the top plate of the leg to the conveyor slope. | Legs Inputs | Default off |  |
| `LegAngle` | Conveyor slope at the leg (deg). It sets the top plate angle and lengthens the columns by 3.5 × tan(angle) in. | Legs Inputs | Shown only with Add Angle, and 0 without it. Text box, Min/Max properties 5–75. No default set | The top plate follows the conveyor slope |
| `Bracing` | Cantilever braces from the leg up to the conveyor: head side (upper), tail side (lower), or both. | Legs Inputs | No Brace, Upper Brace, Lower Brace, Both Brace, from the Bracing group table. No default set | Adds braces under the conveyor |
| `BraceHeight` | Distance (in) from the top of the leg down to where the braces attach (help picture). | Legs Inputs | Hidden with No Brace. No default set | How far down the leg the braces reach |
| `UpperBraceWidth`, `LowerBraceWidth` | "Upper/Lower Brace Position": how far (in) that brace reaches along the conveyor from the leg (help picture). | Legs Inputs | Each shown only when that brace is on. No default set | Brace reach along the conveyor, toward the head (upper) or the tail (lower) |
| `Uppercoïncidant`, `Lowercoïncidant` | "coincident with the leg": that brace's top plate takes the leg angle, with no offset. | Legs Inputs | Shown only when that brace is on. Default off |  |
| `Pupper`, `Plower` | Offset (in) of the brace's top plate when it isn't coincident. | Legs Inputs | Shown only when that brace is on and not coincident. No default set |  |
| `UpperBraceAngle`, `LowerBraceAngle` | Slope (deg) of the brace's top plate when it isn't coincident. | Legs Inputs | Shown only when that brace is on and not coincident. Min/Max = the brace's own slope ± 65°, worked out from its position and Brace Height. No default set |  |
| `StubLegStyle` | Stub leg (foot) style. Normal: a 14 in stub plate with anchor bolts. Inside or Outside: an 8 in plate set inside or outside the column (offset 0.25 or 2.5 in), with no anchors. | Legs Inputs | Normal, Inside, Outside. No default set | Size and side of the foot plate at the floor |
| `HighPriority` | High-priority job (raises its queue priority on release). | Details | Engineering only. Default off |  |
| `DevRelease` | Releases the spec as a development test (local release). | Details | Development team only. Default off |  |
| `ConveyorLegs`, `ConveyorPath` | Set when a conveyor hosts the leg. The files then go to Conveyor Path, the conveyor's spec folder, instead of `\\192.168.0.19\DriveWorks Output Files\<prefix>-A<n>`. | Hidden | Never shown. Default off and empty |  |
| `Testing` | Test flag. It changes nothing in this project. | Hidden | Never shown. Default off |  |
| `OutputDXFFlatState`, `OutputPDF`, `OutputStep`, `Etching` | Old output switches: DXF flat patterns, PDFs, STEP files, etching. Only `Etching` reaches the model, as one custom property. | Obselete | Never shown. Default off |  |
| `UpperBraceHeight`, `LowerBraceHeight` | Old brace heights. Nothing in the model reads them. | Obselete | Always hidden |  |

Left out on purpose: the section toggles (`…CheckExtend`), labels, the help pictures and the Leg Info and Stub Leg Info picture panels, the 3D preview (`LegPreview`), and buttons.

## How the conveyors set the legs

The user confirmed that `DW Kit Conveyor Project` and `Light Duty Conveyor` both use this project for their legs: same legs, different settings. Both do it the same way.

- **Where the child spec is defined.** Each parent has a `SpecificationHostLegs` host control on its Hidden form. Its `InputValues` property is `=DWCalcLegListInput`. In the Kit the host is 0 px high and its form is in no frame, so it is never seen. In Light Duty it is 361 px high, on a frame that only the Developement team sees.
- **Two calculation tables.** `LegList` has one row per leg A40–A44: assembly number, leg height, bracing, brace height, angle, add angle, brace lengths, offset and stub style, read from the parent's `…A4n` variables. `LegListInput` has Name/Value rows: each Name is a Start Leg control, and its Value looks that leg up in `LegList`. The first row, `Index`, is the loop counter (`SpinButton1Return`), which the other rows use as the lookup key. Start Leg has no control called `Index`.
- **The release loop.** The parent's `GenerateModel` macro runs `ReleaseAllLegs`, which loops from 1 to `NumberOfLegs` (`ReleaseAllLegsSub`). Each pass:
  1. drives the hidden `SpinButton1` with the counter;
  2. points `SpecificationHostLegs` at a new `DW Start Leg` spec;
  3. runs that spec's `ReleaseToAutopilot` macro, or `ReleaseToLocal` with Dev Release.
- **The loop doesn't check `LegA4nActive`.** An inactive leg within the count is still released. The conveyor's main assembly then places only the active ones, with `<ReplaceFile>` on `<prefix>-A4n-Legs.SLDASM` from its own spec folder (Kit instances `DummyASM-28` to `-32`).
- **How Start Leg receives the values.** As ordinary control values, set through the host's input table. Start Leg has no parent references and no constants driven from outside. Its own rules still run: for example, the filled `ConveyorPath` forces New Client Project on.
- **What the child's form does when hosted.** Users never see it: the user works only in the conveyor's form, and only Light Duty's Developement frame shows the host. The leg's form rules still evaluate.
- **Inputs no parent sets.** These keep Start Leg's own defaults: the Obselete output switches (off), `UpperBraceHeight` and `LowerBraceHeight` (blank, unused), `Testing` from Light Duty (off), and the section toggles. None of them changes the leg's geometry, so the conveyor fully defines a hosted leg.

| Start Leg input | Set by Kit Conveyor from | Set by Light Duty from | Notes |
| --- | --- | --- | --- |
| `TXTBox_legNaming` | `DWVariablePrefixClientWO` | Same | The conveyor's file-name prefix, so the leg files are `<prefix>-A4n-…` |
| `TextBox1_Client`, `ComboBox1_Client` | `DWVariableClient` | Same |  |
| `TextBox1_Project`, `ComboBox1_Project` | `DWVariableProject` | Same |  |
| `TextBox1_WorkOrder` | `DWVariableWorkOrder` (E2 number & "-" & work order) | Same |  |
| `DesignerDrafter` | `DWVariableDrafter` | Same |  |
| `CheckBox1_NewClientProject` | `DWVariableNewClientProject` | Same | Start Leg forces it on anyway, so the typed Client and Project values are used |
| `ComboBox_Colors` | `DWVariableColor` (Paint Color) | Same |  |
| `TextBox_ColorCode` | `DWVariableColorCode` | Same |  |
| `AssemblyNumber` | `ExtractNumber` of `LegList` AssemblyNumber, `"A4" & (Index − 1)` | Same | 40 to 44 |
| `LegHeightOffset` | `LegList` LegOffset = `DWVariableLegA4nOffsetHeight` (the `LegA4nHeightOffset` input) | Same | Start Leg doesn't use it: it is already subtracted from Leg Height |
| `LegHeight` | `LegList` LegTotalHeight = `DWVariableLegTotalHeightA4n` = `ConvTailHeight` + tan(incline) × `LegA4nPosition` − offset. Past the elbow: the height at the elbow + tan(incline − elbow angle) × the distance past it | Same rule | **Differs in value.** With Height Reference = Tail Shaft, `ConvTailHeight` subtracts the tail shaft height above the frame bottom (`BearingHeightFromBottomOfSidePlate`). Kit: 6.1275 in (12 in tail pulley) or 5.1275 in (14 in). Light Duty: 13.197 in side wall − the tail shaft depth (8 or 9 in, plus 0.375 in from 48 in belts, plus the drum pulley offsets). So the leg top meets the frame bottom at the leg |
| `LegAngle` | `LegList` LegAngle = `DWVariableLegAngleA4n` − 90 = the slope at the leg: `ConveyorAngle`, or `ConveyorAngle − ElbowAngle` past the elbow | Same |  |
| `AddAngle` | `LegList` AddAngle: TRUE when that slope isn't 0 | Same |  |
| `LegWidth` | `DWVariableLegWidth+0.2282+0.14474787*2`, where `LegWidth = ConveyorWidth + 12`. So belt width + 12.52 in | Same | The same in both. The Kit table's "leg planes belt width + 11.6 in apart" comes from the Conveyor Block part (`LeftSideLegPlane` = `RightSideLegPlane` = W/2 + 5.8), not from the real legs |
| `Bracing` | `LegList` Bracing = `DWVariableLegA4nBracing`: Both, Lower, Upper or No Brace, from `LowerCantileverBraceA4n` and `UpperCantileverBraceA4n` | Same |  |
| `BraceHeight` | `LegList` BraceHeight = the `BraceHeightA4n` input | Same |  |
| `UpperBraceWidth` | `LegList` UpperBraceLength = `DWVariableLegA4nUpperBraceBoltCenter − DWVariableLegA4nBoltHolesCenter` | Same | Distance along the side wall from the leg's bolts to the upper brace bolt. The parent works it out from Brace Height, its brace angle (`UpperBraceAngleA4n`, 30–60°) and the slope |
| `LowerBraceWidth` | `LegList` LowerBraceLength = `DWVariableLegA4nBoltHolesCenter − DWVariableLegA4nLowerBraceBoltCenter` | Same | The same, toward the tail |
| `UpperBraceAngle`, `LowerBraceAngle` | The LegAngle row's value (`[5U]`, `[6U]`) | Same | The parent's 30–60° brace angles are not sent: they are already in the brace positions. With coincident braces, Start Leg uses the leg angle anyway |
| `Uppercoïncidant`, `Lowercoïncidant` | `TRUE` | `TRUE` |  |
| `Pupper`, `Plower` | `0` | `0` |  |
| `StubLegStyle` | `LegList` StubLegStyle = the `StubLegStyleA4n` input | Same |  |
| `EtchingType` | `EtchingTypeReturn` | Same |  |
| `ConveyorLegs` | `TRUE` | `TRUE` |  |
| `ConveyorPath` | `DWSpecificationFullPath`, the conveyor's spec folder | Same | The leg files land where the conveyor's main assembly looks for them |
| `DevRelease` | `DevReleaseReturn` | Same |  |
| `HighPriority` | `HighPriorityReturn` | Same |  |
| `Testing` | `TestingReturn` | Not sent | **Differs.** Light Duty has no Testing input. It changes nothing in Start Leg |

What the leg means for a layout: the conveyor sets where each leg stands (`LegA4nPosition`) and the floor level (`LegA4nHeightOffset`). Start Leg has no position input. It turns the values into:
- a leg from the floor up to the conveyor's frame bottom (Leg Height);
- two columns belt width + 12.52 in apart (Width);
- a top plate at the conveyor slope (Leg Angle);
- braces that reach Upper/Lower Brace Position along the conveyor and attach Brace Height below the top;
- a foot plate set by Stub Leg Style.

The braces stay under the conveyor. Only the columns and the foot plates touch the floor.

## Notes and open questions

- **What Start Leg is.** The Legs project. Its header reads "Leg Configurator". It builds one leg assembly, `<prefix>-A<n>-Legs`, from the DW07-A45 models: column sections A45A, B and C, X-braces, cantilever braces and stub legs. Kit Conveyor and Light Duty release one Start Leg spec per leg A40–A44.
- **Opened on its own?** In the sandbox group it is registered as deployed and not hidden, so it can be opened on its own. It has a full form, its own Release button and a standalone output folder. The DW Order Project and DW Select Project never name it. Confirm whether anyone uses it standalone.
- **Team tests.** The Customer Informations toggle shows only to Engineering (`IsUserInEngineering`: Engineering or Xortion Engineering). Other users see just its header, labelled "Conveyor Options" (copied from the Kit). High Priority is Engineering only, and Dev Release is Developement only.
- **No default is set** for Leg Height, Width, Leg Angle, Bracing, Brace Height, the brace positions and angles, Stub Leg Style, Etching Type, Prefix or Assembly Number. A conveyor fills all of them. Confirm what a standalone spec should start with.
- **No spec export to feed the layout app.** When a spec completes, all its documents are released:
  - two emails;
  - the `StartLeg3D` preview;
  - `NewClientProjects`, which writes Client, Project, Work Order and the prefix to the ClientProjects group table. So each leg of a conveyor may add its own row. Confirm that this is intended.
- **Looks wrong, for Sparta engineering to confirm:**
  - **Missing macro.** The conveyors' `Refresh` macro runs `CloseEditMode` in the hosted leg spec, but Start Leg has no macro of that name. Light Duty's `GenerateModel` runs `Refresh`.
  - **Document name mismatch.** The `NewClientProject` macro releases a document called `NewClientProject`, but the document is named `NewClientProjects`. No button runs that macro.
  - **Text-box limits.** Leg Height, Width, Leg Angle and the brace fields are plain text boxes:
    - Leg Height's Maximum property is 300, but its caption says Max 360.
    - Leg Angle's minimum is 5°, but the conveyors can slope 1–4°.
    - I found no code in the DriveWorks 24 assemblies that reads a text box's Minimum directly, so these limits may not be enforced.
  - **Swapped dimension names.** In `DW07-A45-Legs.SLDASM`, `D1@Lower1` gets the upper brace angle and `D1@Upper1` the lower one. This is harmless while both braces are coincident, because both angles then equal the leg angle.
  - **Circular defaults.** The defaults of `TextBox1_Client` and `TextBox1_Project` read the Client and Project variables. With New Client Project on, those variables read the same text boxes.
