# Export tracking

`DriveWorks Files` is the dev copy of production. You refresh it by running **Copy Group** from `SPA-DWP` in DriveWorks Data Management, and each refresh overwrites everything, including our dev edits. This folder records what was there before, what we changed in between, and what we asked for. That way, the review of the next export can say what production picked up, even when it was fixed a different way.

| File | What |
|---|---|
| `exports.json` | Every registered export: id, date, source, file sizes and SHA-256, its snapshot folder and its review. |
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

## While working on the dev copy

- Tag your edits: `Set-DwChangeContext -Item <item id> -Reason '...'`, then the `Set-Dw*`/`Edit-DwProject` calls. Clear it with `Set-DwChangeContext -Clear`.
- Add an item to `items.json` for every issue or fix we agree on, with a check if it can be tested. Copy an existing check.
- `Test-DwTrackingItem` runs the checks at any time. `Test-DwExportChanged` compares against the last export.
- A change made by hand that isn't a re-export (a file deleted in Explorer, say) is recorded with `Add-DwLedgerNote -Path <file> -Change Removed|Changed|Added -Reason '...'`. The hook then stops reporting it.
