# Docs

| Doc | What's in it |
|---|---|
| [analysis/api-vs-xml.md](analysis/api-vs-xml.md) | **Decision record:** DriveWorks API vs. editing project XML. Recommendation, evidence, roadmap, open questions. |
| [engineering-process.md](engineering-process.md) | **How Sparta designs product:** work orders and vault layout, the naming convention (A/K/Z/SA tokens, part codes, colour codes), kits, shipping assemblies, part classes, what each department gets, sheet-metal standards, open questions |
| [projects/apron.md](projects/apron.md) | DW Apron Project: when each section exists, how run lengths are split into sections, where the 10 ft max is hard-coded, the current shipping-assembly layout, known issues |
| [projects/inputs/kit-conveyor-inputs.md](projects/inputs/kit-conveyor-inputs.md) | DW Kit Conveyor Project: every form input with its description, form page, limits and defaults, and what it changes in the conveyor's size or position in a layout. Written for the pre-sales layout app. |
| [projects/inputs/stairs-inputs.md](projects/inputs/stairs-inputs.md) | DW Stairs Project: the same input table for the stairs. Height, horizontal run and width formulas, railing heights, connection types, and the rules between inputs. Written for the pre-sales layout app. |
| [projects/inputs/ladder-inputs.md](projects/inputs/ladder-inputs.md) | DW Ladder: the same input table for the caged rung ladder. Height and rung formulas, cage start and end, railing height, platform brackets, and the gate. Written for the pre-sales layout app. |
| [projects/inputs/light-duty-conveyor-inputs.md](projects/inputs/light-duty-conveyor-inputs.md) | Light Duty Conveyor: the same input table, with how it differs from the Kit Conveyor (pulleys, side walls, belts, shipping split) and the bugs found. Written for the pre-sales layout app. |
| [projects/inputs/start-leg-inputs.md](projects/inputs/start-leg-inputs.md) | DW Start Leg (the Legs project): the same input table, plus how Kit Conveyor and Light Duty host it as a child spec and which value each conveyor sends to each leg input. Written for the pre-sales layout app. |
| [projects/inputs/picking-conveyor-inputs.md](projects/inputs/picking-conveyor-inputs.md) | DW Picking Conveyor Project: the same input table for the picking conveyor. Length breakdown, frame depth, elbow, pull cord, how it differs from the Kit Conveyor, and the block model. Written for the pre-sales layout app. |
| [projects/inputs/apron-inputs.md](projects/inputs/apron-inputs.md) | DW Apron Project: the same input table for the apron. The four profiles, run lengths and angles, width and drive position, oiler/ski/E-stop/logo positions, and the bugs found. Complements [projects/apron.md](projects/apron.md). Written for the pre-sales layout app. |
| [projects/inputs/platform-layout-inputs.md](projects/inputs/platform-layout-inputs.md) | DW Platform Layout, the parent of all platform projects: its own inputs, how it hosts Straight/Picking, the capture tables and release loops, what it sends to each child (Straight, Picking, both HandRails, Bolts), how SAs, bolts and railings are placed, and the SQL feed. Written for the pre-sales layout app. |
| [projects/inputs/platform-straight-inputs.md](projects/inputs/platform-straight-inputs.md) | DW Platform - Straight: the rectangular platform hosted by Platform Layout. Its inputs with what Layout sets, the `ListToPlatform` row it sends back, zones and connections, floor, and size limits. Written for the pre-sales layout app. |
| [projects/inputs/platform-picking-inputs.md](projects/inputs/platform-picking-inputs.md) | DW Platform - Picking: the platform with a picking hopper (bin), hosted by Platform Layout. The same structure as Straight, plus the bin inputs and the differences. Written for the pre-sales layout app. |
| [projects/inputs/handrails-inputs.md](projects/inputs/handrails-inputs.md) | DW HandRails: the inside railing or kick plate for one platform zone, hosted by Platform Layout. Inputs, what Layout sends, post spacing, height, corners, and the Railing/Handrail mismatch. Written for the pre-sales layout app. |
| [projects/inputs/handrails-outside-inputs.md](projects/inputs/handrails-outside-inputs.md) | DW HandRails outside: the outside guard-panel railing with a separate handrail, hosted by Platform Layout when Outside Railing is on. Inputs, what Layout sends, heights, inside and outside corners, and the differences from DW HandRails. Written for the pre-sales layout app. |
| [projects/inputs/platform-bolts-inputs.md](projects/inputs/platform-bolts-inputs.md) | DW Platform Bolts: the on-site bolt set between two platforms in different SAs, and what Platform Layout sends it. Written for the pre-sales layout app. |
| [environment.md](environment.md) | Sparta servers (Pro Server, PDM), installed versions, local tooling, credential handling |
| [inventory.md](inventory.md) | *Generated.* Every project and group with counts. Regenerate with `tools/scripts/Update-DwInventory.ps1`. |
| [formats/driveprojx.md](formats/driveprojx.md) | Project file internals: parts, forms and controls, variables, rules, components |
| [formats/drivegroup.md](formats/drivegroup.md) | Group database: SQLite vs. SQL CE, schema, why it's read-only |
| [formats/captured-models.md](formats/captured-models.md) | How SOLIDWORKS captures in the group connect to model rules in the project. Includes the type-id table. |
| [formats/other-formats.md](formats/other-formats.md) | `.drivepkg`, `.driveprot`, `.drivesft`, CSS |
| [learnings.md](learnings.md) | Dated log of discoveries and gotchas. **Append here first.** |

Reusable procedures for Claude live as skills in [`../.claude/skills/`](../.claude/skills/). The tools are in [`../tools/`](../tools/README.md).
