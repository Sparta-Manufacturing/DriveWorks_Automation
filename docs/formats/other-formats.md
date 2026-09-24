# Other DriveWorks file types

| Extension | Container | Contents | Notes |
|---|---|---|---|
| `.drivepkg` | Plain ZIP (deflate) | A whole group snapshot: project folders, models, drawings, docs, group files | The Sparta package is 3.3 GB with 7,789 entries, about 95% SOLIDWORKS files. It seems to be staged in `%TEMP%\8b3598bb` and then zipped, because the packaged group's paths point there. It also contains a stray empty `.git` folder and `.github/copilot-instructions.md`. Extract it with `Expand-DwPackage` (`-ExcludeCad` for a quick, small extract). |
| `.driveprot` | ZIP | A **project template**: `<name>.driveprojx`, a trimmed `.drivegroup`, `template.xml`, and `Description/index.html` | Example: `Hopper/Empty Hopper Project.driveprot` |
| `.drivesft` | OPC (ZIP) | A **specification flow template**: one XML part plus `[Content_Types].xml` | Example: `Stairs Flow Template.drivesft` (`StairsFlowTemplate.xml`) |
| `.drivemaster` | | The legacy standalone Design Master. It's now embedded as `designMaster.xml` in the `.driveprojx`. | Referenced by the `DesignMasterExtension` attribute |
| `ProjectStyles.css` / `GroupStyles.css` | Text | Form CSS for DriveWorks Live and web forms | See the `driveworks-form-css` skill |
| `ProServerProblem-*.xml` | XML | A Pro Server problem report | One in the package root, dated 2026-09-15 |
