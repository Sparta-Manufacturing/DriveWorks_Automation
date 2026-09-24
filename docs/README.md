# Docs

| Doc | What's in it |
|---|---|
| [analysis/api-vs-xml.md](analysis/api-vs-xml.md) | **Decision record:** DriveWorks API vs. editing project XML. Recommendation, evidence, roadmap, open questions. |
| [engineering-process.md](engineering-process.md) | **How Sparta designs product:** work orders and vault layout, the naming convention (A/K/Z/SA tokens, part codes, colour codes), kits, shipping assemblies, part classes, what each department gets, sheet-metal standards, open questions |
| [environment.md](environment.md) | Sparta servers (Pro Server, PDM), installed versions, local tooling, credential handling |
| [inventory.md](inventory.md) | *Generated.* Every project and group with counts. Regenerate with `tools/scripts/Update-DwInventory.ps1`. |
| [formats/driveprojx.md](formats/driveprojx.md) | Project file internals: parts, forms and controls, variables, rules, components |
| [formats/drivegroup.md](formats/drivegroup.md) | Group database: SQLite vs. SQL CE, schema, why it's read-only |
| [formats/captured-models.md](formats/captured-models.md) | How SOLIDWORKS captures in the group connect to model rules in the project. Includes the type-id table. |
| [formats/other-formats.md](formats/other-formats.md) | `.drivepkg`, `.driveprot`, `.drivesft`, CSS |
| [learnings.md](learnings.md) | Dated log of discoveries and gotchas. **Append here first.** |

Reusable procedures for Claude live as skills in [`../.claude/skills/`](../.claude/skills/). The tools are in [`../tools/`](../tools/README.md).
