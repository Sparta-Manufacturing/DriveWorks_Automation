<#
.SYNOPSIS
    Detects that "DriveWorks Files" no longer matches the last registered export (a Copy Group re-export from
    production, or an edit made outside the DwTools writers, e.g. in DriveWorks Administrator).
    Runs as a Claude Code hook (SessionStart, UserPromptSubmit) with -Hook: it then prints hook JSON that tells
    Claude to review the export, once per distinct change. Without -Hook it prints a readable report.
    Standalone and fast (no DriveWorks DLLs): size first, then SHA-256 only for files whose size is unchanged
    but whose time differs. Files whose hash equals their latest tracking/ledger.jsonl entry are our own edits.
.EXAMPLE
    .\tools\scripts\Test-DwExportChanged.ps1
#>
param([switch]$Hook)
$ErrorActionPreference = 'Stop'
try {
    $repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    $root = Join-Path $repo 'DriveWorks Files'
    $regPath = Join-Path $repo 'tracking\exports.json'
    $statePath = Join-Path $repo 'tracking\.hook-state.json'
    $hookEvent = 'Manual'
    if ($Hook -and [Console]::IsInputRedirected) {
        $raw = [Console]::In.ReadToEnd()
        if ($raw.Trim()) { try { $hookEvent = ($raw | ConvertFrom-Json).hook_event_name } catch { } }
    }
    if (-not (Test-Path -LiteralPath $regPath) -or -not (Test-Path -LiteralPath $root)) {
        if (-not $Hook) { 'No export registered (tracking/exports.json) or no DriveWorks Files folder.' }
        exit 0
    }
    $reg = [IO.File]::ReadAllText($regPath) | ConvertFrom-Json
    $last = @($reg.exports)[-1]
    $known = @{}; foreach ($p in $last.files.PSObject.Properties) { $known[$p.Name] = $p.Value }

    # latest ledger hash per file (our own edits)
    $ledgerHash = @{}
    $ledgerPath = Join-Path $repo 'tracking\ledger.jsonl'
    $ledgerSince = 0
    $goneByHand = @{}
    if (Test-Path -LiteralPath $ledgerPath) {
        foreach ($line in [IO.File]::ReadAllLines($ledgerPath)) {
            if (-not $line.Trim()) { continue }
            $e = $line | ConvertFrom-Json
            $key = ([string]$e.project).Replace('\', '/')
            if ($e.sha256After) { $ledgerHash[$key] = $e.sha256After }
            $goneByHand[$key] = [bool]$e.removed            # Add-DwLedgerNote -Change Removed (latest entry wins)
            if ([datetime]$e.time -gt [datetime]$last.registered) { $ledgerSince++ }
        }
    }

    $changes = New-Object System.Collections.Generic.List[object]
    $seen = @{}
    $files = Get-ChildItem -LiteralPath $root -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -in '.driveprojx', '.drivegroup' }
    foreach ($f in $files) {
        $rel = $f.FullName.Substring($root.Length + 1).Replace('\', '/')
        $seen[$rel] = 1
        $k = $known[$rel]
        if (-not $k) {
            if ($ledgerHash[$rel] -and $ledgerHash[$rel] -eq (Get-FileHash -LiteralPath $f.FullName -Algorithm SHA256).Hash) { continue }   # created by a logged edit
            $changes.Add([pscustomobject]@{ Path = $rel; Change = 'Added'; Sig = "$rel|$($f.Length)" }); continue
        }
        $mod = $f.LastWriteTimeUtc.ToString('o')
        if ($k.size -eq $f.Length -and $k.modified -eq $mod) { continue }
        $fs = [IO.File]::Open($f.FullName, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::ReadWrite -bor [IO.FileShare]::Delete)   # may be open in Administrator
        try { $hash = [BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash($fs)).Replace('-', '') } finally { $fs.Dispose() }
        if ($hash -eq $k.sha256) { continue }
        if ($ledgerHash[$rel] -eq $hash) { continue }          # last change was our own logged edit
        $changes.Add([pscustomobject]@{ Path = $rel; Change = 'Changed'; Sig = "$rel|$hash" })
    }
    foreach ($p in $known.Keys) { if (-not $seen.ContainsKey($p) -and -not $goneByHand[$p]) { $changes.Add([pscustomobject]@{ Path = $p; Change = 'Removed'; Sig = "$p|removed" }) } }

    if (-not $changes.Count) {
        if (-not $Hook) { "DriveWorks Files matches export '$($last.id)' (plus $ledgerSince logged dev edit(s))." }
        exit 0
    }
    # A group database changes whenever Administrator uses it, so the hook only speaks up when a project file was
    # added, removed or changed (a re-export rewrites those too). The manual report still lists group changes.
    if ($Hook -and -not @($changes | Where-Object { $_.Path -notlike '*.drivegroup' }).Count) { exit 0 }
    $sigText = ($changes | Sort-Object Path | ForEach-Object { $_.Sig }) -join "`n"
    $sha = [Security.Cryptography.SHA256]::Create()
    $signature = [BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($sigText))).Replace('-', '')
    $list = ($changes | Sort-Object Path | Select-Object -First 12 | ForEach-Object { "$($_.Path) ($($_.Change.ToLower()))" }) -join ', '
    if ($changes.Count -gt 12) { $list += ", and $($changes.Count - 12) more" }

    if (-not $Hook) {
        "DriveWorks Files differs from export '$($last.id)' (registered $($last.registered)):"
        $changes | Sort-Object Path | ForEach-Object { "  $($_.Change.PadRight(8)) $($_.Path)" }
        "Logged dev edits since then: $ledgerSince. Review with Invoke-DwExportReview (tools/DwTools/DwTracking.psm1)."
        exit 0
    }

    $state = $null
    if (Test-Path -LiteralPath $statePath) { try { $state = [IO.File]::ReadAllText($statePath) | ConvertFrom-Json } catch { } }
    if ($hookEvent -eq 'UserPromptSubmit' -and $state -and $state.signature -eq $signature) { exit 0 }   # already told
    $newState = [ordered]@{ signature = $signature; notified = (Get-Date).ToString('o'); event = $hookEvent; export = $last.id }
    [IO.File]::WriteAllText($statePath, ($newState | ConvertTo-Json), (New-Object Text.UTF8Encoding($false)))

    $context = "DriveWorks export tracking: 'DriveWorks Files' no longer matches the last registered export '$($last.id)' " +
        "($($last.registered)). Changed outside the DwTools writers: $list. This is most likely a new Copy Group re-export from " +
        "production (or an edit made in DriveWorks Administrator). $ledgerSince dev edit(s) were logged in tracking/ledger.jsonl " +
        "since that export; a re-export overwrites them unless production has them. Before changing these projects, follow " +
        "tracking/README.md: Import-Module .\tools\DwTools\DwTracking.psm1; Invoke-DwExportReview; write the summary in " +
        "tracking/reviews/<date>.md; update item statuses (Set-DwTrackingItemStatus) from the checks; then Register-DwExport. " +
        "Tell the user what changed and which tracked items are now fixed (checks test behaviour, so a different fix still passes)."
    $out = [ordered]@{
        systemMessage      = "DriveWorks Files changed since export '$($last.id)': $list. Ask Claude to review the new export."
        hookSpecificOutput = [ordered]@{ hookEventName = $(if ($hookEvent -in 'SessionStart', 'UserPromptSubmit') { $hookEvent } else { 'SessionStart' }); additionalContext = $context }
    }
    $out | ConvertTo-Json -Depth 4 -Compress
    exit 0
} catch {
    if (-not $Hook) { throw }
    exit 0      # never block a session because of this check
}
