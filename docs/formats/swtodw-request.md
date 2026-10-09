# SWtoDW: request for a SOLIDWORKS export made for DriveWorks

*Written 2026-10-09 by the DriveWorks_Automation repo. Paste the prompt below into a Claude Code session in **Solidworks_Automation**. Why each item matters is under "What DriveWorks_Automation does with it".*

## The prompt

> Build a new extraction macro, **`SWExportForDW`**, derived from the DataExtractionMacro (`modules/sw_macros/src/DataExtraction`). It writes a **`.swtodw`** bundle for the DriveWorks_Automation repo, which compares what DriveWorks asked SOLIDWORKS to build with what SOLIDWORKS actually built.
>
> Follow this repo's conventions, as for `.spa`:
> - a versioned format module `modules/swtodw_format/`: spec, JSON schemas, CHANGELOG, a sample fixture, a zero-install PowerShell reader `SwToDwFile.psm1`, and a conformance test;
> - the same version gate (MAJOR/MINOR, `x-since`);
> - units in inches and degrees;
> - UTF-8 JSON.
>
> **Reuse the SPA traversal; don't fork it.**
>
> **The macro must be read-only.** It may call `ForceRebuild3` in memory to refresh error states, but it must never save, never change a suppression state, dimension or configuration, and must close what it opened without saving.
>
> **Container.** A ZIP renamed `.swtodw` holding:
> - `manifest.json`;
> - `data.json`: exactly the SPA record set and fields (same IDs), so existing SPA tools keep working;
> - the extra members below.
>
> The STEP is optional; off by default.
>
> **`manifest.json`** (on top of the SPA manifest fields):
> - `swtodw_version`/`swtodw_minor`;
> - SOLIDWORKS version and service pack;
> - `rebuild` (`as_opened` or `after_force_rebuild`);
> - the root file's active configuration;
> - an optional `driveworks` object: spec name and id, passed as macro arguments or read from the folder name `<prefix>-<project> <id>`.
>
> **Extra members, linked by IDs:**
> 1. **`instances.json`: one row per component instance, not grouped.**
>    - The parent record ID and the matching `data.json` record ID.
>    - The instance name exactly as in the FeatureManager tree (`DW09B-Right Side Drop Zone Assy Dummy-8`) and its full path (`Top/Sub-1/Part-2`).
>    - The referenced file and configuration.
>    - Suppression state (resolved, suppressed, lightweight), fixed or floating, excluded from BOM, virtual, envelope, hidden.
>    - The 4×4 transform relative to the root (inches).
>    - The pattern or mirror feature that created it, if any.
>
>    **Suppressed instances must be listed too** (with their state); the SPA drops them.
> 2. **`features.json`: per unique document plus configuration, the feature tree in order.**
>    - Name, type (`GetTypeName2`), suppression in that configuration, parent and child feature names, and the owning sketch for sketch-based features.
>    - For patterns: instance count, spacing and skipped instances.
>    - For sheet metal: thickness, bend radius, K-factor.
>    - **The rebuild error and warning:** `IFeature.GetErrorCode2`, the warning flag, and the message text.
> 3. **`dimensions.json`: per unique document plus configuration, every dimension.**
>    - Full name `D1@Sketch1`, owning feature, value (system value converted to inches or degrees), and driving or driven.
>    - Whether it is linked to an equation or global variable, and read-only or configuration-specific.
>
>    Also the **equations and global variables**, with their values and any error.
> 4. **`sketches.json`: per sketch.**
>    - Owning feature, constraint status (`GetConstrainedStatus`: under, fully or over defined), and entity counts by type.
>    - **Relations in error or dangling** (`ISketchRelationManager`: relation type, status, entities).
>    - The dimensions on the sketch, by full name.
> 5. **`mates.json`: per assembly, every mate.**
>    - Name, type, alignment, flipped, suppressed, distance or angle value, and **error or warning code and text**.
>    - The components it references (instance names from `instances.json`).
>    - The entity types and names referenced (named planes, faces and axes).
>
>    Include the mate-reference names a component defines, if any.
> 6. **`properties.json`: every custom property,** file-level and per configuration: name, evaluated value and raw expression. Include `Type`, which the SPA skips (ISSUE-0064), and properties DriveWorks writes, such as `DWColor`.
> 7. **`errors.json`: one flat list of everything that is wrong,** with record or instance IDs:
>    - the What's Wrong list (`IModelDocExtension.GetWhatsWrong` or equivalent);
>    - features and mates in error or warning;
>    - unresolved or missing referenced files;
>    - components whose referenced configuration doesn't exist;
>    - zero-thickness or invalid bodies.
>
>    Severity: error or warning.
>
> **Two run modes:**
> - **(a) a built assembly:** a DriveWorks spec output, for example `00- CAI01-Hopper.SLDASM`;
> - **(b) a master model folder or assembly:** for example `DW09B-Hopper Main Assembly.SLDASM` and the Panels master. Here, export every configuration of each part, not only the ones in use.
>
> Allow limiting the run to a subtree or a name filter.
>
> **Deliverables:**
> - the macro and its runner entry (`Invoke-Macro.ps1 -Macro SWExportForDW …`);
> - the format module with schema, reader and sample;
> - docs covering what is and isn't captured;
> - a run on `DW09B-Hopper Main Assembly.SLDASM` as the sample fixture.
>
> Keep the reader dependency-free (PowerShell 5.1), like `SpaFile.psm1`.

## What DriveWorks_Automation does with it

| Member | Answers |
|---|---|
| `instances.json` | Which dummy stayed (`Dummy-8`, not "Dummy ×2"); whether a "Delete" became a suppression; where each panel sits. Today the SPA merges instances and drops suppressed ones. |
| `features.json` + `errors.json` | **Why a red X:** the failing feature and its message, per panel (for example the K20 offset panel, and the B111 bottom-flange pattern predicted to fail on CAI02). Today this is read by hand in SOLIDWORKS. |
| `dimensions.json` | Each dimension DriveWorks drove, compared with the value `DwSimulate` predicted (`Get-DwModelOutput`). Any difference means a rule didn't apply or an equation overrode it. |
| `sketches.json` | Which values make a sketch over-defined or flip, and the limits the rules must respect (like the 4 in minimum panel). |
| `mates.json` | Mates that break when DriveWorks replaces a dummy (the replacement must carry the mated faces and planes). Predicted before generation from the master's mates. |
| `properties.json` | Whether DriveWorks custom-property rules landed (`DWColor`, WO, Client). |
| Master mode | **The model definition for offline simulation:** every dimension's name and value, feature dependencies and mates, so a rule change can be checked against the model before generating. |

Today's `.spa` already covers the BOM, quantities, sheet-metal blanks and mass. `SWExportForDW` adds what's needed to explain a failed generation and to simulate a change before running it.
