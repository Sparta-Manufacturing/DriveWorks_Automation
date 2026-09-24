# `.drivegroup`: DriveWorks group database

> Reverse-engineered, not official. **Treat these files as read-only.** Change group data in DriveWorks Administrator.

## Two storage engines behind one extension

| Engine | How to recognise it | Files in the Sparta snapshot |
|---|---|---|
| **SQLite 3** (current) | Header starts with `SQLite format 3\0` | `Sparta DW Group for Claude.drivegroup` (sandbox), `Sparta Manufacturing Group.drivegroup` (inside the package) |
| **SQL Server Compact 4.0** (legacy) | UInt32 at byte offset 16 = `0x003D0900` | `Sparta Manufacturing Group Single.drivegroup`, `Sparta Website Configurator/Sparta Website Group.drivegroup` |

`Get-DwGroupFormat` tells them apart. `Invoke-DwGroupQuery` reads SQLite only, using **DriveWorks' own** `System.Data.SQLite.dll` (x64) from the install folder, opened read-only. SQL CE needs `System.Data.SqlServerCe`, which isn't installed. Open or upgrade those groups in Administrator.

## SQLite schema (group version 24.0.3), non-empty tables

| Table | Rows (sandbox) | What it holds |
|---|---|---|
| `Projects` | 18 | `Id`, `Name`, `Extension`, `Directory` (absolute path), `Hidden`, `Deployed`. **This is only a registry.** The project content lives in the `.driveprojx` file. |
| `CapturedComponents` | 3,658 | `Id`, `Path` (absolute model path), `Type` (`PartFactory`, `AssemblyFactory`, `DrawingFactory`), `Version`. **`Data` is XML**: the captured dimensions, features, custom properties, and so on. **`ReferenceData`** is the child capture ids as concatenated GUIDs. See [captured-models.md](captured-models.md). Project component XML refers to these by `CCRef` = `Id` without dashes. Use `Get-DwCapturedComponent` and `Get-DwModelRule`. |

> **GUID storage:** `uniqueidentifier` columns are **16-byte blobs in .NET `Guid.ToByteArray()` order**, with the first three groups byte-swapped. For example, `48496ae0-ee8c-4327-...` is stored as hex `E06A49488CEE2743...`. Compare with `hex(Id) = '<converted>'`. `Get-DwCapturedComponent` does this for you.
| `GroupDataTables` | 6 | Group tables (`Colors`, `Material`, `ClientProjects`, `StairTreads`, `HelicalBevelNordGearbox`, `Bracing`). `TableData` is **raw deflate** (`DeflateStream`) over delimited text: a header row, then rows. The separators are control characters, not yet mapped. `MetaData` is empty in the sandbox. |
| `GroupSettings` | 3 | `GroupContentFolder`, `DefaultSpecificationFolder`, `FeatureDriveCompatibility` |
| `GroupProperties` | 3 | `GroupVersionMajor`/`Minor`/`Revision` |
| `SecurityUsers`, `SecurityTeams`, `SecurityTeamUsers`, `SecurityTeamProjects`, `SecurityTeamGroupDataTablePermissions` | | Users, teams, and per-project and per-table permissions. **Contains credentials data. Don't dump it into docs or logs.** |

Empty in the snapshot, but present: `Specifications*`, `Reports*`, `DrivenComponent*`, `RuleRevisions` (rule version history), `DriveApps`, `SecurityRoles*`, `Connectors`.

## Why we don't write to it

- The blobs are **readable** (capture XML, deflated table text), but DriveWorks owns their consistency. A capture must match the real SOLIDWORKS file, and only the DriveWorks add-in can guarantee that.
- Absolute paths and GUIDs cross-reference the project files and the model files.
- DriveWorks keeps security and version bookkeeping here.
- Administrator itself can do everything we'd need here: re-point the content folder, add or remove projects, and edit tables.

## Useful queries

```powershell
Get-DwGroupProject  $g                                        # registered projects
Get-DwGroupTable    $g                                        # tables + row counts
Invoke-DwGroupQuery $g "SELECT Name, Value FROM GroupSettings"
Invoke-DwGroupQuery $g "SELECT Type, COUNT(*) n FROM CapturedComponents GROUP BY Type"
Get-DwCapturedComponent $g -Id 48496ae0ee8c43278bee9715b584668e   # a CCRef from components/<n>.xml
Get-DwCapturedComponent $g -Path '*\Ladder\*'
```
