# DriveWorks Automation

Tooling and knowledge base for automating changes to Sparta's DriveWorks projects.

- **Why this approach:** [docs/analysis/api-vs-xml.md](docs/analysis/api-vs-xml.md) explains the choice between the DriveWorks API and direct project-file edits.
- **Tools:** [tools/README.md](tools/README.md) documents the `DwTools` PowerShell module (read, search, and safely edit `.driveprojx`; query `.drivegroup` read-only).
- **Docs:** [docs/README.md](docs/README.md) covers file formats, environment, inventory, and the learnings log.
- **Claude skills:** [.claude/skills/](.claude/skills/) holds reusable procedures for DriveWorks work in Claude Code.

## Quick start

```powershell
Import-Module .\tools\DwTools\DwTools.psm1 -Force
Get-DwProjectSummary '.\DriveWorks Files' | Format-Table Project, Variables, Constants, Forms, Controls
Find-DwRule 'DWVariableWorkOrder' '.\DriveWorks Files' | Format-Table Project, Location
```

`DriveWorks Files/` (the group snapshot, 3.3 GB) is git-ignored. Copy it in from the `.drivepkg`, or use `Expand-DwPackage`.
