---
name: driveworks-group-db
description: Query DriveWorks .drivegroup group databases (SQLite, or legacy SQL CE) read-only - registered projects, group settings and version, captured models, group tables. Use when a task needs to know what the group contains, how projects are registered, or which captured model a project component refers to.
---

# Reading DriveWorks group databases

The reference is `docs/formats/drivegroup.md`. **Read-only, always.** Never open a `.drivegroup` for writing, and never run `INSERT`/`UPDATE`/`DELETE`. Group changes go through DriveWorks Administrator.

```powershell
Import-Module .\tools\DwTools\DwTools.psm1 -Force
$g = '.\DriveWorks Files\Sparta DW Group for Claude.drivegroup'   # the local sandbox group

Get-DwGroupFormat  $g        # SQLite | SqlCe40 | Unknown  (only SQLite is queryable)
Get-DwGroupProject $g        # Name, Directory, Hidden, Deployed, Id
Get-DwGroupTable   $g        # tables + row counts
Invoke-DwGroupQuery $g "SELECT Name, Value FROM GroupSettings"
```

## Common questions

| Question | Query |
|---|---|
| Group content folder and version | `SELECT Name, Value FROM GroupSettings UNION ALL SELECT Name, Value FROM GroupProperties` |
| Which model is component `CCRef=abc...`? | `Get-DwCapturedComponent $g -Id abc...`. **Don't hand-write SQL for ids.** They're 16-byte blobs in .NET `Guid` byte order, so string comparison never matches. |
| Captured models for one project folder | `Get-DwCapturedComponent $g -Path '*\Ladder\*'` |
| Group tables | `SELECT Name, TypeName FROM GroupDataTables` (the data itself is a binary blob) |

## Rules

- Blob columns come back as `<blob N bytes>`. Their format is unknown, so don't try to decode them without a plan.
- The `Security*` tables hold user and credential data. Don't print them into docs, logs, or chat beyond what the task needs.
- Group credentials are given per session. Read them from `$env:DW_GROUP_USER` and `$env:DW_GROUP_PASSWORD`, and **never write them to a file**.
- Automation opens only the **sandbox** group. It never connects to Pro Server `SPA-DWP` unless the user explicitly says so for that task.
