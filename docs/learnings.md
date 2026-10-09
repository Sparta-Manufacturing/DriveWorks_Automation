# Learnings log (cross-project)

A running record of what we discovered and what bit us. **Append new entries at the top**, dated, with the evidence.
Promote stable facts into `docs/formats/*`, and repeatable procedures into a skill (`.claude/skills/`).

**Where an entry goes:**
- **This file** is for anything not tied to one project: DriveWorks and Titan engine behaviour, file formats, DwTools, Copy Group and exports, PowerShell, process, and patterns seen in several projects.
- **`docs/projects/<project>/learnings.md`** is for findings about one project's rules, form or models.
- **When a project finding teaches a general lesson,** write the details in the project file and end with an "Applies elsewhere:" line. Then add a short pattern bullet here that links back.
- `docs/projects/<project>/` also holds the project's logic diagrams (`logic.md`) where they exist. The input tables stay in [projects/inputs/](projects/inputs/).

## Project learnings

| Project | Learnings | Other docs |
|---|---|---|
| DW Apron Project | [apron](projects/apron/learnings.md) | [write-up](projects/apron.md), [inputs](projects/inputs/apron-inputs.md) |
| DW Hopper V2 | [hopper-v2](projects/hopper-v2/learnings.md) | [logic diagrams](projects/hopper-v2/logic.md), [inputs](projects/inputs/hopper-v2-inputs.md) |
| DW Hopper V2 - Panels | [hopper-v2-panels](projects/hopper-v2-panels/learnings.md) | [logic diagrams](projects/hopper-v2-panels/logic.md), [inputs](projects/inputs/hopper-v2-panels-inputs.md) |
| DW Hopper Project (original) | [hopper](projects/hopper/learnings.md) | [inputs](projects/inputs/hopper-inputs.md) |
| DW Kit Conveyor Project | [kit-conveyor](projects/kit-conveyor/learnings.md) | [inputs](projects/inputs/kit-conveyor-inputs.md) |
| Light Duty Conveyor | [light-duty-conveyor](projects/light-duty-conveyor/learnings.md) | [inputs](projects/inputs/light-duty-conveyor-inputs.md) |
| DW Picking Conveyor Project | [picking-conveyor](projects/picking-conveyor/learnings.md) | [inputs](projects/inputs/picking-conveyor-inputs.md) |
| DW Start Leg | [start-leg](projects/start-leg/learnings.md) | [inputs](projects/inputs/start-leg-inputs.md) |
| DW Ladder | [ladder](projects/ladder/learnings.md) | [inputs](projects/inputs/ladder-inputs.md) |
| DW Stairs Project | [stairs](projects/stairs/learnings.md) | [inputs](projects/inputs/stairs-inputs.md) |
| DW Platform Layout, DW Platform Bolts | [platform-layout](projects/platform-layout/learnings.md) | [inputs](projects/inputs/platform-layout-inputs.md), [bolts inputs](projects/inputs/platform-bolts-inputs.md) |
| DW Platform - Straight | [platform-straight](projects/platform-straight/learnings.md) | [inputs](projects/inputs/platform-straight-inputs.md) |
| DW Platform - Picking | [platform-picking](projects/platform-picking/learnings.md) | [inputs](projects/inputs/platform-picking-inputs.md) |
| DW HandRails | [handrails](projects/handrails/learnings.md) | [inputs](projects/inputs/handrails-inputs.md) |
| DW HandRails outside | [handrails-outside](projects/handrails-outside/learnings.md) | [inputs](projects/inputs/handrails-outside-inputs.md) |
| DW Order Project | [order](projects/order/learnings.md) | [inputs](projects/inputs/order-inputs.md) |
| DW Select Project | [select](projects/select/learnings.md) | [inputs](projects/inputs/select-inputs.md) |
| Web Kit Conveyor | [web-kit-conveyor](projects/web-kit-conveyor/learnings.md) | [inputs](projects/inputs/web-kit-conveyor-inputs.md) |

---

## 2026-10-09 (afternoon): The first dev → prod release

- **The user pushed all 18 projects from the sandbox to production** on 2026-10-09, **between 13:03 and 13:12 (−03:00)**.
  - It's logged in `tracking/releases.json`, with the release note in `tracking/copy-group/2026-10-09-dev-to-prod.md`.
  - **Rollback:** restore production from an archive taken before 13:03 that day.
- **Preparing a release means comparing against the last real production copy, not the last registered export.** Exports 06b to 07 were registrations of sandbox states, so the 31 ledger edits since 10-07 were only part of what prod would get. The full list came from 2026-10-06, the last prod → dev copy:
  - per project, `Compare-DwProjectContent`;
  - for the group, `Compare-DwGroupContent`. It found re-captures and test rows.
- **"Automatically select all components" carries every dev-side model change of every selected project,** wanted or not: re-saved masters, a re-capture that lost a reference. Anything not meant for production has to be left out by running the release in parts, or by choosing components.
- **The time of a Copy Group can be recovered afterwards:**
  - the configuration file is saved from the summary page, just before the copy runs;
  - Data Management writes `%LOCALAPPDATA%\DriveWorks\Common\DataManagementDisplayPrefs.xml` when it closes.

  The copy writes nothing to the source group.
- **`DWSpecificationDefaultFolder` stored in a project is only a cache.** Apron and Platform - Picking were saved in dev Administrator and store the dev folder. Hopper V2 stores the prod folder, yet its dev specs went to the dev folder. DriveWorks sets it from the group at run time, so a stored dev path does no harm in prod.

## 2026-10-09 (afternoon): DriveWorks' generation log is in the group database

- **Every model generation writes a report to the group:**
  - `Reports`: Title `<file> Generation yyyymmdd-hhmm`, counts and dates;
  - `ReportEntries`: `Type` 0 info, 1 warning, 2 error, with `Description` and `Detail`;
  - `DrivenComponentReports` links them to `DrivenComponents`.

  `Get-DwGenerationIssue <WO>` (DwSpa) reads them read-only and sorts them by kind. This is the missing third layer of a test: the rules say what was asked, the `.spa` says what was built, and the log says what SOLIDWORKS refused.
  - Each group keeps only its own runs. The sandbox's log starts 2026-10-05, so production generations (spec 46203) are not in it.
