# Web Kit Conveyor: form inputs

*Read from `DriveWorks Files/Sparta Website Configurator/Web Kit Conveyor/Web Kit Conveyor.driveprojx` as saved 2020-07-30 08:07. Written 2026-10-02 for Bruno's pre-sales layout app, which should use the same parameters as DriveWorks.*

This table lists every input on the Web Kit Conveyor form, the old quick conveyor configurator for Sparta's website, so the layout app can use the same parameter names. It lives in its own legacy group, `Sparta Website Configurator/Sparta Website Group.drivegroup` (SQL Server Compact), in project format 10.0.

- **DriveWorks Input**: the control name exactly as it appears in DriveWorks.
- **Description**: what the input is for, inferred from its caption, options and rules.
- **Group**: the form page the input sits on.
- **Limitation**: minimum, maximum, option list, or an override limit set by a rule. Empty when there is none.
- **Layout effect**: what the input changes in the conveyor's size or position in a layout. Empty when it changes neither.

## Inputs

Rows follow the form from top to bottom: the configuration panel on the right of WebForm, the only page the user sees, then the Tab1 page left over from the DriveWorks web template, which no step or frame shows. Units are in the description, and defaults are at the end of the limitation.

| DriveWorks Input | Description | Group | Limitation | Layout effect |
| --- | --- | --- | --- | --- |
| `ComboBox_Width` | "Width (in)": belt width (in). Not programmed yet: it changes nothing in the model and is only saved with the spec. | WebForm | 18, 24, 30, 36, 42, 48, 60, 72, 84. No default set |  |
| `SpinButton_Length` | "Length (ft)": conveyor length; with Elbow, the incline length. Model length = ft × 12 + 3 in with Elbow, or ft × 12 − 9 in without. | WebForm | 11–80 ft, 1 ft steps. Default 0, below the minimum | Length. Moves the discharge further out and, on an incline, higher |
| `CheckBox_Elbow` | "Elbow": adds a run after the incline. Keeps two elbow features of the model, else deletes them, and shows the second Length. | WebForm | Default off | Profile: one straight run, or an incline plus a run to the head |
| `SpinButton_LengthHoriz` | "Length (ft)", the same caption as the first: length after the elbow. Model length = ft × 12. Without Elbow that length is fixed at 12 in. | WebForm | Shown only with Elbow. 7–84 ft, 1 ft steps. Default 0, below the minimum. Nothing checks the total length | Length after the elbow. Moves the discharge further out |
| `SpinButton_Angle` | "Angle (deg)": incline angle. It drives two model angles, angle and 90 + angle. There is no separate elbow angle. | WebForm | 0–30°, 1° steps. Default 0 | Incline. Sets the discharge height and the horizontal footprint |
| `SpinButton_Height` | "Height (in)": conveyor height. Not programmed yet: it changes nothing in the model and is only saved with the spec. The model's tail height is fixed at 60 (`HeightTail`). | WebForm | 11–80 in, 1 in steps. Default 0, below the minimum |  |
| `CheckBox_Legs` | "Legs": keeps two leg features of the model, else deletes them. | WebForm | Default off | Floor supports, or none |
| `ComboBox_MotorSide` | "Motor": side of the drive. Keeps the right or the left motor feature and deletes the other. | WebForm | Right, Left. No default set: with neither picked, both motor features are deleted | Side the drive sticks out on |
| `Height`, `Width`, `Depth` | Template boxes. They feed only the template's Description text. | Tab1 | Never shown. 0–10000, default 0 |  |
| `Material` | Template material list. Feeds only the Description text. | Tab1 | Never shown. Oak, Pine, Steel, Aluminium, Copper, Cardboard (project table `DWLookupMaterialList`). No default set |  |
| `Quantity` | Quantity. Sets the spec's Quantity, Price and Discount properties: price = 1245 × quantity × the currency rate, less 10 % per 5 units, at most 30 %. | Tab1 | Never shown. 1–100. Default 0, below the minimum |  |
| `Color` | Colour, with a swatch. Feeds only the Description text. | Tab1 | Never shown. Options from the website group's Colors table. No default set |  |

