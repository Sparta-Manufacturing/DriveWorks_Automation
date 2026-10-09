# Issues

*Generated from [tracking/items.json](../tracking/items.json) by `Update-DwIssueDocs`. Do not edit by hand.*

Every project's known issues are in its own `docs/projects/<project>/issues.md`. This page counts them and lists the issues that span several projects.

Statuses: **open** (a problem, not fixed anywhere), **recommended** (a fix proposed), **fixed-in-dev** (applied in `DriveWorks Files`, waiting for production), **verified** (the check passes on a production export), **closed** (dropped).

| Project | open | recommended | fixed-in-dev | verified | closed |
|---|---|---|---|---|---|
| [DW Apron Project](projects/apron/issues.md) | 10 | 1 | 0 | 6 | 0 |
| [DW Hopper V2](projects/hopper-v2/issues.md) | 9 | 1 | 0 | 3 | 0 |
| [DW Hopper V2 - Panels](projects/hopper-v2-panels/issues.md) | 8 | 1 | 0 | 0 | 0 |
| [DW Hopper Project (original)](projects/hopper/issues.md) | 2 | 0 | 0 | 0 | 0 |
| [DW Kit Conveyor Project](projects/kit-conveyor/issues.md) | 2 | 0 | 0 | 0 | 0 |
| [Light Duty Conveyor](projects/light-duty-conveyor/issues.md) | 3 | 0 | 0 | 1 | 0 |
| [DW Picking Conveyor Project](projects/picking-conveyor/issues.md) | 4 | 0 | 0 | 0 | 0 |
| [DW Start Leg](projects/start-leg/issues.md) | 1 | 0 | 0 | 0 | 0 |
| [DW Ladder](projects/ladder/issues.md) | 2 | 0 | 0 | 0 | 0 |
| [DW Stairs Project](projects/stairs/issues.md) | 3 | 0 | 0 | 0 | 0 |
| [DW Platform Layout, DW Platform Bolts](projects/platform-layout/issues.md) | 6 | 0 | 0 | 0 | 0 |
| [DW Platform - Straight](projects/platform-straight/issues.md) | 2 | 0 | 0 | 0 | 0 |
| [DW Platform - Picking](projects/platform-picking/issues.md) | 2 | 0 | 0 | 0 | 0 |
| [DW HandRails](projects/handrails/issues.md) | 2 | 0 | 0 | 0 | 0 |
| [DW HandRails outside](projects/handrails-outside/issues.md) | 4 | 0 | 0 | 0 | 0 |
| [DW Order Project](projects/order/issues.md) | 3 | 0 | 0 | 0 | 0 |
| [DW Select Project](projects/select/issues.md) | 0 | 0 | 0 | 0 | 0 |
| [Web Kit Conveyor](projects/web-kit-conveyor/issues.md) | 0 | 0 | 0 | 0 | 0 |

## Cross-project issues

### env-no-hardcoded-prod-locations

**All projects take production/dev locations (input files, output files, SQL server) from the Environments group table, not hard-coded \\192.168.0.19 or personal paths; costing/quoting emails go to the logged-in user outside prod**

- **Status:** open; **Priority:** high; **Raised:** 2026-10-05
- **Check:** [checks/env-no-hardcoded-prod-locations.ps1](../tracking/checks/env-no-hardcoded-prod-locations.ps1)
- **Notes:** Decision 2026-10-05: dev stays the individual group in DriveWorks Files; one Environments group table with a row per group (keyed by GetGroupName()); one base variable per project that tells prod from dev. Check covers all projects (the project field only locates the export root).
- **History:**
  - 2026-10-06: open (export 2026-10-06). Prod has the Environments table, IsProductionEnvironment and 48 of the 49 rule changes; the lookups give prod values as Sparta Manufacturing Group and dev values as Sparta DW Group for Claude (engine check). Left: Kit Conveyor EmailToCustomerCAD attachment (#15). Email recipients on hold by decision.

### sql-export-plaintext-logins

**Seven SQL export documents in five projects store their login in plain text**

- **Status:** open; **Priority:** high; **Raised:** 2026-10-02
- **Check:** none (checked by hand)
- **Notes:** Kit Conveyor (DWKitConveyorData, EquipmentListExport), Platform Layout (DWPlatformLayoutData, EquipmentListExport), Order (ProjectListExport), Select (AddNewTeamInSQL), Hopper (EquipmentListExport). Same password in all. Never copy the values anywhere; refer to them by document name.

### generation-date-property-assemblies

**The Date custom property fails on every generated assembly (Failed to drive in configuration '')**

- **Status:** open; **Priority:** low; **Raised:** 2026-10-09
- **Check:** none (checked by hand)
- **Notes:** Sandbox generation log: 572 times on the user's Apron runs (JA01), 16 per Hopper V2 test spec; parts take it. Assemblies keep the Date saved in the master. Check whether drawings or BOMs read it before fixing (the assembly capture likely drives a file-level property the assemblies do not have).

### dev-release-forced-in-dev

**Dev Release is forced on outside production (all 16 projects with the check box)**

- **Status:** verified; **Priority:** high; **Raised:** 2026-10-09
- **Check:** [checks/dev-release-forced-in-dev.ps1](../tracking/checks/dev-release-forced-in-dev.ps1)
- **Notes:** User decision 2026-10-09: ClaudeAI stays a plain Engineering user. DevRelease Checked rule becomes If( DWVariableIsProductionEnvironment = FALSE ,TRUE ,<the project's current rule>). In prod nothing changes: Hopper V2, Panels, Kit, Stairs and Light Duty still require the Developement team; the 11 others follow the box. Dev group has no Autopilot, so a dev release must always be local.
- **History:**
  - 2026-10-09: fixed-in-dev. Applied in all 16 projects on 2026-10-09 (ledger); the check passes: forced on in dev, the previous rule in prod (Sparta Manufacturing Group -> IsProductionEnvironment TRUE). In the 2026-10-09 dev -> prod release.
  - 2026-10-09: verified (export 2026-10-09-release). In production with the first dev -> prod release (2026-10-09 13:03-13:12 -03:00, tracking/releases.json): the check passes on the project files that were pushed; the user checked prod after the copy.

### project-edition-2026-08

**Every project on project edition 2026-08 (Project Settings > Project edition)**

- **Status:** verified; **Priority:** low; **Raised:** 2026-10-06
- **Check:** [checks/project-edition-2026-08.ps1](../tracking/checks/project-edition-2026-08.ps1)
- **Notes:** Decision 2026-10-06: the user accepts the 2026-08 date-to-text behaviour (dates without time use invariant formatting instead of regional). Affects Today() drawing properties (HandRails outside, Apron and HandRails Date variables) and Order Project date texts. Done by the user in prod Administrator, per project; arrives in dev with the next Copy Group. Check covers all registered projects.
- **History:**
  - 2026-10-06: verified (export 2026-10-06). All 18 projects on edition 2026-08 (Edition="260800").
