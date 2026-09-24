# Sparta DriveWorks environment

*As observed on 2026-09-23. Update this when things change.*

## Servers and storage

| What | Where |
|---|---|
| Production group | `Sparta Manufacturing Group` on **DriveWorks Pro Server `SPA-DWP`**. Some projects use the `http://SPA-DWP:54380` endpoint form. |
| CAD and DriveWorks content | **SOLIDWORKS PDM** vault `Sparta SW Vault`, local view `C:\Sparta SW Vault\`, server `SPA-PDM`. A second vault, `Sparta Vault 2026`, is also registered. |
| Local sandbox | `DriveWorks Files/Sparta DW Group for Claude.drivegroup`, with the content folder set to `DriveWorks Files/`. **This is the only group automation may open.** |

Files that come out of PDM in a checked-in state are **read-only**, like the `Restored Files` copies. `Edit-DwProject` refuses in-place edits on read-only files.

## Deployment (confirmed 2026-09-23)

- **Nothing goes to production for now.** All work stays in the sandbox group.
- Later, the sandbox group gets **copied over the `SPA-DWP` group with DriveWorks' Copy Group tool**, after heavy testing shows the changes don't break or affect anything they shouldn't. The user does this manually. A migration system comes after that.
- Copy Group **overwrites** the server group. Server-side changes made since the snapshot would be lost unless they're frozen or re-synced first.

## License

DriveWorks Administrator licenses are **one per computer. This PC is licensed**, so scripted API use here is covered.

## Local software

| Software | Details |
|---|---|
| DriveWorks | **24.0.1.4** (current) and 22.2.1.76, in `C:\Program Files\DriveWorks\<version>\` |
| DriveWorks PowerPacks | SOLIDWORKS, Specification, Image, CAMWorks, SOLIDWORKS CAM, Salesforce, SYSPRO, Azure, PDF, PDM Professional integration |
| SOLIDWORKS | Installed |
| Windows PowerShell 5.1 | **The tooling runtime.** .NET Framework 4.8, so it can load DriveWorks assemblies directly. |
| Node 24, git | Available |
| Python | **Not installed.** Only the Microsoft Store alias exists. |
| .NET | Runtime only, **no SDK**. C# builds would need the SDK plus the .NET Framework 4.8 targeting pack. |

## Versions

| Thing | Version |
|---|---|
| Group schema (`GroupProperties`) and **Pro Server `SPA-DWP`** | 24.0.3 (server confirmed). The local install is 24.0.1.4, which is a skew to resolve before any Copy Group. |
| Project file format (`Version` attribute) | 14.0 for everything except `Web Kit Conveyor` (10.0) |
| Local Administrator | 24.0.1.4 |
| `.github/copilot-instructions.md` in the package | Says "DriveWorks Pro 23". This is probably out of date. |

## Credentials

Group credentials are provided by the user **per session**. Scripts read them from environment variables (`DW_GROUP_USER`, `DW_GROUP_PASSWORD`). **Never write them to files, docs, commits, or memory.**
