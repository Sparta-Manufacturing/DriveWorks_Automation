# Simulating a DriveWorks change

*Written 2026-10-09: what can be simulated today, what the DriveWorks API on this PC offers, and what the SOLIDWORKS side needs.*

A change to a DriveWorks project is simulated in three layers. Each layer is closer to the real build and costs more.

| Layer | Answers | Tool | Status |
|---|---|---|---|
| 1. Rules, offline | What the form shows, and **what DriveWorks will send to SOLIDWORKS** for given inputs: every captured dimension's value, feature and instance states, replacements, file names (or Delete), custom properties. Plus before/after diffs, and values that can't build (negative sizes, pattern counts under 1, rule errors) | `DwFormEngine` + `DwSimulate` (`Get-DwModelOutput`, `Compare-DwModelOutput`, `Test-DwModelOutput`) | **Works.** Hopper V2: 1,605 rules in 5 s; Panels: 16,726 rules in 15 s |
| 2. DriveWorks itself, no SOLIDWORKS | The same, run by DriveWorks: specification flow, macros (e.g. V2's `ReleaseAllPanels` loop and the hosted Panels specs), documents, and the list of components queued for generation | DriveWorks API (`DriveWorks.Engine.dll`), see below | **Possible, not built.** Needs the sandbox credentials and the user's OK |
| 3. SOLIDWORKS | What the values do to the geometry: sketches solving, mates, rebuild errors, the actual sizes | Model generation (the user), then a `.spa` (`DwSpa`) and DriveWorks' generation log (`Get-DwGenerationIssue`) | **Works, with the user generating.** What's Wrong details still need SOLIDWORKS |

## Layer 1: what the offline simulator knows

- **The rules:** every variable, control, calculation table and model rule, evaluated by DriveWorks' own Titan engine (`docs/formats/form-rules.md`).
- **The captured items, from the group** (`CapturedComponents.Data`): for each captured model, the DriveWorks and SOLIDWORKS name and type of each captured dimension (`PanelLength@Sketch10`), feature, suppression state, instance (`DW09B-Right Side Drop Zone Assy Dummy-1` … `-12`), custom property and configuration.
  - It holds **names only**: no values, sketches, relations, mates or positions.
  - It holds only what was captured, which is 51 of the master's instances in Hopper V2.
- **The component tree** (`Get-DwComponentTree`): nesting from `components/*.xml`. A deleted assembly takes its parts with it.
- **Owner names for `MyName`/`MyNumber`:**
  - instance rules: `<component set>\<instance>`;
  - file-name rules: `<component set>\<model>` (both confirmed);
  - other rules: assumed to be `<component set>\<model>\<SOLIDWORKS name>`. Kit Conveyor uses `MyNumber(3)` in about 2,700 dimension and suppression rules, reading the copy number from the set name (`DW01-A02-6 (DW01-A02)`), which counts from the left and is safe.

It cannot know whether SOLIDWORKS can build the values: a sketch that flips, a mate that loses its reference after a replace, a pattern that fails.

## Layer 2: the DriveWorks API on this PC

**Working since 2026-10-09** (`tools/DwTools/DwApi.psm1`).
- **The sandbox group opens headlessly** with the ClaudeAI user. Test specs CAI01-Hopper 0008 and CAI02-Hopper 0009 were created, driven and saved.
- **On the same inputs, DriveWorks and `DwFormEngine` agree on 746 of 747 Hopper V2 variables.** That took one fix in DwFormEngine: a new spec's defaults stay live until the user types in the control.
- **What it took:**
  - `SpecificationEnvironment.TemporaryFolderPath` and `.SpecificationBasePath` must be set; null gives "path1" / "default specification folder" errors.
  - `DriveInputs` takes `IDictionary<string,string>`.
  - Each `Start()` takes a spec id, even if never saved.
- **Rules for Claude's specs (user, 2026-10-09):** WO prefix starts with `CAI`, and Dev Release is checked.
  - ClaudeAI stays in team Engineering only, so it sees what other engineers see.
  - Dev Release is forced TRUE outside production in all 16 projects (item `dev-release-forced-in-dev`), so ClaudeAI's releases are local with tag 99.
- **Releasing:** `Invoke-DwSpecTransition` (Edit, then ReleaseLocal) runs the Completed state, including V2's Panels loop, and **queues** the models (`Generated=False`). The user generates them in SOLIDWORKS.
- **Generation:** the SOLIDWORKS add-in (`ProAddin`) exposes only `Connect`/`Disconnect`/`InvokeCommand`, which are UI commands. The likely automatic route is `ReleaseLocal` from an API host with DriveWorks' SOLIDWORKS libraries loaded, as Administrator does, with SOLIDWORKS open. That's not tried yet; the user generates for now.

The API surface, read from `DriveWorks.Engine.dll` 24.0.1.4:
- `DriveWorks.Hosting.EngineHost` → `CreateGroupManager()` → `OpenGroup(connectionString, user, password)` → `Group`.
  - `Group.Projects.GetProject(name)`
  - `Group.Specifications.GetSpecification(…)`, `GetSpecificationComponents(id, includeChildSpecifications)`
- `EngineHost.CreateSpecificationContext(group, SpecificationEnvironment)`, then on the context:
  - `Start(projectDetails)` creates a new specification;
  - `DriveInputs(@{control = value})` sets exact inputs;
  - `GetTransitions()` / `InvokeTransition(name[, inputs])` and `GetOperations()` / `InvokeOperation(name)` run the flow;
  - `Open(details)` / `Copy(details)` reopen or copy an existing spec;
  - `SpecificationDirectory`, `Report` and `TaskList` show where it went and what happened.
- `SpecificationEnvironment` has `SpecificationBasePath` (where spec folders go), `DocumentGeneration` options, `ReleaseToAutopilot` and `ReportingLevel`.
- `EngineHost.ConnectionManager.IsDisabled` switches off `QueryData`/`DbExecute`, so a test run can't write to SQL.
- `Group.RegisterGenerationAgent()` exists: a host can take model-generation jobs. Generating needs SOLIDWORKS and the DriveWorks SOLIDWORKS integration; not explored.

**Safety:**
- **A release can send emails** (client, done, costing) and **write data**: the ClientProjects group table, and SQL exports to the database the `Environments` table points at.
- **A spec is a record in the group database,** written by DriveWorks itself, not by us.
- **Proposed:** run test specs against a **throwaway copy of the sandbox group** in `work/`, with a temporary spec folder, database connections disabled and documents/emails off. The sandbox group and `DriveWorks Files` stay untouched.

## Layer 3: the SOLIDWORKS side

To *simulate* geometry without SOLIDWORKS, each master model's definition would be needed. None of it is in the group or the `.spa`:
- every dimension with its value and whether it drives or is driven;
- the sketches (entities, relations);
- the feature tree (type, parents, suppression);
- equations;
- configurations;
- the components (file, configuration, transform, suppression, pattern membership);
- the mates (type, references, suppression).

A read-only extraction macro could produce it (Solidworks_Automation has the macro runner and COM helpers). The request, **`SWExportForDW` → `.swtodw`**, is in [swtodw-request.md](swtodw-request.md). Even then, re-solving sketches and mates outside SOLIDWORKS is not realistic.

Two things such a model definition *would* allow:
- predicting mate failures after a `<ReplaceFile>` (the replacement must carry the mated faces, planes and names);
- finding which features a dimension feeds.

**The reliable layer 3 is SOLIDWORKS itself.** Generate the test spec's models in the sandbox, then read them back:
- `DwSpa` (`.spa` of the build): what was built, and the sizes;
- **DriveWorks' generation log** (`Get-DwGenerationIssue`, from the group database). It names every dimension not found, every value SOLIDWORKS refused, every `#VALUE!`, failed replacements and "Rebuild model" failures, per generated file. It doesn't say *which feature* fails, and a "Rebuild model" entry also appears on parts that open clean. What's Wrong still needs SOLIDWORKS, or the `.swtodw` export.