Left out on purpose: labels (header "Kit Conveyor", footer "SpartaWay.com", "Specs", the template's "Lorem ipsum" tab texts, price and description), pictures and backgrounds, frames, the 3D preview `PreviewControl1` (it shows `Web Kit Conveyor Model.DRIVE3D`), the five tab buttons, and the Cancel and Add to Contract buttons of the Details page.

## Size and position in a layout

- **Units:** feet for the lengths, inches for width and height, degrees for the angle. The model rules work in inches.
- **The model** is one part, `Web Kit Conveyor Model.SLDPRT`, named after the spec. Its captured dimension and feature names are in the SQL Server Compact group, which can't be read here, so they are described by their rules only.
- **Length:** the incline is ft × 12 + 3 in with an elbow, or ft × 12 − 9 in without. The second length is the run after the elbow, ft × 12, or a fixed 12 in without an elbow.
- **Height:** fixed at 60 for every spec. The Height input doesn't reach it.
- **Width:** whatever the part was saved with. The Width input doesn't reach the model.
- **Two fixed or computed dimensions look like leg positions:** one is fixed at 48, the other is (the incline length above) × cos(angle) − 36 without an elbow, or 60 with one. Kit Conveyor's first leg also defaults to 48 in from the tail. This is inferred from the values only; confirm in the part.

## Notes and open questions

- **What it is.** The website's quick configurator, built on DriveWorks' single-form web template: WebForm with a 3D preview and a right-hand panel. The flow is the template's basket: Specify, then Add to Contract (which releases the model) to In Contract, and Edit raises the revision. The template's Tab1–Tab5 pages, the NavigationTabs and Footer forms and the Details page are left over. Navigation goes Start → WebForm → Finish, and no step or frame shows them. There are no user or team tests, no client or project fields, no SQL export and no documents.
- **Does anything still use it?** Probably not. It is registered only in the legacy website group. The main group doesn't list it, and no project there names it. The project was saved 2020-07-30, the part 2020-10-09 and the group 2021-11-22. Today, website users go through DW Select Project, DW Order Project and DW Kit Conveyor Project in the main group ([order-inputs.md](order-inputs.md)). Confirm with Sparta that the website no longer links to this group.
- **Compared with DW Kit Conveyor Project** ([kit-conveyor-inputs.md](kit-conveyor-inputs.md)). None of the control names match, so the layout app should use the Kit's names.

  | Parameter | Web Kit Conveyor | DW Kit Conveyor Project |
  | --- | --- | --- |
  | Belt width | `ComboBox_Width`: the same 18–84 in list, but it changes nothing | `ConveyorWidth`: outside of the side walls = belt width + 6.135 in |
  | Length | `SpinButton_Length`: 11–80 ft. Model ft × 12 + 3 in with an elbow, ft × 12 − 9 in plus 12 in without | `ConveyorLength`: slider 9–79 ft. Model ft × 12 + 24 in, or + 12 in with an elbow |
  | Length after the elbow | `SpinButton_LengthHoriz`: 7–84 ft, no check on the total | `ConveyorHorizontalLength`: 6 ft to (88 − incline length) ft |
  | Incline angle | `SpinButton_Angle`: 0–30° | `ConveyorAngle`: 0–32°, or 0–35° for Engineering |
  | Elbow angle | None | `ElbowAngle`: 0–35° |
  | Height | `SpinButton_Height`: 11–80 in, changes nothing; the model is fixed at 60 | `ConveyorTailHeight`: 0–500 in, with `HeightReference` |
  | Legs | `CheckBox_Legs`: on or off | `NumberOfLegs` 0–5, with position, height offset and braces per leg |
  | Motor side | `ComboBox_MotorSide`: Right, Left | `MotorSide`: Left, Right, None |
  | Everything else | None | Pulleys, shafts, belt, gearbox, horsepower, beds, guards, material data |

- **Couldn't verify here.** No SQL Server Compact provider is installed on this PC, so the captured dimension and feature names, the Colors and Currency tables and any saved specs in the website group can't be read. Opening the group in Administrator would show them.
- **Defaults below the minimum:** Length, Length after the elbow and Height start at 0 against minimums of 11, 7 and 11. Height's 11–80 is the same range as Length, so it looks copied.
- **Template leftovers that point at nothing:** the Description text uses `SpecialFeature1` and `SpecialFeature2`, which no longer exist, and the Height, Width and Depth tooltips use `HeightMin`, `HeightMax` and the like, which don't exist either.
