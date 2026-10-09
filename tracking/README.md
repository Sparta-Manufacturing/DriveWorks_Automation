# Export tracking

`DriveWorks Files` is the dev copy of production. You refresh it by running **Copy Group** from `SPA-DWP` in DriveWorks Data Management, and each refresh overwrites everything, including our dev edits. This folder records what was there before, what we changed in between, and what we asked for. That way, the review of the next export can say what production picked up, even when it was fixed a different way.

| File | What |
|---|---|
| `exports.json` | Every registered export: id, date, source, file sizes and SHA-256, its snapshot folder and its review. |
| `releases.json` | Every **dev → prod** Copy Group the user ran: start and end time (the **rollback point**: restore production from an archive taken before the start), the configuration file, projects, components and options, the SHA-256 of each pushed project file, and the items it released. Written by `Register-DwRelease`. |
| `copy-group/` | Copy Group configurations: the prod → dev copies, and the release notes of each dev → prod push (what it carries, the checks, what was left out). The user saves each push's own configuration in `Copy Group Specification/` (repo root). |
| `ledger.jsonl` | One line per write to a project in `DriveWorks Files`. `Edit-DwProject` appends it automatically: time, project, parts, semantic changes, tracked item, reason, backup and the file's new hash. |
| `items.json` | Issues and fixes we discussed: status, priority, notes, history, and a behaviour **check**. |
| `checks/*.ps1` | One check per item. Each runs DwFormEngine or reads the XML, and returns `Pass` when the problem is gone, however it was fixed. |
| `reviews/<date>.md` | The review of each export: summary, file changes, diff counts, dev changes it overwrote, and item check results. |
| `../snapshots/<id>/` | Copies of every project and group file of each export. Git-ignored, about 90 MB each. |

Item statuses:
- `open`: a problem, not fixed anywhere.
- `recommended`: a fix proposed, not in production.
- `fixed-in-dev`: applied in `DriveWorks Files`, waiting for production.
- `verified`: the check passes on a production export.
- `closed`: dropped.

## The hook

`.claude/settings.json` runs `tools/scripts/Test-DwExportChanged.ps1 -Hook` at **SessionStart** and on every **UserPromptSubmit**, which takes about 1.5 s. When a project or group file no longer matches the last registered export, and the change wasn't one of our logged edits, the hook shows you a message. It also tells Claude to run the review. It reports each distinct change only once. Run the script without `-Hook` for a readable report.

It also catches edits made in DriveWorks Administrator on the sandbox. Review those the same way.

## After a re-export (Claude does this when the hook fires)

```powershell
Import-Module .\tools\DwTools\DwTools.psm1, .\tools\DwTools\DwFormEngine.psm1, .\tools\DwTools\DwTracking.psm1 -Force
Invoke-DwExportReview                 # writes tracking/reviews/<today>.md, full diffs in work/export-review-<today>/
# read it, investigate, write the Summary section, then:
Set-DwTrackingItemStatus -Id <id> -Status verified -Export <today> -Note '...'
Register-DwExport -Id <today> -Note '...' -Review tracking/reviews/<today>.md
```

## Releasing dev → prod (the user runs the Copy Group)

1. **Claude prepares it:**
   - each project in dev against the last production copy (`Compare-DwProjectContent`, `Compare-DwGroupContent`);
   - every check;
   - the settings, and what to leave out;
   - a release note in `copy-group/<date>-dev-to-prod.md`.

   See [docs/analysis/dev-prod-workflow.md](../docs/analysis/dev-prod-workflow.md).
2. **The user runs Copy Group** and saves its configuration in `Copy Group Specification/`.
3. **Claude logs it right away, before any new dev edit:**

```powershell
Register-DwRelease -Id <date> -Started <yyyy-MM-ddTHH:mm:ss-03:00> -Finished <...> -Config 'Copy Group Specification\<file>.xml' -ProdBefore <last prod copy id> -Items <ids> -Note '...'
Register-DwExport -Id <date>-release -Source 'Dev -> prod release <date>' -Note '...'    # new baseline: prod = these files
Set-DwTrackingItemStatus -Id <id> -Status verified -Export <date>-release -Note '...'   # for each released fix
```

   - **The start time:** the configuration file's save time, since it's saved from the summary page just before the copy runs.
   - **The end time:** the last write in `%LOCALAPPDATA%\DriveWorks\Common\DataManagementDisplayPrefs.xml`, which Data Management writes when it closes.

First release: **2026-10-09, 13:03–13:12 (−03:00)**, all 18 projects ([copy-group/2026-10-09-dev-to-prod.md](copy-group/2026-10-09-dev-to-prod.md)).

## While working on the dev copy

- Tag your edits: `Set-DwChangeContext -Item <item id> -Reason '...'`, then the `Set-Dw*`/`Edit-DwProject` calls. Clear it with `Set-DwChangeContext -Clear`.
- Log every issue we find or fix we agree on with `Add-DwTrackingItem -Id <project-short-name> -Project '<Folder/File.driveprojx>' -Title '...' -Priority high|medium|low -Notes '...' [-Check checks/<id>.ps1] [-CrossProject]`. Add a check when it can be tested (copy an existing one), and change an item only with `Set-DwTrackingItemStatus`.
- **`items.json` is the single source.** Both commands regenerate `docs/projects/<project>/issues.md` (one per project, open issues first) and the index `docs/issues.md` (counts, plus the cross-project issues) through `Update-DwIssueDocs`. Never edit those `issues.md` files by hand. Run `Update-DwIssueDocs` yourself only after editing `items.json` some other way.
- `Test-DwTrackingItem` runs the checks at any time. `Test-DwExportChanged` compares against the last export.
- A change made by hand that isn't a re-export (a file deleted in Explorer, say) is recorded with `Add-DwLedgerNote -Path <file> -Change Removed|Changed|Added -Reason '...'`. The hook then stops reporting it.