- **What the entries mean:**
  - **"Drive dimension … not found":** the captured name doesn't exist in the generated model, and the dimension keeps the master value. It finds master/capture mismatches (Hopper V2: the left K50 and two right Panels masters).
  - **"… invalid" with value 0:** SOLIDWORKS refuses a pattern count of 0 and keeps the old count. Whether that matters depends on the pattern also being suppressed ([things-to-test.md](things-to-test.md) HV2-11).
  - **"Drive color of … to '#VALUE!'":** a rule error reached the model.
  - **"Failed to replace a component instance":** a `<ReplaceFile>` target didn't exist. That is how the Panels folder mismatch showed up.
  - **"Rebuild model / Failed to rebuild within 3 attempts":** also logged on parts that show no red X in the finished assembly (10 on CAI04). Read it as "look here", not "broken".
  - **"Drive custom property 'Date' … Failed to drive in configuration ''":** logged on every generated assembly, in every project (572 times on the Apron tests). It's noise for now (issue `generation-date-property-assemblies`).
- **A test is cheaper with a baseline.** Comparing a spec's log with an earlier spec of the same inputs separates new errors from old ones. CAI03/CAI04 = CAI01/CAI02 minus the failed replacements proved the fix caused nothing.
- **Process (user, 2026-10-09):**
  - `SPA files\` is an inbox. The SOLIDWORKS macro saves there, and `Move-DwSpa` files each checked bundle into `Specs\` or `Masters\`.
  - [things-to-test.md](things-to-test.md) holds what Claude is unsure about in each project. It's read before every test spec, so each release answers more than one question.

## 2026-10-09: Real specifications through the DriveWorks API; defaults stay live

- **The API runs real specs in the sandbox** (`DwApi.psm1`, user ClaudeAI): `EngineHost` → `OpenGroup("Provider=LocalGroupProvider;Path=<file>;", user, password)` → `CreateSpecificationContext` → `Start` → `DriveInputs` → `InvokeTransition('Save')`. Specs CAI01-Hopper 0008 and CAI02-Hopper 0009 were saved for the user to release from SOLIDWORKS.
  - It needs `SpecificationEnvironment.TemporaryFolderPath` and `SpecificationBasePath`.
  - `DriveInputs` takes text.
  - Every `Start` takes a spec id, saved or not.
  - It works while Administrator has the group open.
- **DriveWorks and DwFormEngine agree on 746 of 747 variables** for the same Hopper V2 inputs; the user name differs.
- **The comparison found an engine bug: a new spec's defaults stay live until the user types in the control.** `TextBox_ColorCode` followed Paint Color to GR in DriveWorks, but DwFormEngine had frozen it at the starting default (BL). DwFormEngine now re-applies defaults after every input change (`Update-DwFormDefaults`).
- **`SppGetTeamsDataForUser` works in an API host;** it returned the user's real teams.
- **User rules for Claude's test specs:** WO prefix starts with `CAI`, and Dev Release is checked (the dev group has no Autopilot). `New-DwSpec` enforces both.
- **The DriveWorks SOLIDWORKS add-in has no generation call** (`ProAddin`: `Connect`, `Disconnect`, `InvokeCommand`). Generation is done by the user for now. See [formats/simulation.md](formats/simulation.md).
- **Released through the API the same day** (`Invoke-DwSpecTransition`, user request): Edit, then ReleaseLocal on CAI01-Hopper 0008 and CAI02-Hopper 0009.
  - **Panels children:** the Completed state's `ReleaseAllPanels` loop ran in the API host and released 10 + 5 Panels specs. Their Release macro falls back to ReleaseLocal when the group has no Autopilot setting.
  - **Models are queued, not generated:** 35 + 53 V2 components, all `Generated=False`, tags 109, though the host loads DriveWorks' SOLIDWORKS plug-ins. Emails became deferred tasks.
  - **The Release macro was not used** because, for a user outside Developement, Dev Release is forced off. V2's Release then goes to Autopilot only if the group's "Release to Autopilot" setting is on, and otherwise does nothing.
  - **Tags:** these specs carry 109/108 instead of the dev 99.
- **Then fixed in the projects, not the user's team** (user decision: ClaudeAI stays a plain Engineering user, to see what other engineers see). In all 16 projects that have the box, Dev Release's Checked rule is now:

  ```
  If( DWVariableIsProductionEnvironment = FALSE
     ,TRUE
     ,<the project's previous rule>)
  ```

  - In dev it's always TRUE, because the dev group has no Autopilot. In production nothing changes.
  - Checked offline in both environments, and through the API: as ClaudeAI, Hopper V2 now tags 99.
  - Tracked as `dev-release-forced-in-dev`, a cross-project item with a check.
- **The offline simulator matched DriveWorks' real release:**
  - all 122 distinct component file decisions agree, and all 15 Panels shapes chosen;
  - the only differences are the 11 copies of `DW09B-Onsite Bolt 1in long` under different kits. `DwSimulate` keys components by file name, so copies of one file under different parents are confused (to fix: carry the component path in model rules).
- The SOLIDWORKS-side export we need is requested in [formats/swtodw-request.md](formats/swtodw-request.md).

## 2026-10-09: How numeric text boxes and sliders round a value

Read from `DriveWorks.Engine.dll` and `DriveWorks.Applications.WebTech.dll` (24.0.1.4) by disassembling the IL. Details in [formats/form-rules.md](formats/form-rules.md#numeric-controls).
- **A slider snaps its value to its `Increment`:** `Round(value / Increment, 0) * Increment`, after clamping to Minimum and Maximum. An Increment of 1 makes every value a whole number.
- **A numeric text box rounds only to `DecimalPlaces`.** -1 (the default, on 249 of 253 boxes) means 15 places, so no rounding. It has no Increment in the engine: the `<Increment>` element saved with it is ignored.
- **A text box paired with a slider takes the slider's step.** When the text box's DefaultValue is the slider's `Return`, a changed DefaultValue resets the box's value, so a typed 105.37 comes back as the slider's snapped 105. Light Duty's leg positions did this ([projects/light-duty-conveyor/learnings.md](projects/light-duty-conveyor/learnings.md)).
- The web adapters don't round: the text box sends `Value.ToString()`, and the slider passes its value through.

## 2026-10-09: Model rules simulated offline; the DriveWorks API can run specs

- **`DwSimulate` evaluates every model rule for given inputs:** Hopper V2's 1,605 in 5 s, Panels' 16,726 in 15 s.
  - Rev 7 replayed with no rule errors.
  - Drop zone 6 → 8 ft changed exactly 28 values (K80 back, the K70 pattern to 1, planes +24 in).
  - On rev 7's K11 inputs, `Test-DwModelOutput` found the single bad value in Panels on its own: `R615-3LF Width@Sketch1` = −0.28125. The `.spa` shows that part built at 0.28 in.
- **The group's captures store names, not geometry.** Every captured instance name is there (`…Assy Dummy-1` to `-12`), linked to its rule. There are no values, sketches, mates or positions, and only captured items appear (51 of the master's instances).
- **`MyNumber` is used far beyond instance rules:** about 3,000 model rules in Kit Conveyor (dimension 1,183, suppression 1,499), reading the copy number from the component-set name (`DW01-A02-6 (DW01-A02)` → `MyNumber(3)` = 6). Their owner name starts with the set name; the rest is assumed.
- **The DriveWorks API can create and run specifications** (read from `DriveWorks.Engine.dll` 24.0.1.4; run the same day, see the entry above). See [formats/simulation.md](formats/simulation.md):
  - `EngineHost`, `GroupManager.OpenGroup(cs, user, password)`;
  - `CreateSpecificationContext`, then `Start` / `DriveInputs` / `InvokeTransition`;
  - `GetSpecificationComponents`;
  - `ConnectionManager.IsDisabled` and `SpecificationEnvironment` options for a safe test run.

  Running one needs the sandbox credentials and a decision on emails, data writes and which group to run against.

## 2026-10-08: .spa files tell what SOLIDWORKS built; model rules now evaluate offline

- **A `.spa` (Solidworks_Automation's DataExtractionMacro) is the missing half of a spec check.** The rules say what should be built, and the `.spa` says what was: every component with its configuration, quantity and sheet-metal blank. `DwSpa.psm1` reads it with that repo's own reader, and `Test-DwHopperV2Build` compares the two. Format notes: [formats/spa.md](formats/spa.md).
- **It has no instance numbers, suppression states or rebuild errors.** Suppressed components are dropped, so a master `.spa` shows only what the master saves unsuppressed (the Panels back shapes list 1 of their 3 parts). Read red X causes in SOLIDWORKS.
- **`Invoke-DwFormRule` (DwFormEngine) evaluates any rule text with a chosen owner name,** so model rules that use `MyNumber`/`MyName` run offline. Each evaluation gets its own child scope, so the slot can carry the exact owner name.
- **Confirmed by a real build: a component-set file-name rule's owner is `<component set>\<model name>`.** In Hopper V2, `DW09B-Hopper Main Assembly\DW09B-A32-K50B-BL -with Onsite Bolts` gives `MyNumber(4)` = 50, and the evaluated name matched the built `ARD1653-A32-K50-GR-YD -with Onsite Bolts` exactly. That's the same pattern as instance rules (2026-10-06).
- **File-name rules can return a leading `*`** (Hopper V2's `PrefixFileName*` variables start with `*`), while the built file has none. Strip it when comparing names.
- Project details: [Hopper V2](projects/hopper-v2/learnings.md).

## 2026-10-08: Learnings split per project

- Project-specific findings moved from this file into `docs/projects/<project>/learnings.md` (18 projects), keeping their dates. This file keeps the cross-project entries and links to the project files.
- Hopper V2 and Panels also have logic diagrams (Mermaid) in their folders.

## 2026-10-08: Checking a production specification offline (Hopper V2 spec 46203)

- **A specification folder holds an empty `.drivespec` and a copy of the `.driveprojx`.** The copy carries the spec's inputs as the controls' saved `Source` values, plus run metadata in `SpecialVariables` (spec id, revision, state, client details, URL). Variables and model rules store no results, and `components/*.xml` differs from the master only in whitespace.
  - Diff the inputs with `Compare-DwProjectContent <master> <spec copy>`. Replay them with `New-DwFormSession <spec copy> -StartValues Saved`.
- **`SppTableFilterByColumnComparison(t, a, b, TRUE)` keeps the rows where column a = column b.** It's a Pro Server function, so `DwFormEngine` returns `UnrecognizedFunction`. When column b holds one value in every row, stand in for it with `-OverrideRule @{ Slot = 'TableFilter(t,a,TableGetValue(t,b,1))' }`. Hopper V2's bolt zones (`BoltZoneTableCurrentSide`) need this.
- **Titan's `=` and `<>` on numbers allow for rounding noise.** `BeforeElbowLastPanelLengthRight` came out as −1.8e-15, and `<> 0` returned FALSE, so the K80 last panel was deleted as intended.
- **To test model rules that the form engine doesn't run**, join them into one existing slot: `IfError((rule),"#ERR") & "~~" & …`, set it with `-OverrideRule`, and split the result. `-OverrideRule` only takes slots that already exist. It doesn't work for rules that use `MyNumber`/`MyName`.
- A child project's inputs can be replayed the same way: take the host's `InputValues` table (Hopper V2 `PanelListInput`, one panel per `PanelSelectorSpinButton` value). Pass names that match a control with `-Inputs`, and names that match a constant with `-Override @{ DWConstant<Name> = … }`.
- **Regression check for a rule fix:** before and after, replay a real spec, snapshot every variable and every row of the child-input table, and diff. Only the intended values may change. For the Hopper V2 Backward fix: 3 values changed on rev 6, none on rev 7.
- **Pattern: hidden inputs keep their values and still drive rules.** Hiding a control doesn't reset it. Gate the variable that reads it on the switch that shows it. Seen in Hopper V2 (Back Angle Direction, Conveyor Angle) and Apron (the `none` check box).
- **Pattern: a long input with no maximum can silently remove whole sections.** Hopper V2's 69 ft drop zone dropped its transition and mid section without any message. Limit lengths against what the model can hold and against each other.
- **Pattern: limits.** Rule-driven `Minimum`/`Maximum` exist on numeric boxes (Hopper V2's Drop Zone Height), but platform rows show they may not be enforced (2026-10-01). Pair a limit with an `Error` rule that says why. Kit Conveyor, Light Duty, HandRails, Platforms and Stairs already use `Error` messages.
- Project details: [Hopper V2](projects/hopper-v2/learnings.md), [Hopper V2 - Panels](projects/hopper-v2-panels/learnings.md).

## 2026-10-06: MyNumber in model rules; scripted model rules

- **In a model rule, `MyName()` / `MyNumber()` read `<component set>\<instance>`.** The user confirmed this with the Drill Down view in the Administrator rule builder: `SA5 (Apron Conveyor Assembly)\DummyASMA -11`. The model name isn't part of it.
  - Every digit run counts, including those in the component set's name: Apron V2's `SA3 (Apron Conveyor Assembly V2)` gives 3, **2**, 15, and Hopper V2's `DW09B-…Dummy-n` gives 09, 09, n. Count from the right (`MyNumber(-1)`) when the set name may change.
  - DwFormEngine doesn't evaluate model rules, so we can't test this here. Check it in the Administrator rule builder.
- **Model rules can be generated by script.** 196 instance rules were written in one `Edit-DwProject` pass. Each one is matched by `PP/@CPRef` = the `ParamRef` from `Get-DwModelRule -Kind Instance`.
- Project details: [Apron](projects/apron/learnings.md) (V1/V2 slot numbering).

## 2026-10-06: First prod -> dev copy after the environment changes

- **The first save in Administrator 24.0 adds a lot of noise to `Compare-DwProjectContent`, with no behaviour change:**
  - forms gain default static properties (Opacity, InputSpacing, ButtonPadding...), hundreds per project;
  - flow and macro tasks are keyed by name instead of position (`Task[Release Document(s)]` instead of `Task#2`), and gain `CreationData`;
  - empty component task values are dropped.

  To tell real changes apart, compare flows by content with the task keys normalised (all 13 flows were identical), and look at rule and formula changes.
- **The Copy Group configuration file is plain XML** (`tracking/copy-group/2026-10-06-prod-to-dev.xml`):
  - `<Projects>` (Id, Name, RuleHistoryIncluded) and `<GroupTables>` (Id, Name);
  - `<Components AutoSelectFromProjects>`, plus `<Files>`/`<IncludedFile>` and `<Folders>`/`<ExcludedFolder>`;
  - `<AdditionalOptions>`: target and source folders, and the `Copy*` flags.

  It's the template for `New-DwRelease`. The **Save Configuration** button is on the wizard's Summary page.
- **The prod content folder has an empty `.git` and a `.github\copilot-instructions.md`.** Exclude them in File Selection.
- **`Restored Files` holds old copies of HandRails and the three Hopper projects under the same project names.** `Find-DwRule` reports project names, not paths, so skip that folder by path in checks.
- **PowerShell 5.1: `.Count` on a single `[pscustomobject]` returns nothing.** A check reported "Fail / none found" because of it. Wrap results in `@(...)` before `.Count` (already a CLAUDE.md rule).

## 2026-10-06: MyNumber() blanked whole projects in DwFormEngine; input paths go relative

- **`MyNumber()` and `MyName()` need a name-number provider.** Titan's default `DefaultNameNumberProvider` throws `NotSupportedException`. `ResumeUpdate()` then stops, and the error was swallowed, so **every slot in the project stayed blank**.
  - This hit Kit Conveyor, Light Duty and Hopper V2.
  - Before this fix, `DwFormEngine` results for those three projects compared blank with blank, including the first environment check.
- **Fix in `DwFormEngine`:**
  - `DwNameNumberProvider`, passed to the `ExecutionEngine(CultureInfo, IMyNameNumberProvider)` constructor (the property is read-only).
  - It strips `DWVariable`/`DWConstant`/`DWCalc` from the owner's name. Numbers are runs of adjacent digits, index 1 from the left, negative from the right.
  - A `ResumeUpdate` failure now throws instead of hiding.
  - All 18 projects load and calculate.
- **Relative paths resolve against the project's folder.** Evidence:
  - 252 of Kit Conveyor's 253 Drive3D rules are `"3D Model Files\…"`;
  - Apron's form pictures use `"..\Images\…"`;
  - Order Project (at the content root) uses `"Images\…"`;
  - the user's own rule 22 in prod is `"Form Design Documents\AddSliderbedheight1.png"`.
- **So rules that point straight at an input file need no environment lookup.** These are the form pictures and Drive3D document rules.
- **The location variables keep the lookup anyway** (user's decision): if the dev location moves, one table row changes. This holds even for the input-folder variables, which are read only by form pictures and Drive3D documents. Six `ServerInputFileLocation` variables are read by nothing.
- **Unconfirmed:** what a relative email attachment path resolves against.

## 2026-10-06: Project editions

- **"Project edition" (Project Settings) is DriveWorks 24's compatibility switch for behaviour changes.** It's stored as `Edition` on the `<Project>` root of `project.xml`. The schema in `DriveWorks.Projects.dll` allows `250900` (2025-09) and `260800` (2026-08).
  - No attribute means **2025-09**, the behaviour before 24.0. Every project in the 2026-10-05 export had none.
  - New projects default to 2026-08.
- **The only 24.0 change is date → text.** In 2025-09, a date without a time is formatted with the running machine's regional settings, and a date with a time in the invariant format. 2026-08 makes them consistent. It can be switched back at any time. Source: [24 SP0 Information](https://docs.driveworkspro.com/topic/24SP0Information#project-editions).
- **Our date rules:** 62 of them, mostly `Today()` in drawing properties (HandRails outside) and `DateTime(Now())` in Order Project documents.
- **Decision:** the user switches all projects to 2026-08. Tracked item `project-edition-2026-08`.

## 2026-10-06: Multi-line rules evaluate the same

- **The user writes rules multi-line in the rule builder:** one argument per line, leading commas, `& tail` on its own line. Claude now writes every rule that way: the "Rule layout" section of `driveworks-project-files`.
- **Line breaks and indentation inside a rule don't change evaluation.** Checked in the Titan engine (`DwFormEngine`) on the 52 environment rules, in both the prod and dev groups.
- **Re-formatting can still break a rule.** Moving the commas to the front of the lines once dropped one, and the engine rejected the rule with a parse error. Evaluate reformatted rules with `DwFormEngine` before handing them over.
- **The rule builder rejects a leading `=`.** The project XML stores control, document, macro and model rules with `=`, but the builder doesn't show it. Rules handed to the user must not have one (seen when pasting a macro's Target File Name rule).
- **In Markdown, rules for the user go in fenced code blocks, not table cells.** A table cell can't hold line breaks.
- **`DWVLookup`'s lookup column can be named instead of numbered:** `TableGetColumnIndexByName(table,"GroupName")` in place of `1`. Both give the same result. The named form survives column reordering.

## 2026-10-05: Copy Group test (prod → dev, every project but Apron)

- **Setup.** Constant `test = "dev"` in all 18 dev projects (Administrator in Apron, `Edit-DwProject` elsewhere). Then the user ran a Copy Group from prod into the dev group with every project except Apron. Files were snapshotted beforehand in `work/copytest-2026-10-05/before/`.
- **Selected projects are replaced whole.** All 17 copied projects came out byte-identical to the 10-05 prod export, and `test` was gone. Dev edits to a copied project don't survive and aren't merged.
- **Unselected projects are untouched.** Apron was byte-identical before and after, keeping `test` and the `NextEnabledSA` column. So releasing project by project works.
- **Copy Group keeps the source's file times.** The copied projects show prod's modified dates, not the copy date.
- **No capture changed.** Identical components were skipped, as documented.
- **Group table `ClientProjects` was replaced:** 1506 → 1505 rows, losing the dev-only row. A dev → prod release with tables ticked would do the same to prod's rows. Untick group tables on releases.
- **Adding a constant by XML matches Administrator:** `<Constant DisplayName="x" StoreName="DWConstantx" Value=".." Comment="" />` appended to `/TDM/Constants`, with nothing else. All 17 files validated and DriveWorks accepted them.

## 2026-10-05: First re-export review, and export tracking

- **A Copy Group from SPA-DWP overwrote `DriveWorks Files`** (project files and group) and with it the 10-02 dev edits. Only the Apron project and the group changed; 18 projects were byte-identical to the 09-23 package. The review is [tracking/reviews/2026-10-05.md](../tracking/reviews/2026-10-05.md). Production had fixes 1 and 2 for the Conveyor Options collapse, word for word.
- **Copy Group re-serialises every capture.** Each one's `Data` grows by 27 bytes and `Version` goes up by 1 (4294967296 → 4294967297), so neither shows a real re-capture. `Compare-DwGroupContent` takes the most common size shift as noise. The group's `GroupContentFolder` and `DefaultSpecificationFolder` now point into this repo, so sandbox runs write specifications to `DriveWorks Files\Specifications`.
- **The 09-23 package's group** (`Sparta Manufacturing Group.drivegroup`) is the production group at that date. Its registered project paths point to the package's temp folder (`…\Temp\8b3598bb`). Compare paths relative to `GroupContentFolder`.
- **`Compare-DwProjectContent` rename bug, fixed.** A control rename (`Elbow` → `TopElbow`) was applied to every whole word, including caption values ("Bottom Elbow"), string literals and comments, which produced false "changes". It now renames only rule references outside string literals, never in static values or `@Comment`, and includes the store forms (`CtrlVisible`, `CtrlListData`…).
- **Calculation tables now run in DwFormEngine** through Titan's public `SlotTable`, the same class DriveWorks uses (see [formats/form-rules.md](formats/form-rules.md)). `TableGetValue(table, column, row)` takes the column first: `(DWCalcSectionLayout, 7, 29)` is the `ShippingAssembly` of A29.
- **Pattern: never read a calculation table from inside itself.** A variable that reads the table depends on every cell, so it's circular. Use a helper column with relative references. Found on Apron's SectionLayout "Last" bug ([projects/apron/learnings.md](projects/apron/learnings.md)).
- **PS 5.1 JSON pitfalls.** `'[…]' | ConvertFrom-Json` yields the whole array as one object, and `@($arr) | ConvertTo-Json` writes `{"value":[…],"Count":n}`. Use `-InputObject` both ways and unroll arrays by hand. `.gitignore` has no trailing comments. `Set-Content -Encoding UTF8` writes a BOM.
- **Export tracking added** ([tracking/README.md](../tracking/README.md)): the export registry and snapshots, the `Edit-DwProject` ledger, tracked items with behaviour checks, and a SessionStart/UserPromptSubmit hook (about 1.5 s, mostly PowerShell start-up). Files open in Administrator are read with `FileShare.ReadWrite`.

## 2026-10-02: DwFormEngine, running forms in DriveWorks' own engine

- **Forms can be evaluated without DriveWorks running.** `Titan.Rules.dll` loads in PS 5.1. An `ExecutionEngine` with the `Titan.Rules.Common.*Functions` types registered (370 functions) evaluates real project rules. Rebuilding DriveWorks' slot layout from the XML is enough to reproduce form behaviour, including `Indirect`, list validation, and error propagation. Load time for Apron: 171 controls and 1,926 global slots in about 2 s, with no rule Titan can't parse. The model is in [formats/form-rules.md](formats/form-rules.md), and the tool is `tools/DwTools/DwFormEngine.psm1`.
- **Bare control names are the Source store.** `skimaintenance` in a rule is the raw input, `skimaintenanceReturn` the value. They are distinct slots (`GetStandardStoreName`: option −1 → the bare name).
- **PS classes can supply engine functions.** `ExecutionEngine.AddFunction($null, [Class].GetMethod('X'))` registers a static method of a PowerShell class. Return arrays as `StandardArrayValue(object[,])`, and create the array with `[object[,]]::new()`: `New-Object` wraps it in a PSObject, and the constructor call fails.
- **`Edit-DwProject` backups could overwrite each other.** `backups/<yyyyMMdd-HHmmss>` was shared by every edit in the same second. Five quick `Set-Dw*` calls left only intermediate states, and the pristine original was lost from `backups/` (a copy was kept in `work/`). `Backup-DwFile` now adds `-2`, `-3`… instead.
- **Headless Edge screenshots work:** `msedge --headless=new --screenshot=<png> --window-size=W,H <file-uri>` (`Save-DwFormScreenshot`). Claude can then look at a rendered form.

## 2026-10-02: Engine facts, and plain-text SQL logins

- **Engine facts, checked in `Titan.Rules.dll`:**
  - String `=` ignores case (`Value.IsEqual` calls `String.Compare(a, b, ignoreCase: true, culture)`), so `"None"="none"` is TRUE.
  - `ExtractNumber` returns a Double: `"A03"` → 3, `"NoneA02"` → 2, `"None"` and `""` → NaN.
  - `IfError` isn't a `StringFunctions` method, but it's valid rule syntax (used 162 times across the projects).
  - With a culture (as the engine calls it), `Value.Add` gives 100 + FALSE = 100, but 100 + `""` is an error (`ConvertFailed`). So a blank anywhere in a Top/Height sum breaks the whole chain.

  Found on Apron's Conveyor Options collapse ([projects/apron/learnings.md](projects/apron/learnings.md)).
- **SQL export documents store their login in plain text.** Seven SQL export documents in five projects have a non-empty `Username`/`Password` in their `LoginDetails` in `project.xml`:
  - Kit Conveyor: `DWKitConveyorData`, `EquipmentListExport`;
  - Platform Layout: `DWPlatformLayoutData`, `EquipmentListExport`;
  - Order: `ProjectListExport`;
  - Select: `AddNewTeamInSQL`;
  - Hopper: `EquipmentListExport`.

  All seven hold the same password (compared without printing it). Anyone with a `.driveprojx` can read it. **Never copy these values into docs, scripts, commits or memory**, and report them only by document name.
- **A Drive Control Value task can take its value from the macro argument,** so an empty `<sf:String>` doesn't mean blank (Order's Add button; [projects/order/learnings.md](projects/order/learnings.md)).
- **Sandbox permissions** (`SecurityTeamProjects` joined to `SecurityTeams` and the registered projects): only Select, Order and Kit Conveyor are open to the customer teams, Sales and Xortion Engineering. Every other project, the platform family and DW Start Leg included, is open only to Administrators, Developement and Engineering. This contradicts the user's statement that non-Engineering users reach the platforms, so production may differ (the sandbox group lags production: see 2026-09-28). **Pending the user's confirmation.** Open question: does a customer's Kit release still build its legs, given that Start Leg is restricted?
- **Pattern: the model may read only hidden helper controls.** Rules can copy a visible input into hidden or off-screen controls, and only those reach the model. Follow a control's value into other controls' rules before calling it unused (the original DW Hopper Project; [projects/hopper/learnings.md](projects/hopper/learnings.md)).
- Project details from the layout-app reads of 2026-10-02: [Order](projects/order/learnings.md), [Select](projects/select/learnings.md), [Web Kit Conveyor](projects/web-kit-conveyor/learnings.md), [Hopper](projects/hopper/learnings.md), [Hopper V2](projects/hopper-v2/learnings.md), [Hopper V2 - Panels](projects/hopper-v2-panels/learnings.md), [Apron](projects/apron/learnings.md).

## 2026-10-01: Hosted child specs, combo-box fallback, frames and limits

- **How a host's input table is applied,** read from `DriveWorks.Engine.dll` (`SpecificationHostControl.GetInputs`, then `TitanDesignMaster.SetNamedItemValues`). Not yet tested in a release:
  - Names match a control or a constant, ignoring case.
  - When a Name appears twice, the first row wins.
  - A Name the child doesn't have is ignored.
  - Values are written as is, with no check against the child's option list or min/max. A combo box then applies its own fallback (next bullet).
- **A combo box whose value isn't in its list falls back to its first item.** All 231 combo boxes in the 18 dumped projects have `SelectedItemRemovedBehavior` = SelectFirst. This is what makes Layout's "Railing" zones build a handrail ([projects/handrails/learnings.md](projects/handrails/learnings.md)). **Before concluding that a value outside a combo box's list breaks something, check `SelectedItemRemovedBehavior` and the list's first item.**
- **How a hosted child spec gets its inputs.** The parent has a `SpecificationHostControl` (`SpecificationHostLegs`), and its `InputValues` rule points at a Name/Value calc table (`=DWCalcLegListInput`). Each Name is a child control, and each Value sets it. The child sees plain control values, with no parent references or driven constants, and its own form rules still run. In calc-table rules, `[nU]` means n rows up and `[nL]` means n columns left.
- **Host input tables can set child constants,** not just controls (`PushedDown…`, `Hosted…`). A Name the child doesn't have is ignored.
- **A hosted child can send values back.** The child's close macros (`CloseAddMode`, `CloseEditMode`, `Cancel`) run a macro in the parent (`RunFromSpartaChild…`), with a pipe list as the argument (Platform Layout; [projects/platform-layout/learnings.md](projects/platform-layout/learnings.md)).
- **Pattern: a loop releases one child spec per row, then the parent swaps placeholders for the files.** Conveyors' legs (`ReleaseAllLegs`, [projects/start-leg/learnings.md](projects/start-leg/learnings.md)), Hopper V2's panels (`ReleaseAllPanels`, [projects/hopper-v2/logic.md](projects/hopper-v2/logic.md)), and Platform Layout's platforms, railings and bolts.
- **Rule engine behaviour, checked in `Titan.Rules.dll`:**
  - `TableGetValue` returns blank for row 0, and `TableGetColumnIndexByName` returns NaN for a missing column.
  - `ListAll` skips the first row as a header.
  - `ListFindItem` and `ListGetItem` count from 1.
- **Text-box Min/Max doesn't seem to be enforced.** Platform rows hold 101 and 1101 against a maximum of 100. This matches the Start Leg finding that no DriveWorks code reads a text box's Minimum.
- **List strings joined without a `|` merge items** (`"None" & "A02|A03"` gives `NoneA02|A03`). Confirmed with the engine's own `StringFunctions.ListGetItems`. Found in Apron's oiler list ([projects/apron/learnings.md](projects/apron/learnings.md)).
- **Controls past a frame's width can't be reached.** Section frames have both scroll bars hidden, so check `Left` against the frame width as well as `Top` against its height (2026-09-29). Seen in Picking Conveyor, Hopper V2, Panels and HandRails outside.
- **A copied form is not a copied model** (Light Duty vs Kit; [projects/light-duty-conveyor/learnings.md](projects/light-duty-conveyor/learnings.md)). Check the rules behind each control, not just the control.
- **Which project opens which.** Platform Layout opens Platform Straight, Platform Picking, both HandRails projects and Platform Bolts. Straight and Picking open only DW HandRails. No project opens DW Ladder or DW Stairs, so nothing passes values to them.
- **The user confirmed:** non-Engineering users can reach only Kit Conveyor and the platform projects, because Sparta's website access is limited. In every other project the Engineering/non-Engineering paths are partly built and not live, so read them as unfinished rather than broken. The user will revisit this.
- Project details from the layout-app reads of 2026-10-01: [HandRails](projects/handrails/learnings.md), [HandRails outside](projects/handrails-outside/learnings.md), [Platform - Straight](projects/platform-straight/learnings.md), [Platform - Picking](projects/platform-picking/learnings.md), [Platform Layout](projects/platform-layout/learnings.md), [Apron](projects/apron/learnings.md), [Picking Conveyor](projects/picking-conveyor/learnings.md), [Start Leg](projects/start-leg/learnings.md), [Kit Conveyor](projects/kit-conveyor/learnings.md), [Light Duty](projects/light-duty-conveyor/learnings.md), [Ladder](projects/ladder/learnings.md).

## 2026-09-30: Instance-rule grammar, corrected

- **The instance-rule handler is `ReleasedAssembly.ReleaseInstance` in `DriveWorks.SolidWorks.dll`**, not `ReleaseComponentHelper` in the Engine. The `|` split found on 2026-09-28 in `EvaluateComponentReferences` is on the component set's **Tags** rule. That method's `IsDelete`/`IsSuppress` chain matches whole strings, and it handles component **file-name** rules.
- In `ReleaseInstance`, each `|` part is handled on its own, so **`S|<Replace>X` and `<Replace>X|S` are the same**. With two state words, the last one wins. The angle-bracket forms (`<suppress>`, `<delete>`) are **not** recognised in instance rules. Details are in [formats/captured-models.md](formats/captured-models.md).
- How it was found: scan all `DriveWorks*.dll` for `ldstr` containing `<replace`, then decode the method IL with `GetILAsByteArray()` + `System.Reflection.Emit.OpCodes`, resolving tokens through `Module.ResolveMember`/`ResolveString`. Gotcha: a PS 5.1 `AssemblyResolve` handler that runs `Get-ChildItem` can recurse into a stack overflow. Pre-index the DLL folder, and skip `*.resources`.

## 2026-09-30: Form pages, lists and defaults (from the Stairs read)

- **DW Order Project opens only two equipment projects:** its `NewConveyor` button opens `DW Kit Conveyor Project` and its `NewPlatform` button opens `DW Platform Layout`.
- **A form page that sits in no frame is never shown.** Stairs' Extra Stuff and Ladder's Extra Info pages hold the output switches but are in no `FrameControl` and not in the navigation, so those outputs are always off.
- **`ListAll` doesn't remove duplicates.** Called from the rule engine (`TableFunctions.ListAll`), Stairs' tread-type list returned 105 entries for 2 types. `ListAllDistinct` returns the 2.
- **Numeric boxes can default below their own minimum** (Stairs, Picking Conveyor).
- Project details: [Stairs](projects/stairs/learnings.md), [Ladder](projects/ladder/learnings.md).

## 2026-09-29: Frame visibility, Source values, group tables (from the Kit Conveyor read)

- **User visibility is decided at the frame level.** `LeftSideWindow` stacks one `FrameControl` per section. The frames have scroll bars hidden, and their `Height` rules return 0 for non-Engineering users. So whole sections disappear, and fields below a frame's cut-off height are clipped even when their own `Visible` is TRUE. To find what a user sees, read the frame heights and the control `Top`/`Height` rules, not just `Visible`.
- **The user test is `IsUserInEngineering`** (teams Engineering or Xortion Engineering). `IsUserInSparta` (Engineering or Sales) has no reference outside its own definition.
- **PowerShell trap:** in `-like` patterns the backtick is the escape character, so `'| `*'` matches a literal `*`, not "anything". To match text that starts with a backtick, such as markdown code spans, use `.StartsWith()`.
- **A control's `Source` property holds its static value.** A Label's text is there ("Standard Conveyor Configurator"); its `Text` rule `=IF(X="","",X)` only points back to it. NumericTextBoxes store their last design-time value there. ComboBoxes and CheckBoxes have no `Source`.
- **Group table text uses tab between columns and LF between rows.** See [formats/drivegroup.md](formats/drivegroup.md).
- The sandbox group has **no specifications** (the `Specifications` table is empty). Spec values have to come from DriveWorks or from the `DWKitConveyorData` SQL table, or from a spec folder's project copy (2026-10-08).
- Project details: [Kit Conveyor](projects/kit-conveyor/learnings.md).

## 2026-09-28: Table lookups, tested in the real engine

- **The rule functions are static .NET methods** in `Titan.Rules.dll`, class `Titan.Rules.Common.TableFunctions`. You can call them from PowerShell on a table built with `Titan.Rules.Execution.StandardArrayValue(object[,])`. Return it with `,$obj`, because PowerShell unrolls it otherwise. This checks a lookup rule without Administrator.
- Signatures:
  - `DWVLookup(value, table, lookupColumnIndex, returnColumnIndex[, closestMatch])` searches down a column.
  - `DWHLookup(value, table, lookupRowIndex, returnRowIndex[, closestMatch])` searches across a row.
  - Indexes are 1-based.
- **With 4 arguments, the lookup defaults to closest match, meaning the *nearest* value** (55 → 60, 105 → 108, 0 → the first row). It doesn't round down, and it never errors. Pass `FALSE` for exact match: a missing value then returns an error.
- Cells stored as text or as numbers both match a numeric lookup value.
- Simple-table data is in `designMaster.xml`, not `project.xml`. See [formats/driveprojx.md](formats/driveprojx.md).
- A calc table is referenced in rules as `DWCalc<Name>`, for example `DWCalcSectionLayout`. To read one cell, use `DWVLookup(key, DWCalc<Name>, 1, TableGetColumnIndexByName(DWCalc<Name>, "<Column>"), FALSE)`. Hopper already uses this pattern.
- **A component set's file-name rule is stored twice**, in `project.xml` and in the root `PC/CN/R` of its part. Editing only one copy would leave them out of sync, so the new `Set-DwComponentSetRule` updates both and refuses if they already differ.
- *(Corrected 2026-09-30: wrong method, see the entry above.)* **Instance-rule grammar, from the engine:** the result is split on `|`, and `S`/`U`/`TRUE`/`FALSE` are short forms of suppress and unsuppress. See [formats/captured-models.md](formats/captured-models.md). How it was found: scan method IL for `ldstr` of `<replace>`, which leads to `ReleaseComponentHelper.EvaluateComponentReferences` and `IsSuppress`/`IsUnsuppress`/`IsDelete`.
- Gotcha: loading a part with a plain `[xml]` cast drops the `\r` from rule text, so comparing it to a `PreserveWhitespace` load showed false differences. Always compare parts loaded the same way.

---

## 2026-09-28: Reviewing a saved project

- **Keys that include a name break on renames.** A renamed component set changes every model-rule key under it, and a renamed control changes every property key. `Compare-DwProjectContent` detects:
  - variable and constant renames, by voting on how references changed;
  - component-set renames, by the same `RId`;
  - control renames, by the same form and type with 60% or more identical properties.

  It then substitutes the new names before diffing. Without this, 5 renames looked like 2,400 changes.
- **Renaming a component set doesn't update `<Replace>` strings everywhere.** Administrator updated the replace in one SA1 but not in the other (V2). Always search for the old name after a component-set rename.
- The user edits the **production** group and copies only the `.driveprojx` into the sandbox. The sandbox's models and captures then lag behind production. Check that captures still resolve: look for `Get-DwModelRule` rows whose Kind is `Unknown` or whose ModelPath starts with `<capture`.
- **PS 5.1 gotcha:** a local `$group` silently overwrote the `[string]$Group` parameter, because names are case-insensitive.

---

## 2026-09-28: Unused variables

- `Find-DwUnusedVariable` scans raw part text (not just rule fields), follows variable→variable references to find dead chains, and respects `Indirect("DWVariable…"&…)` name fragments.
- Apron result: 99 of 309 variables are unused, listed in `docs/projects/apron.md` §4c.
- **PS 5.1 gotcha, again:** `$x = if (...) { @(...) } else { @() }` unrolls. Write `$x = @($(if (...) { ... }))`.

---

## 2026-09-23: Reading a project (Apron mid sections)

- **The group file is locked while Administrator has it open.** `Get-DwGroupFormat` now opens it with `FileShare.ReadWrite`; SQLite read-only access works alongside Administrator.
- **Pattern: N optional copies of one section.**
  - A count variable, e.g. `bottomconstatmult = RoundUp(run/10)`, gates each copy's *file-name* rule (`If(count > k-1, name, "Delete")`).
  - The same count gates *instances* inside each copy (`If(count > k, "Delete", "Unsuppress")`), so an item appears only in the **last** copy.
  - It also gates the `<Replace>` of dummy placeholders in the SA assemblies.
- **Pattern: `If(TRUE=TRUE, "Delete", ...)` / `If(TRUE=FALSE, "Delete", ...)`** are kill switches: a rule disabled or forced without deleting it. Light Duty uses one to switch two component sets off for good.
- New tool: `Get-DwRuleDependency` traces a variable back to its inputs.
- **No instance rule means DriveWorks does nothing**, and Sparta models are usually saved unsuppressed. So an instance with no rule is normally **present**. I first assumed "suppressed"; the user corrected it. Default to "present, as saved".
- Apron findings to review with the user are in [projects/apron/learnings.md](projects/apron/learnings.md).

---

## 2026-09-23: Engineering process collected

- Sparta's conventions were collected from `Solidworks_Automation` into `docs/engineering-process.md`.
- Jonathan confirmed the codes that no file defines:
  - **Process index:** L Laser, B Bend, D Detailing, F Fab, P Paint, N Straight cut, S Subbed.
  - `-YD` = yard (assembled on site only).
  - `-NP` = no paint.
  - `-Z` = an assembly of parts the laser, press and fabricator never touch.
  - Welded (`F`) parts are painted with their kit.
  - Lesson: my guess that `N` meant "non-metal" was wrong; it means straight cut. **Mark inferred meanings as such until someone confirms them.**
- **The colour codes are defined only in the DriveWorks `Colors` group table**, not in the SOLIDWORKS repo.
- **Shipping-split logic exists only in DriveWorks project variables** (`NumberOfShippingAssy*`, `SameShippingAssy*`). The SOLIDWORKS macros have none.
- **Work-order numbering:** the `ClientProjects` group table (1,439 rows) is the best source for mapping WO number to WO prefix.

---

## 2026-09-23: Captures, model rules, and the typical workflow

### From the user
- Typical change: **edit SOLIDWORKS features and dimensions → capture them with the DriveWorks add-in → create variables and assign rules to the captured items in Administrator.**
- Deployment later means **Copy Group over `SPA-DWP`**, after heavy testing. The server is 24.0.3. The Administrator license is per computer, and this PC is licensed.

### DriveWorks facts
- **`CapturedComponents.Data` is XML** (namespace `c-component`): `C` → `E` (element/feature) → `P` (parameter). `N` = DriveWorks name, `A` = SOLIDWORKS name (`CageHeight@Sketch1`), `T` = type id, `S` = feature type or format. `ReferenceData` = child capture GUIDs, concatenated.
- The type ids are string literals in `DriveWorks.SolidWorks.Components.Constants` (`ID_PARAM_TYPE_DIMENSION`, ...). Reflection over static fields **didn't** find them, because the static constructor doesn't run. **Scanning the `.cctor` IL for `ldstr` → `stsfld` did.** The same technique works for any DriveWorks constant.
- The project `components/<n>.xml` mirrors the capture: `PC`↔`C` (`CCRef`), `PE`↔`E` (`CERef`), `PP`↔`P` (`CPRef`). A newly captured parameter has **no `PP` until it gets a rule**.
- Slot meanings were confirmed from the serializer class names in `DriveWorks.Engine.dll`: `CN` = `ComponentNameElement`, `CP` = `ComponentPathElement`, `CT` = `ComponentTagsElement`, `LC` = `LoopCountElement`.
- `GroupDataTables.TableData` = **raw deflate** over delimited text.
- The API has writable model rules (`DriveWorks.Components.ProjectComponentRule.Rule`) and capture management (`DriveWorks.GroupCapturedComponents`).
- 52 model rules reference captures that are no longer in the group, and 32 reference missing parameter ids. These are probably stale, from re-captures.

---

## 2026-09-23: Project kickoff

### DriveWorks facts
- `.driveprojx` = OPC package of XML. `.drivegroup` = SQLite (current) **or** SQL CE 4.0 (legacy). Details are in [formats/](formats/).
- **Round-trip is lossless.** `System.IO.Packaging` + `XmlDocument` with `PreserveWhitespace = $true` + `XmlWriter` with the original BOM and newline style reproduces every part of all 23 project files byte for byte. Evidence: `tools/tests/Test-DwRoundTrip.ps1`.
- Variables and constants live in **`designMaster.xml`**, not `project.xml`. Their rules have no leading `=`. Control and component rules in the other parts **do** start with `=`.
- Rules reference variables by store name, `DWVariable<Name>`, and controls by bare name. Renaming via XML means rewriting every reference, so leave renames to the API or Administrator.
- Component XML `CCRef` = `CapturedComponents.Id` in the group DB (without dashes). 10,206 of 10,216 references resolved.
- The DriveWorks engine exposes an authoring API: `Project.Variables.CreateVariable`, `ProjectVariable.Rule` (read/write), `Project.CreateRenameProcess`, and `Project.Save()`. The assemblies load in PowerShell 5.1.
- Rules hard-code `C:\Sparta SW Vault\Driveworks\...` paths: 16 hits in Hopper and Platform. That's a PDM vault view.
- The package contained a stray empty `.git` folder and a `.github/copilot-instructions.md` about form CSS. It was ported to the `driveworks-form-css` skill.

- **Forms and controls use a default XML namespace**, `pa-namespace:DriveWorks.Forms,DriveWorks.Engine`, so un-prefixed XPath silently returns nothing. `Select-DwXml` registers `f:` and the other prefixes. A first draft of the tools README had this exact bug.
- `IsStatic="True"` control properties never contain `<Rule>` (0 of 69,087).
- Group DB GUIDs are **16-byte blobs in .NET byte order**. A naive `WHERE Id = '...'` or `lower(Id)` never matches. Use `Get-DwCapturedComponent`, or compare `hex(Id)` against `[guid]::ToByteArray()`.
- The local sandbox group `Sparta DW Group for Claude.drivegroup` was set up by the user, with its content folder set to `DriveWorks Files`. **Credentials are provided per session. Never store them.**

### Tooling gotchas (PowerShell 5.1)
- **Function output unrolls.** A function returning an `XmlNodeList` with 0 or 1 items gives `$null` or a single node, so `.Count` and `[0]` break under StrictMode. Wrap calls in `@(...)`.
- **The `[xml]` adapter shadows properties.** On an element that has a `Name` attribute, `$node.Name` returns the *attribute*, not the element name. Use `$node.LocalName` and `$node.GetAttribute('Name')`.
- **Paths containing `[` `]`**, like `[Content_Types].xml`, are wildcards to `-Path`. Always use `-LiteralPath`.
- **Variables are case-insensitive.** `$s` silently overwrote `$S`. Use distinct names.
- **`-WhatIf` propagates** into every cmdlet the function calls, so internal temp-file work needs `-WhatIf:$false`.
- `Get-Content -Raw` fails with the "parameter not found" error if the path doesn't resolve, which is misleading. It's the wildcard issue above.
- DriveWorks' SQLite interop is x64 only, so use 64-bit PowerShell.
- Files that come out of PDM checked-in are **ReadOnly**. `Copy-Item` preserves that, so clear it on temp copies.
- `Find-DwRule` over 19 projects takes about 30 s (XPath over every attribute). Pre-filtering the raw text would speed it up, but watch out for XML entities and regex anchors.
