# DW Apron Project: issues

*Generated from [tracking/items.json](../../../tracking/items.json) by `Update-DwIssueDocs`. Do not edit by hand: log an issue with `Add-DwTrackingItem` and change it with `Set-DwTrackingItemStatus` (see [tracking/README.md](../../../tracking/README.md)).*

Known issues of this project, open ones first. Findings and context are in [learnings.md](learnings.md); cross-project issues are in [docs/issues.md](../../issues.md).

Statuses: **open** (a problem, not fixed anywhere), **recommended** (a fix proposed), **fixed-in-dev** (applied in `DriveWorks Files`, waiting for production), **verified** (the check passes on a production export), **closed** (dropped).

| Issue | Status | Priority | Check |
|---|---|---|---|
| [apron-10ft-hardcoded](#apron-10ft-hardcoded) The 10 ft section maximum is a literal 10 in 21 variables; ftMaximumSectionLength is read only by the three finallength guards | open | medium | by hand |
| [apron-a02a-placement](#apron-a02a-placement) A02A placement on the incline (A11-A19) and top run (A21-A24) does not follow the bottom run's last-section rule | open | medium | by hand |
| [apron-replace-targets-exist](#apron-replace-targets-exist) SA4-SA7 belt/chain slots insert DW10-A50/A51/A52-SA4..SA7, which do not exist | open | medium | yes |
| [apron-sa-count-limit](#apron-sa-count-limit) SectionLayout can produce more shipping assemblies than the 7 SA component sets | open | medium | yes |
| [apron-ski-warning-height](#apron-ski-warning-height) "Change Ski Position" warning always shows and adds a 100 px gap (SkiPositionWarning.Height = Max( 100, ... )) | open | medium | yes |
| [apron-top-run-copies](#apron-top-run-copies) Only 4 top-run section copies exist, but topconstatmult can reach 6 (slider max 60 ft) | open | medium | by hand |
| [apron-clientprojects-every-release](#apron-clientprojects-every-release) Every Apron release appends a row to the ClientProjects group table | open | low | by hand |
| [apron-defaults-not-options](#apron-defaults-not-options) Defaults that are not options: TypeBelt 2.4375 (a shaft size), Thickness None | open | low | by hand |
| [apron-kit-hooks-leftover](#apron-kit-hooks-leftover) Kit Conveyor hooks copied into Apron point at nothing | open | low | by hand |
| [apron-sa-hardcoded-index](#apron-sa-hardcoded-index) SA2-SA7 read SectionLayout by position: TableGetValue(DWCalcSectionLayout, 7, 29) | open | low | yes |
| [apron-commonspecs-height-guard](#apron-commonspecs-height-guard) Guard the Conveyor Options height chain so no rule error can collapse the left panel (fix 3) | recommended | low | yes |
| [apron-conveyor-options-collapse](#apron-conveyor-options-collapse) Conveyor Options frame collapses (and Motor/Settings headers vanish) without a bottom elbow | verified | high | yes |
| [apron-sa-last-marker](#apron-sa-last-marker) SectionLayout FirstLastInShippingAssy misses "Last" when disabled rows follow the last section of an SA | verified | high | yes |
| [apron-top-run-without-top-elbow](#apron-top-run-without-top-elbow) Top-run mid-sections (A21-A28) stay enabled when Top Elbow is turned off | verified | high | yes |
| [apron-chain-holder-after-elbow](#apron-chain-holder-after-elbow) SAs that start with an elbow (A10/A20) have no chain holder at their start | verified | medium | yes |
| [apron-midsection-enable-sectionlayout](#apron-midsection-enable-sectionlayout) Mid-section copies (DW10-A02-n) keep or delete themselves from the SectionLayout Enable column | verified | medium | yes |
| [apron-v2-shipping-assemblies](#apron-v2-shipping-assemblies) No-top-elbow builds (Apron Conveyor Assembly V2) always get SA1-SA3, not driven by SectionLayout | verified | medium | yes |

### apron-10ft-hardcoded

**The 10 ft section maximum is a literal 10 in 21 variables; ftMaximumSectionLength is read only by the three finallength guards**

- **Status:** open; **Priority:** medium; **Raised:** 2026-10-01
- **Check:** none (checked by hand)
- **Notes:** See docs/projects/apron.md.

### apron-a02a-placement

**A02A placement on the incline (A11-A19) and top run (A21-A24) does not follow the bottom run's last-section rule**

- **Status:** open; **Priority:** medium; **Raised:** 2026-09-23
- **Check:** none (checked by hand)
- **Notes:** To review with the user.

### apron-replace-targets-exist

**SA4-SA7 belt/chain slots insert DW10-A50/A51/A52-SA4..SA7, which do not exist**

- **Status:** open; **Priority:** medium; **Raised:** 2026-10-06
- **Check:** [checks/apron-replace-targets-exist.ps1](../../../tracking/checks/apron-replace-targets-exist.ps1)
- **Notes:** V1 and V2 SA4-SA7 sets, slots -37 (belt) / -38 (chain). Only -SA1..-SA3 sets exist for A50, A51, A52. Add the sets in Administrator (copy -SA3) with their own split, or limit the chain split.
- **History:**
  - 2026-10-06: open (export 2026-10-06d). Found while remapping V2 slots -30..-38.

### apron-sa-count-limit

**SectionLayout can produce more shipping assemblies than the 7 SA component sets**

- **Status:** open; **Priority:** medium; **Raised:** 2026-10-05
- **Check:** [checks/apron-sa-count-limit.ps1](../../../tracking/checks/apron-sa-count-limit.ps1)
- **Notes:** Both elbows, 30/60/30 ft already needs 8 SAs; the longest build needs 10 (10,000 lb per SA). Add SA8-SA10 or cap/flag on the form.
- **History:**
  - 2026-10-05: open (export 2026-10-05). Found in the 2026-10-05 export review; check fails.

### apron-ski-warning-height

**"Change Ski Position" warning always shows and adds a 100 px gap (SkiPositionWarning.Height = Max( 100, ... ))**

- **Status:** open; **Priority:** medium; **Raised:** 2026-10-05
- **Check:** [checks/apron-ski-warning-height.ps1](../../../tracking/checks/apron-ski-warning-height.ps1)
- **Notes:** Fix: drop the Max( 100, ... ) wrapper: =IfError( If(skimaintenance="none",0,If(Indirect("DWVariableLengthMidSection"&ExtractNumber(skimaintenance))>=96,0,24)) ,0).
- **History:**
  - 2026-10-05: open (export 2026-10-05). Found in the 2026-10-05 export review; check fails.

### apron-top-run-copies

**Only 4 top-run section copies exist, but topconstatmult can reach 6 (slider max 60 ft)**

- **Status:** open; **Priority:** medium; **Raised:** 2026-09-23
- **Check:** none (checked by hand)
- **Notes:** To review with the user.

### apron-clientprojects-every-release

**Every Apron release appends a row to the ClientProjects group table**

- **Status:** open; **Priority:** low; **Raised:** 2026-10-01
- **Check:** none (checked by hand)
- **Notes:** NewClientProjects is released with all documents. Group table ClientProjects: 1457 -> 1505 rows between 2026-09-23 and 2026-10-05, 45 of them Apron. Manual check: compare the Apron row count between exports.
- **History:**
  - 2026-10-05: open (export 2026-10-05). ClientProjects 1457 -> 1505 rows (+45 Apron) since 2026-09-23.

### apron-defaults-not-options

**Defaults that are not options: TypeBelt 2.4375 (a shaft size), Thickness None**

- **Status:** open; **Priority:** low; **Raised:** 2026-10-01
- **Check:** none (checked by hand)
- **Notes:** No belt or chain is built until one is picked.

### apron-kit-hooks-leftover

**Kit Conveyor hooks copied into Apron point at nothing**

- **Status:** open; **Priority:** low; **Raised:** 2026-10-01
- **Check:** none (checked by hand)
- **Notes:** ExportToDB and ImportFromDB macros, EmailToCustomerCAD email, DWVariableProjectNameFromDB, a DataLine query on the Kit SQL table.

### apron-sa-hardcoded-index

**SA2-SA7 read SectionLayout by position: TableGetValue(DWCalcSectionLayout, 7, 29)**

- **Status:** open; **Priority:** low; **Raised:** 2026-10-05
- **Check:** [checks/apron-sa-hardcoded-index.ps1](../../../tracking/checks/apron-sa-hardcoded-index.ps1)
- **Notes:** Column 7 = ShippingAssembly, row 29 = A29. Inserting a column or row breaks it silently. Use TableGetColumnIndexByName(DWCalcSectionLayout,"ShippingAssembly") and DWVLookup("A29", ...).
- **History:**
  - 2026-10-05: open (export 2026-10-05). Found in the 2026-10-05 export review; check fails.

### apron-commonspecs-height-guard

**Guard the Conveyor Options height chain so no rule error can collapse the left panel (fix 3)**

- **Status:** recommended; **Priority:** low; **Raised:** 2026-10-02
- **Check:** [checks/apron-commonspecs-height-guard.ps1](../../../tracking/checks/apron-commonspecs-height-guard.ps1)
- **Notes:** Proposed: CommonSpecsExtend.Height = IfError(LogoWarning.Top + LogoWarning.Height,400). Defence in depth; not needed while the lists are right.
- **History:**
  - 2026-10-02: recommended (export 2026-09-28-reconstructed). Applied in the sandbox only; overwritten by the 2026-10-05 export.
  - 2026-10-05: recommended (export 2026-10-05). Not in production; the dev copy was overwritten by the export.

### apron-conveyor-options-collapse

**Conveyor Options frame collapses (and Motor/Settings headers vanish) without a bottom elbow**

- **Status:** verified; **Priority:** high; **Raised:** 2026-10-02
- **Check:** [checks/apron-conveyor-options-collapse.ps1](../../../tracking/checks/apron-conveyor-options-collapse.ps1)
- **Notes:** Cause: variable none = If(BottomHorizontalLength1,...) dropped the \| before the bottom-section list, so the logo list came out empty at straight 20-21 ft / Top Elbow 16-17 ft and LogoWarning.Height failed. Fix 1: none = If(DWVariableNumberOfBottomSection>0,"None\|","None"). Fix 2: IfError on LogoWarning.Height/Visible and SkiPositionWarning.Height.
- **History:**
  - 2026-10-02: fixed-in-dev (export 2026-09-28-reconstructed). Fixes 1-3 applied to the sandbox project and verified with DwFormEngine (ledger 2026-10-02). User applied fixes 1-2 in production.
  - 2026-10-05: verified (export 2026-10-05). Production has fixes 1 and 2 (same text). Check passes: 256 states.

### apron-sa-last-marker

**SectionLayout FirstLastInShippingAssy misses "Last" when disabled rows follow the last section of an SA**

- **Status:** verified; **Priority:** high; **Raised:** 2026-10-05
- **Check:** [checks/apron-sa-last-marker.ps1](../../../tracking/checks/apron-sa-last-marker.ps1)
- **Notes:** 76 model rules keep lifting braces / chain holders on First/Last sections, so those were deleted on e.g. A02/A04 (SA1), A14, A22. Recommended fix (tested in DwFormEngine): new last column NextEnabledSA, common rule If( [7L,1D] = TRUE , [2L,1D] , [1D] ), A29 row = 0; FirstLastInShippingAssy common rule If( [6L] = FALSE , 0 , If( [1L] > [1L,1U] , "First" , If( [1L] <> [1R] , "Last" , 0 ) ) ). A filtered-table variable is circular because it reads the whole table.
- **History:**
  - 2026-10-05: open (export 2026-10-05). Found in the 2026-10-05 export review; check fails.
  - 2026-10-05: fixed-in-dev (export 2026-10-05). NextEnabledSA column added to SectionLayout (common If( [7L,1D] = TRUE , [2L,1D] , [1D] ), A29 = 0) and FirstLastInShippingAssy now compares with [1R]. Check passes on the dev copy. Production still needs the same change.
  - 2026-10-06: verified (export 2026-10-06). Prod has the fix: SectionLayout column NextEnableSA (prod name; dev used NextEnabledSA) with the same rules, and the same FirstLastInShippingAssy common rule. Check passes.

### apron-top-run-without-top-elbow

**Top-run mid-sections (A21-A28) stay enabled when Top Elbow is turned off**

- **Status:** verified; **Priority:** high; **Raised:** 2026-10-06
- **Check:** [checks/apron-top-run-without-top-elbow.ps1](../../../tracking/checks/apron-top-run-without-top-elbow.ps1)
- **Notes:** MidSectionA21toA28Length has no TopElbow test; the hidden top slider keeps its value. Fix at the source like MidSectionA11toA19Length: If( DWVariableTopElbow = TRUE ,DWVariableConveyorTopHorizontalLengthInput-DWConstantftConveyorHeadSectionLength ,0 ). Also fixes NumberOfTopSection = -1 and the DW10-A02-21..24 sub-assembly name rules.
- **History:**
  - 2026-10-06: recommended (export 2026-10-06b). User found it; reproduced in the form engine, source-side fix tested with OverrideRule.
  - 2026-10-06: fixed-in-dev (export 2026-10-06c). User applied the TopElbow test to MidSectionA21toA28Length in the sandbox; check passes.
  - 2026-10-09: verified (export 2026-10-09-release). In production with the first dev -> prod release (2026-10-09 13:03-13:12 -03:00, tracking/releases.json): the check passes on the project files that were pushed; the user checked prod after the copy.

### apron-chain-holder-after-elbow

**SAs that start with an elbow (A10/A20) have no chain holder at their start**

- **Status:** verified; **Priority:** medium; **Raised:** 2026-10-07
- **Check:** [checks/apron-chain-holder-after-elbow.ps1](../../../tracking/checks/apron-chain-holder-after-elbow.ps1)
- **Notes:** The elbows have no chain holder, and they are always First, so A11/A21 (never First) only got a holder when Last. Agreed fix: holder 1 on A11 and A21 = TRUE. That is not at the SA end, but better than none. Holder 2 is unchanged (Last and > 48 in).
- **History:**
  - 2026-10-07: recommended (export 2026-10-07). Agreed with the user.
  - 2026-10-07: fixed-in-dev (export 2026-10-07). Applied in the sandbox.
  - 2026-10-09: verified (export 2026-10-09-release). In production with the first dev -> prod release (2026-10-09 13:03-13:12 -03:00, tracking/releases.json): the check passes on the project files that were pushed; the user checked prod after the copy.

### apron-midsection-enable-sectionlayout

**Mid-section copies (DW10-A02-n) keep or delete themselves from the SectionLayout Enable column**

- **Status:** verified; **Priority:** medium; **Raised:** 2026-09-28
- **Check:** [checks/apron-midsection-enable-sectionlayout.ps1](../../../tracking/checks/apron-midsection-enable-sectionlayout.ps1)
- **Notes:** tools/scripts/Set-ApronMidSectionFileNameRule.ps1 (2026-09-28, written to work/ only): If(DWVLookup("A0n", DWCalcSectionLayout, 1, Enable), PrefixMidSection n, "Delete").
- **History:**
  - 2026-09-28: recommended (export 2026-09-28-reconstructed). Script written; result kept in work/apron-filename-rules, not in the sandbox.
  - 2026-10-05: verified (export 2026-10-05). Done in production with a DWVLookup on MidSectionNumber instead of the section name. All 19 sets use SectionLayout Enable.

### apron-v2-shipping-assemblies

**No-top-elbow builds (Apron Conveyor Assembly V2) always get SA1-SA3, not driven by SectionLayout**

- **Status:** verified; **Priority:** medium; **Raised:** 2026-10-05
- **Check:** [checks/apron-v2-shipping-assemblies.ps1](../../../tracking/checks/apron-v2-shipping-assemblies.ps1)
- **Notes:** Question for the user: is the V2 SA rework planned? Until then straight and bottom-elbow-only aprons ship as three fixed SAs.
- **History:**
  - 2026-10-05: open (export 2026-10-05). Found in the 2026-10-05 export review; check fails.
  - 2026-10-06: fixed-in-dev (export 2026-10-06d). SA1-SA7 (V2) placeholders from SectionLayout (MyNumber), top level -30..-36 = SA1-SA7 by SA count, -37/-38 belt/chain after the user re-captured V2. Check passes.
  - 2026-10-09: verified (export 2026-10-09-release). In production with the first dev -> prod release (2026-10-09 13:03-13:12 -03:00, tracking/releases.json): the check passes on the project files that were pushed; the user checked prod after the copy.
