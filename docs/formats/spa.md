# `.spa`: what SOLIDWORKS built

*Written 2026-10-08 from the format repo (Solidworks_Automation, `modules/spa_format`, spec v5.1) and four real bundles (spec 46203 rev 6 and rev 7, the Hopper V2 master and the Panels master).*

A `.spa` is Sparta's extraction of a built SOLIDWORKS assembly. It is written by the **DataExtractionMacro** (Solidworks_Automation, `modules/sw_macros/src/DataExtraction`). In this project it answers the question the rules can't: *what was actually built?* The tools are in `tools/DwTools/DwSpa.psm1` ([tools/README.md](../../tools/README.md), "What was built").

**The format's source of truth is the other repo**, not this page. Its README and `spec/v5/fields.md` define it, and `doc/fields/Field-Reference.md` explains how each field is derived. DwSpa imports that repo's reader; it doesn't copy it.

## Container

- A ZIP with the extension renamed: `manifest.json`, `data.json`, `model.step` (mandatory since v5). The Explorer preview may add `preview.glb`/`preview.json`.
- `manifest.json`: `spa_version`/`spa_minor` (here 5.0), generator and version, `created_utc`, `record_count`, `source_file` (for example `J:\ARD1653-Hopper 46203\00- ARD1653-Hopper.SLDASM`), `source_saved_utc`, `custom` (client, project, job, designer).
- `data.json`: one record per **component occurrence group** (63 fields). Instances of the same file and configuration under one parent are merged into one record with `Qty_Local`.
- The JSON is UTF-8 without BOM since v2. The readers fall back to cp1252.

## Fields this project uses

| Field | Use |
|---|---|
| `ID`, `Parent_ID`, `SW_Level` | The tree. Level 1 = placed by the top assembly. |
| `Name`, `Configuration`, `File_Path` | Which file was used, under which configuration |
| `Qty_Local` / `Qty_Total` | Instances under the parent / rolled up. **Total anything with `Qty_Total`.** |
| `SW_Type`, `Class`, `Prod_PartClass` | Assembly or part; Sheet Metal / Solid; `Kit_Part`, `Single_Part`, `ERP_Part` (6-digit ERP number), `Misc_Part`, `BOM_Excl` |
| `Thickness`, `blank_length_in`, `blank_width_in`, `number_of_bends`, `bend_angles_deg` | The flat blank of a sheet-metal part, which is what the laser cuts |
| `volume_in3`, `Weight_lb`, `surface_area_in2` | Mass properties |

## What it does NOT contain

- **Instance numbers.** `DW09B-Right Side Drop Zone Assy Dummy-8` becomes "Right Side Drop Zone Assy Dummy ×2". Which dummies were left can't be told apart.
- **Suppressed components.** They are dropped, so anything that appears was neither suppressed nor deleted. For the same reason, a *master* `.spa` shows only what the master saves unsuppressed: the Panels master's back shapes list only their `1LBF` part, because their `2LF`/`3LF` are saved suppressed and turned on by `TopProfile`.
- **Rebuild errors** ("What's Wrong", red X), mates, transforms and feature dimensions. A panel with a red X is still extracted with its last good geometry.
- Custom properties other than `Description`, `BOM Name` and `Material`.

Nothing in Solidworks_Automation exports these today. That repo has COM helpers (`lib/SwCom.ps1`: `Connect-Sw`, `Invoke-Sw`) that a new read-only macro could build on. The request is [swtodw-request.md](swtodw-request.md).

**For rebuild problems, read DriveWorks' generation log** with `Get-DwGenerationIssue <WO>` (group database, read-only). It lists every dimension "not found", every value SOLIDWORKS refused (pattern counts of 0), every `#VALUE!` that reached a model, failed replacements, and "Rebuild model" failures. A "Rebuild model" entry alone doesn't mean a red X: parts that open clean also get it (see [../things-to-test.md](../things-to-test.md), HV2-05).

## Where the files go

`SPA files\` (client data, git-ignored) has three places:
- **The root is the inbox.** The SOLIDWORKS macro saves each `.spa` and its `.xlsx` there.
- **`Specs\`** holds the checked builds of specifications (`00- CAI03-Hopper.spa`).
- **`Masters\`** holds the master models (`DW09B-…`, any name starting with `DW` and a digit).

Once a build is checked, `Move-DwSpa CAI03` moves its `.spa` and `.xlsx` out of the inbox into the right folder. A bundle of the same name already there is an older build: it goes to `<folder>\Previous\` with its date, so before/after builds can still be compared.

Every DwSpa function takes a path or a name: `Find-DwSpa CAI03` looks in the inbox, then `Specs`, then `Masters`. `Test-DwHopperV2Build` finds the Panels master in `Masters` by itself.

## Names

DwSpa parses Sparta names as `<WO>-A<n>-K<n>[A-D]-<rest>`. The colour (`-GR-YD`, or `-BL-YD` in the DW09B masters) is pulled out, so two builds with different WO prefixes or colours compare by `Key` (`A32-K10-YD-with Onsite Bolts`). Part suffixes: `GR-YD` (shown as `main`) is the panel, and `2LF`, `3LF`, `2LBF`, `3LBF` are the gussets and flanges. The suffix set identifies the Panels shape (x531 has a `3LBF`, x6xx has a `2LBF`).

## Masters

- `DW09B-Hopper Main Assembly.spa`: V2's master, with 12 + 12 + 9 drop-zone dummies, all K50 variants, K60, K70 ×5 and K110 ×5 (pattern seeds), K80–K120, and 210 on-site bolts.
- `DW09B-General Assembly All Panels.spa`: every Panels shape (147 families: 56 R, 56 L, 35 B) with its parts. `Get-DwSpaFamilyCatalog` turns it into family → parts.
