# DW Platform Bolts: form inputs

*Read from `DriveWorks Files/Platform/DW Platform Bolts.driveprojx` as saved 2025-06-03 16:45. Written 2026-10-01 for Bruno's pre-sales layout app, which should use the same parameters as DriveWorks.*

This table lists every input on the DW Platform Bolts form, which builds the on-site bolt set for one joint between two platforms in different shipping assemblies, so the layout app can use the same parameter names.

- **DriveWorks Input**: the control name exactly as it appears in DriveWorks.
- **Description**: what the input is for, inferred from its caption, options and rules.
- **Group**: the form page the input sits on.
- **Limitation**: minimum, maximum, option list, or an override limit set by a rule. Empty when there is none.
- **Layout effect**: what the input changes in the bolt set's size or position in a layout. Empty when it changes neither.

## Inputs

The form has one page, Details. Rows follow it from top to bottom. Units are in the description, and defaults are at the end of the limitation.

| DriveWorks Input | Description | Group | Limitation | Layout effect |
| --- | --- | --- | --- | --- |
| `WOPrefix` | "W O Prefix": the file-name prefix. The bolt set is `<prefix>-OnSiteBolts-Assy-A<n1>-A<n2>`, saved in `\\192.168.0.19\Driveworks Output Files\<prefix>`. | Details | No default set |  |
| `ShippingAssembly1` | "Shipping Assembly1": despite the caption, the assembly number of the first platform at the joint (Platform Layout sends, for example, 101). The file name adds the "A". | Details | No default set |  |
| `ShippingAssembly2` | "Shipping Assembly2": the assembly number of the other platform. | Details | No default set |  |
| `PlatformWidth` | Length (in) of the joint, which is the width of the connected zone. The left-to-right bolt distance is width − 5 in (`LeftToRightBoltDist`). Bolt assemblies 1 and 5 are removed at 24 in or less. | Details | 0–100. Default 0 | How far along the joint the bolts spread |
| `PlatformThickness` | Platform frame depth (in). From 8 in up, the pillar width is 5 in and the top and bottom bolts are 3.5 in apart. Under 8 in, the pillar width is 0.625 × depth and the bolts are 1.5 in apart. | Details | 0–100. Default 8 |  |
| `DevRelease` | Releases the spec as a development test (local release). | Details | Visible to every user. Default off |  |
| `HighPriority` | High-priority job (raises its queue priority on release). | Details | Always hidden. Default off |  |

Left out on purpose: the Release button, which runs `ReleaseToAutopilot`.

## How Platform Layout sets the bolts

DW Platform Layout is the only project that creates Platform Bolts specs. Its `ReleaseAllBolts` loop works through every platform, and for each one through the rows of `BoltsListCalcTableClean`. A zone gets a bolt set when all three hold:
- its connection is Platform or Platform - Moment Connection;
- the neighbour's assembly number is higher than this platform's;
- the neighbour is in another shipping assembly.

For each such joint, the loop hosts a new Platform Bolts spec in `BoltsHostControl` and runs its `ReleaseToAutopilot`. The full mechanism is in [platform-layout-inputs.md](platform-layout-inputs.md) §"How Platform Layout builds the platforms".

| Platform Bolts input | Set by Platform Layout from | Notes |
| --- | --- | --- |
| `WOPrefix` | `DWVariablePrefixClientWO`, Layout's Prefix |  |
| `ShippingAssembly1` | `BoltsList` AssemblyNumberPrimary: the lower-numbered platform's assembly number |  |
| `ShippingAssembly2` | `BoltsList` AssemblyNumberSecondary: that zone's `ConnectedTo` number, the neighbour's assembly number |  |
| `PlatformWidth` | That zone's `ActualWidthXn` from the `PlatformList` row |  |
| `PlatformThickness` | Layout's `PlatformThickness` (default 8) |  |
| `DevRelease`, `HighPriority` | Layout's `DevRelease` and `HighPriority` |  |

Every input is set, so a hosted bolt spec is fully defined by Layout. Layout then inserts `\\192.168.0.19\Driveworks Output Files\<WOPrefix>\<WOPrefix>-OnSiteBolts-Assy-A<n1>-A<n2>.SLDASM` into its top-level assembly. This is the same path and name that Platform Bolts saves to. The bolt set is mated to the lower-numbered platform:
- its Top to the platform's Top;
- its Front to the zone face;
- its Right plane to the zone plane.

So it sits on the zone plane, level with the platform's Top plane.

## Notes and open questions

- **What it builds.** One component set, `DW05-OnSiteBolts-Assy-S100-S200`, named `<prefix>-OnSiteBolts-Assy-A<n1>-A<n2>`. Inside it, `DW05-Bolt Assy` is renamed `<prefix>-Onsite Bolt Assy`, which is the same file name for every bolt set in a job. Two dimensions are driven: `LeftToRightBoltDist@Sketch1` and `D1@Sketch1` (top-to-bottom bolt distance).
- **Who sees what.** There are no team tests. Dev Release shows to every user, and High Priority is always hidden. In the sandbox group the project is hidden and deployed, so users don't open it from the project list.
- **No default is set** for the prefix or the two assembly numbers. Platform Width defaults to 0, which would give a −5 in bolt distance. Platform Layout always fills these.
- **No exports.** The project has no documents: no SQL export, no emails and no ClientProjects row.
- **Looks wrong, for Sparta engineering to confirm:**
  - **Width limit.** Platform Width allows at most 100 in, but a platform side can be up to 120 in (Straight with Grating, Picking). A one-zone side joined to another platform would send a width above that maximum.
  - **Misleading captions.** "Shipping Assembly1/2" receive assembly numbers, not shipping-assembly numbers. The component set name (`…-S100-S200`) dates from the same older idea.
