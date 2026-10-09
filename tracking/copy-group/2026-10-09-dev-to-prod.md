# Release 2026-10-09: dev → prod (all projects)

*Prepared by Claude on 2026-10-09. The user runs the Copy Group. The baseline is the last production copy, export `2026-10-06` (`snapshots/2026-10-06`). The diffs are in `work/release-2026-10-09/` (`project-diffs.csv`, `group-diffs.csv`).*

## Done: the first dev → prod push

- **When:** 2026-10-09, **between 13:03 and 13:12 (−03:00)**.
  - The configuration was saved from the summary page at 13:03:27.
  - Data Management closed at 13:11:44.
- **Rollback point:** restore production from an archive taken **before 2026-10-09 13:03**.
  - The prod project files from before the push are in `snapshots/2026-10-06`.
  - The files as pushed are in `snapshots/2026-10-09-release`.
- **The user ran it as one Copy Group** of all 18 projects, from the dev group to `\\192.168.0.19\Driveworks Input Files`.
  - **Components:** all components of the selected projects, auto-selected.
  - **Not copied:** group tables, security, specifications, reports, tasks, release data, connectors and rule history.
  - **Excluded:** `Specifications`, `Restored Files`, `Sparta Website Configurator`, `.git`, `.github` and the dev group file.
  - **Configuration:** [`Copy Group Specification/2026-10-09 - Copy Group Specification.xml`](../../Copy%20Group%20Specification/2026-10-09%20-%20Copy%20Group%20Specification.xml). The two-run plan files beside this note weren't used.
- **Logged** in [`tracking/releases.json`](../releases.json) (`Register-DwRelease`), with the SHA-256 of every pushed project file.
  - The 8 released fixes are now `verified`.
  - The new baseline export is `2026-10-09-release`.
- **The user checked prod after the copy:** it looks good.
- **Because components were auto-selected for all projects, two things below "Left out on purpose" probably went too:**
  - the re-saved Hopper V2 masters. CAI03 built from them exactly like CAI01 from the old ones, so a change isn't expected; HV2-19 in [things-to-test](../../docs/things-to-test.md) checks it.
  - the DW02-A50 capture with 5 references. Item `picking-dw02-a50-capture-refs`, PC-1 in things-to-test.

## What production gets

| Project | Changes since the 2026-10-06 production copy | Tracked items |
|---|---|---|
| DW Hopper V2 | Constant `PanelMinHeight` = 4. `DropZonePanelList.Enable` drops side panels thinner than it. `DZLengthRight`/`DZLengthLeft` stop the drop zone where the top cut reaches 4 in, rounded down to whole feet. Dev Release rule | `hopper-v2-min-panel-height`, `hopper-v2-topcut-limit`, `dev-release-forced-in-dev` |
| DW Hopper V2 - Panels | `SWFileLocation` and `DWSpecificationPath` pad the spec id with `Text(…,"0000")`, like V2; no change for ids ≥ 1000. Dev Release rule | `hopper-v2-spec-id-format`, `dev-release-forced-in-dev` |
| DW Apron Project | The user's V2 shipping-assembly rework (SA1–SA7 driven by SectionLayout, re-captured slots −1 to −38), `MidSectionA21toA28Length` without a top elbow, the chain holder after an elbow, form size. Dev Release rule. **Needs its components** (the re-captured `Apron Conveyor Assembly V2` and the Apron models changed on 10-06) | `apron-v2-shipping-assemblies`, `apron-top-run-without-top-elbow`, `apron-chain-holder-after-elbow`, `dev-release-forced-in-dev` |
| Light Duty Conveyor | Leg position sliders LegA40–A44 step 0.01 in. Dev Release rule | `light-duty-leg-position-increment`, `dev-release-forced-in-dev` |
| 12 others: Hopper (original), Kit Conveyor, Picking Conveyor, Start Leg, Ladder, Stairs, Platform Layout, Straight, Picking, Bolts, HandRails, HandRails outside | Dev Release rule only. Platform - Picking also has its form size | `dev-release-forced-in-dev` |
| DW Order, DW Select | none (identical) | |

The Dev Release rule is `If( DWVariableIsProductionEnvironment = FALSE ,TRUE ,<the previous rule>)`. In production, `GetGroupName()` = "Sparta Manufacturing Group" gives `IsProductionEnvironment` TRUE, so the previous rule applies unchanged.

## Checks run on 2026-10-09

- **Every fix applied in dev passes its check:** the 7 `fixed-in-dev` items plus `dev-release-forced-in-dev`. The failing checks are open issues, not part of this release.
- **The environment is detected correctly:** "Sparta Manufacturing Group" → TRUE, "Sparta DW Group for Claude" → FALSE, and an unknown group → FALSE.
  - Production has resolved its paths through the same `Environments` row since 2026-10-06: spec 46203 rev 7 was released to `J:\ARD1653-Hopper 46203`.
- **All 18 projects pass `Test-DwProject`,** and no rule contains a dev path.
- **The dev spec folder stored by Apron and Platform - Picking (`DWSpecificationDefaultFolder`) is harmless.** DriveWorks replaces it at run time: Hopper V2 stores the prod path, yet its dev specs went to the dev folder.
- **Production's Hopper V2 hadn't changed by 10-08:** the 46203 rev 7 copy differs from the baseline only in the spec's values. Other projects can't be checked from here.

## Left out on purpose

- **The Hopper V2 master models.** 834 files in `Hopper\Models V2` were re-saved on 2026-10-09 between 10:23 and 10:43, between two test generations, with no capture change. Nothing in this release needs them.
- **The `DW02-A50` capture (Picking Conveyor).** In dev it was "re-captured" on 10-06 with the same data but 5 child references instead of 6. Its path is `Elbow Section\`, while the dev file is in `ElbowSection\`. That looks accidental, so production keeps its own.
- **Group tables:**
  - `ClientProjects` has 13 test rows;
  - `Environments` is unchanged;
  - the others are unchanged.
- **Security** (the ClaudeAI user), **specifications** (CAI and JA tests), reports, tasks, release data and **rule history** (661 dev revisions).

## Not in this release (still open or waiting)

- `hopper-v2-dropzone-length-limits`: the user enters the limits in Administrator.
- `hopper-v2-panels-flange-dim-duplicate`: Picking should get 1.0625. Answered, not yet applied.
- `hopper-v2-inx0sidepanel`: the fix is waiting for approval and a test (CAI05).
