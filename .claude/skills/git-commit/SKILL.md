---
name: git-commit
description: How Claude commits, pushes and opens pull requests in this repo - branch first, commit by path, pre-commit checks (round-trip, generated docs, credentials, binaries), message and PR format, and what never gets done (tags, force pushes, history rewrites). Use whenever the user asks to commit, push, branch, open a PR, or asks how commits are handled here.
---

# Commits, pushes and pull requests

Remote: `origin` = `https://github.com/Sparta-Manufacturing/DriveWorks_Automation`, default branch `main`.

## When

- **Commit only when the user asks.** Finishing a change, or saving a project with `Edit-DwProject`, is not a request to commit.
- **Push or open a PR only when the user asks.** "Commit" doesn't mean "push".
- Git never deploys anything. The project files live in the git-ignored `DriveWorks Files/`; the repo carries the tooling, docs and `tracking/`. Deployment is the user's Copy Group to `SPA-DWP`.

## Branching

- **Never commit to `main`** unless the user says so for that commit. Start each piece of work on a fresh branch from an up-to-date `main`:
  ```powershell
  git switch main; if ($?) { git pull }; if ($?) { git switch -c <topic> }
  ```
  Uncommitted changes come along to the new branch. If `git pull` refuses because of local changes, stop and tell the user. Don't stash, reset or check out to get past it.
- Topic names are short kebab-case: `apron-chain-holder`, `dwtools-unused-vars`, `tracking-export-2026-10-08`.
- After a PR merges, `git switch main; git pull` before starting the next branch.

## Before committing

1. **Look.** Run `git status`, `git diff` and `git diff --cached` (another session may have staged files in this same working tree). Know exactly what goes in.
2. **Choose the paths.** Take only the files that belong to this piece of work. The tree usually carries other work in progress, so ask before including anything you didn't change for this task.
3. **Never commit:**
   - anything git-ignored. Never `git add -f`. That covers `DriveWorks Files/`, `work/`, `backups/`, `snapshots/` and `tracking/.hook-state.json`.
   - DriveWorks, SOLIDWORKS or customer binaries anywhere in the tree: `.driveprojx`, `.drivegroup`, `.drivespec`, `.drivepkg`, `.spa`, `.xlsx`, CAD. For example, `SPA files/` and `Test specification to check/` hold job files. Ask the user, and suggest a `.gitignore` entry.
   - credentials, or `Security*` table contents from a group database. If `$env:DW_GROUP_PASSWORD` is set, check the staged diff without printing the value:
     ```powershell
     if ($env:DW_GROUP_PASSWORD) { git diff --cached | Select-String -SimpleMatch -Quiet $env:DW_GROUP_PASSWORD }   # must be False
     ```
4. **Run the checks for what changed:**

   | Changed | Run | Must |
   |---|---|---|
   | any `.ps1` / `.psm1` | `[System.Management.Automation.Language.Parser]::ParseFile($f, [ref]$null, [ref]$errs)` on each | have no parse errors |
   | `tools/DwTools/*.psm1` | `Import-Module` each changed module with `-Force` | import cleanly |
   | the reader or writer in `DwTools.psm1` (`Get-DwProjectPart`, `Get-DwProjectXml`, `Edit-DwProject` and their helpers) | `.\tools\tests\Test-DwRoundTrip.ps1 -Path '.\DriveWorks Files'` | report every project byte-identical |
   | `tracking/items.json` | the generated `docs/issues.md` and `docs/projects/<project>/issues.md` | be in the same commit, never hand-edited |
   | `tracking/checks/*.ps1`, `DwTracking.psm1` or `DwFormEngine.psm1` | `Test-DwTrackingItem -Id <ids>` | run. Report the results; a failing check on an open item is expected |
   | project files on disk | `.\tools\scripts\Update-DwInventory.ps1` | regenerate `docs/inventory.md`, which goes in the commit |

   If a "must" fails, tell the user with the output and don't commit over it. If a check can't run (for example `DriveWorks Files` is missing), say so.

## The commit

- **Commit by path, never `git add -A` or `git add .`.** New files must be added first, because `--only` rejects untracked paths:
  ```powershell
  git add -- 'docs/projects/apron/learnings.md'          # new files only
  git commit --only -F $msgFile -- 'tools/DwTools/DwTracking.psm1' 'docs/projects/apron/learnings.md'
  ```
  `--only` commits exactly those paths and leaves anything another session staged untouched and out of the commit.
- **Write the message to a file** in the scratchpad with the Write tool, then pass it with `-F`. PowerShell 5.1 mangles double quotes inside native-command arguments, so don't pass multi-line messages with `-m`.
- **The format follows the history:** an imperative subject with no conventional-commit prefix (`Add functions for unused variable detection and component set rule modification`), a blank line, then `- ` bullets saying what changed and why. Name the projects and the tracking item ids involved. End with the `Co-Authored-By:` line for the model you are running as, currently:
  ```
  Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
  ```
- **Hooks and signing stay on.** No `--no-verify`, no `-c commit.gpgsign=false`. If a hook fails, fix the cause.
- **No interactive git** (`rebase -i`, `add -i`, `add -p`).
- **No rewritten history.** Don't amend unless the user asks, and never amend a pushed commit. No force pushes. Add a new commit instead.
- **Never undo work with `git checkout`, `git restore`, `git reset --hard`, `git stash` or `git clean`.** A "clean" snapshot can hide uncommitted changes, yours or another session's. To roll something back, restore it from a copy you saved yourself in the scratchpad. For a project file, use the `backups/` copy that `Edit-DwProject` made.

## Push and pull request

- Push with `git push -u origin <branch>`.
- Open the PR with `gh pr create --base main`. **`gh` isn't installed on this PC** (checked 2026-10-08). If it's still missing, give the user the compare URL with the title and description ready to paste:
  `https://github.com/Sparta-Manufacturing/DriveWorks_Automation/compare/main...<branch>?expand=1`
- **The PR description** covers:
  - **What changed**: tools, docs, tracking items.
  - **Why**: the issue, with tracking item ids.
  - **How it was tested**: the round-trip result, the tracking checks with their Pass/Fail, and which project in the sandbox group was edited. Say whether the user opened it in DriveWorks Administrator, which specification they ran, and what came out (models generated, the error or warning seen). The diff can't show whether DriveWorks accepts a rule, so the reviewer relies on this line. State plainly what wasn't tested.
  - It ends with `🤖 Generated with [Claude Code](https://claude.com/claude-code)`.
- **Stop there.** Approving and merging belong to the code owner.

## What never gets done

- **No tags.** Don't create, move or delete them. Tagging is for the repository admin.
- **If a push is rejected** (branch protection, permissions), tell the user what was refused. Don't get around it another way: no force push, no other branch name, no API call.

## Afterwards

Tell the user:
- the branch, and the commit hash and subject;
- the paths that went in, and what is still uncommitted;
- any step that was skipped, and why (round-trip not run, no PR because `gh` is missing, and so on).
