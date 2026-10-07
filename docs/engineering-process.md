# Sparta engineering process: reference

*Compiled 2026-09-23 from the `Solidworks_Automation` repo, cross-checked against the DriveWorks projects and group tables in this repo. Sources are listed in §12.*

Every fact carries one of three tags:

| Tag | Meaning |
|---|---|
| **[rule]** | Written down in Sparta's docs, or implemented in the macros and DriveWorks rules |
| **[observed]** | Holds consistently in real job data (ARC103, 455 records; PD43, 334 records) but is **not written down anywhere** |
| **[confirm]** | Unknown or a guess. Listed in §11 for someone to confirm |

---

## 1. Glossary.

| Term | What it is |
|---|---|
| **Project number** | 5-digit number for a client project, e.g. `12227` (Pope Douglas Material Recovery), `12599` (AMP Robotics, Frederick Blvd). **[rule]** |
| **Job / work order (WO)** | `<project>-<nn>` (or `-<nnn>`), e.g. `12227-43`, `12599-103`. One job = one buildable top-level assembly. Always treat it as **text**, because leading zeros matter. **[rule]** |
| **WO prefix** | Client initials plus the job suffix, e.g. `PD43` (Pope Douglas, job 43), `ARC103`, `WM23`, `ARD223`. It starts every file name in the job. **[rule]**, see §2.2 |
| **Top-level assembly** | The root `.SLDASM` of a job, e.g. `00-ARC103-IBC-R-01` or `PD43`. `Prod_Level = WorkOrder`. **[rule]** |
| **Assembly** | A direct child of the top-level assembly, e.g. `ARC103-A35-Chute`, `ARC103-SA1`. `Prod_Level = Assembly`. **[rule]** |
| **Sub-assembly** | Any assembly below that, at tier `Sub_Assembly_1..n`. It's built before its parent. **[rule]** |
| **Shipping assembly** | The unit that ships as one piece, named `-SA<n>` (see §6). **[observed]** in names, **[rule]** in DriveWorks |
| **Kit** | A leaf assembly of cut sheet-metal parts that becomes one fabricated (usually welded) unit. It has `-K<n>` in the name. See §5. **[rule]** |
| **Kit part** | A sheet-metal part whose direct parent is a kit. **[rule]** |
| **Single part** | A sheet-metal part that is **not** in a kit. It is finished and painted on its own and carries a colour code. **[rule]** |
| **Purchase / ERP part** | A bought-out item with an ERP number: 6+ digits in the name, or the `BOM Name` property. **[rule]** |
| **Misc part** | Everything else: solids without an ERP number, `-Z` sheet metal, structural beams, belts, decals, gearboxes. **[rule]** |
| **Excluded part** | A part whose configuration says *Exclude from BOM* (`Excl_BOM = Yes`). It appears on no production list. **[rule]** |
| **Hardware (Toolbox)** | Anything whose path contains `toolbox`. It is skipped entirely and never counted. **[rule]** |
| **Onsite hardware** | Bolt assemblies for field installation, e.g. `ARC103-Bolt Onsite Asm Leg`, `PD43-Onsite Bolt`, and the "with Onsite Bolts" kits in DriveWorks. **[observed]** |
| **Yard item (`-YD`)** | An item that does **not** need in-house assembly. It is assembled **only on site**. **[rule]** |
| **Process index** | The letters in a part code give the part's route through the shop: L Laser, B Bend, D Detailing, F Fab, P Paint, N Straight cut, S Subbed. See §3.3. **[rule]** |

## 2. Work orders and where files live

### 2.1 PDM vault layout **[rule]**
```
<vault>\Projects by Client\<Client>\<date or site> (<project#>)\<project#>-<nn> - <job name>\Design Files\<files>
```
Examples:
- `C:\Sparta Vault 2026\Projects by Client\AMP Robotics\2026-01-05 -Frederick Blvd (12599)\12599-103 - Fines Collection Conv\Design Files\00-ARC103-IBC-R-01.SLDASM`
- `C:\Sparta SW Vault\Projects by Client\Pope Douglas\Material Recovery System - 12227\12227-43-  Support Structure Phase 3\Design Files\PD43.SLDASM`

Details:
- **Vaults:** `C:\Sparta SW Vault\` (older) and `C:\Sparta Vault 2026\`. Both are SOLIDWORKS PDM **Standard** on server `SPA-PDM`.
- **Client name:** the folder directly below `Projects by Client`. Project and job come from the last `<digits>-<digits>` folder. A leading date such as `2026-03-26 - ...` is not a job.
- **Folders to ignore:**
  - Paths containing `Layout` hold the plant layout (real assemblies, but not buildable).
  - `Obsolete`, `Blocks`, `CNC`, and `Supplied by Client\...` hold client models or old files.
- **`Design Files` isn't universal.** Some jobs keep their assemblies at the job folder's own level.
- **Bought-in and shared parts** live in `...\Libraries\` (`Hardware`, `Sparta Parts`, `Decals`, `Nord Gear`, `Mechanical\Dodge Baldor\Bearings`, ...).
- **Material library:** `Y:\Sparta SW Files\Sparta Material\Sparta Materials.sldmat`.

### 2.2 WO prefix **[rule]**
- The prefix is the client's letter code plus the job suffix. The DriveWorks `ClientProjects` table has 1,439 rows mapping client → project → work order → WO prefix. Examples:
  - `Pope Douglas | Kit Conveyor | 12227-23 | PD23`
  - `AMP Robotics | Victory Blvd | 12598-312 | ARD312`
  - `WM26`, `RMD105`, `GFB24`
- **The letters can't be derived from the client name.** For example, client folder `IWS` uses prefix `IWD1xx`, and one client can have several codes (`PD`, `PDA`).
- **The digits usually equal the job suffix, but not always.** They match in 581 of 971 rows. DriveWorks also has template prefixes such as `DW01` (Kit Conveyor), `DW02` (Picking Conveyor), `DW03` (Stairs), `DW04` (HandRail), and `DW05` (Platform).

### 2.3 Top-level assembly name **[rule]**
- **New convention:** `00-` prefix plus a descriptor, e.g. `00-ARC103-IBC-R-01`, `00-ARD223-SBC-H-54`, `00-PDA101-Structure`. Children don't repeat the root's name.
- **Old convention:** the root is just the prefix and children extend it, e.g. `PD43`, `OQB21` → `OQB21-A1` → `OQB21-A1A`.
- **The descriptor is often the customer's name for the conveyor**, so it sits outside Sparta's naming convention. `IBC-R-01` and `SBC-H-54` are probably customer tags; the only way to know is to check the project. **Don't parse the root name** for meaning. **[rule]**

### 2.4 Outputs **[rule]**
- DataExtraction writes `<Assembly>.spa` and `<Assembly>.xlsx` to `\\spa-fse\Engineering\300 SPA Files` (`S:\300 SPA Files`), or to Downloads if the share is offline. Each run **replaces** the previous files; there's no timestamp.
- The older MasterMacro wrote `[WorkOrder] BOM.xlsx`.
- The macros are distributed from `Y:\Sparta SW Files\SpartaMacros\` (`\\spa-fil\Solidworks\...`).

## 3. Naming convention

### 3.1 Grammar
```
ARC103 - A31 - K11 - 2LF - BL - YD
  │       │     │     │     │    └─ YD = yard: assembled on site only (§3.5); NP = no paint
  │       │     │     │     └────── colour code (§3.4)
  │       │     │     └──────────── part code: <index><process letters> (§3.3), parts only
  │       │     └────────────────── kit token K<n>   (§3.2)
  │       └──────────────────────── group token A<n> (§3.2)
  └──────────────────────────────── WO prefix (§2.2)
```
**[rule]** from the MirrorMacro name parser, and DriveWorks builds names the same way. For example, the Ladder project's rule is `PrefixFileNameWithA & "-1LBP-" & CageColorCode & "-YD"`.

- **Separator:** `-`.
- **Tokens:** a letter, then digits, then optional letters (`A31`, `A01`, `A40A`, `K11`, `K3B`). `BL`, `YD` and `Asm` are not tokens.
- **Case:** Sparta file names are **uppercase**.
- **Kit files come in pairs.** A kit assembly and its main part share a base name: `ARC103-A31-K11-BL-YD.SLDASM` and `.SLDPRT` both exist, and the part is the main bent piece. **[rule]** + **[observed]**
- **Names with no tokens** (`Sparta Multi Bolt`, `ARC103 - Hopper Bolt Assembly`) are shared hardware or purchased items. **[rule]**
- **Revision:** Sparta names carry no revision token. `_REV3` appears only on client-supplied models. **[observed]**
- **Configurations** are part of an item's identity. Purchased hardware is modelled as multi-configuration parts, e.g. `Sparta Multi Bolt` has 9 configurations, each with its own ERP number. **[rule]**

### 3.2 Structure tokens

| Token | Meaning | Examples | Tag |
|---|---|---|---|
| `A<nn>[letter]` | **Group / section** within the job. Numbers can be zero-padded, can carry a trailing letter, and have gaps. | `A01` Tail Section, `A02` Mid Section, `A29` Head Section, `A30`–`A32` Hopper panels, `A35` Chute, `A40`/`A41` Legs, `A40A`, `A50` Head Scraper | [rule] (grammar), [observed] (meanings per job) |
| `A<n>00` | On **platforms**, the A-number defaults to **shipping assembly × 100** (A300 = shipping assembly 3) | DriveWorks Platform: `AssemblyNumber = ShippingAssembly * 100` | [rule] (DriveWorks) |
| `K<n>[letter]` | **Kit** (§5). Numbered within its group. | `ARC103-A01-K1-BL` Side Plate Kit, `K3A`/`K3B` Adjustable Takeup Kits, `PD43-K16-BL-YD` Knee Brace | [rule] |
| `K0` | Single parts placed directly in a group, not in a kit | `ARC103-A01-K0-5LBP-BL` | [observed] |
| `Z<n>` | **An assembly made of parts that the laser, press and fabricator never touch.** The work is usually just assembly and/or machining. DataExtraction therefore keeps `-Z` sheet metal out of the kit/single flow and classes it as Misc. (The old MasterMacro doc calls it "Zero/excluded part".) | `ARC103-A0-Z1` Skirting Assembly, `ARC103-A01-Z1-NP` Tail Pulley Assembly, `ARC103-A01-Z2-NP` Takeup Rod Weldment, `ARC103-A01-Z0-1N` | [rule] |
| `SA<n>` | **Shipping assembly** (§6) | `ARC103-SA1` Conveyor Shipping Assembly, `ARC103-A40-SA1` / `ARC103-A41A-SA2` Leg Shipping Assembly | [observed] |
| 6+ consecutive digits | **Purchase / ERP part**. The ERP number is the name. | `301851` weld nut, `500689` flange bearing, `742045` decal | [rule] |

### 3.3 Part codes: `<index><process letters>` **[rule]**
The letters are the part's **route through the shop, in order**. This is Sparta's *Process Index*:

| Letter | Process |
|---|---|
| `L` | Laser |
| `B` | Bend (press brake) |
| `D` | Detailing |
| `F` | Fab (fabrication, i.e. welding) |
| `P` | Paint |
| `N` | Straight cut |
| `S` | Subbed (subcontracted) |

- **The index is the part's number** within its kit or group (`1LF`, `2LF`, ...).
- **DriveWorks builds the same codes** (`-1LBP-`, `35LP`).

**Painting rule:** a part that gets welded (`F`) is painted **as a kit**, with the kit it's welded into. A part that isn't welded is painted **as a part**. **[rule]** That's why kit parts carry no colour code, while kits and single parts do (§3.4).

Codes in real jobs (ARC103 + PD43). The data matches the index on every record:

| Code | Route | Count | Data |
|---|---|---|---|
| `LF` | laser → weld | 250 | Never bent. Always a **kit part**. |
| `LBF` | laser → bend → weld | 21 | Always bent. Kit part. |
| `LP` | laser → paint | 10 | Not bent. **Single part** with a colour code. |
| `LBP` | laser → bend → paint | 27 | Bent. Single part. |
| `LBFP` | laser → bend → weld → paint | 1 | Bent. Single part. |
| `N` | straight cut | 4 | Rubber skirting strips (`-Z` items) |
| `NF` | straight cut → weld | 45 | Structural beams (W8x31, W8x18) |
| `DF` | detailing → weld | 5 | Structural beams |

In DataExtraction, `B` in the name lines up exactly with `needs_bending = Yes`, and `F` with `Kit_Part`. The macro doesn't read these letters; the match comes from following the convention.

### 3.4 Colour codes **[rule]**
From the DriveWorks `Colors` group table:

| Code | Colour | RGB | | Code | Colour | RGB |
|---|---|---|---|---|---|---|
| `BL` | **Sparta Blue** | 45,111,183 | | `GN` | Green | 0,128,0 |
| `YL` | **Sparta Yellow** | 255,198,39 | | `PU` | Purple | 105,25,102 |
| `GR` | **Sparta Gray** | 167,169,172 | | `MG` | Magenta | 205,25,102 |
| `WH` | White | 245,245,245 | | `LG` | Light Green | 160,255,20 |
| `BK` | Black | 10,10,10 | | `PK` | Pink | 209,120,125 |
| `GZ` | Galvanized | 128,128,128 | | `LB` | Light Blue | 60,255,220 |
| `RD` | Red | 155,35,33 | | `RB` | Ruby | 209,20,25 |
| `BG` | Beige | 245,245,220 | | `OR` | Orange | 255,140,0 |
| *(none)* | Custom | — | | | | |

How the colour code is used:
- **On which items:** kits and single parts carry it. Kit *parts* don't, because welded parts are painted with their kit (§3.3). **[rule]**
- **In DataExtraction:** the `Color` field only separates `Yellow` (`-YL`) from everything else (`Custom`). It's a naming hint, not the model's appearance, so a Sparta Blue part reads `Custom`. **[rule]**
- **In DriveWorks:** the code comes from the `ColorCode` variable, backed by this table, and the `PaintRed`/`PaintGreen`/`PaintBlue` inputs cover custom colours. **[rule]**

### 3.5 Other suffixes

| Suffix | Seen on | Tag |
|---|---|---|
| `-NP` | **No Paint.** Seen on tail/head pulley assemblies, the takeup rod weldment, `PD43-K40-NP` Bolt-On Plate Weldment, and Apron kits (`-A52A-K3-NP`). | [rule] |
| `-YD` | **Yard.** The item does **not** need in-house assembly; it is assembled **only on site**. It comes after the colour code (`-BL-YD`, `-GN-YD`, `-GR-YD`), e.g. every `PD43-K#-BL-YD` column and beam weldment. DriveWorks appends it systematically (~900 rules). `-YD(1)` is used for STEP/DXF output names. | [rule] |
| `-MIR`, `-MIR-<n>` | Only the fallback names MirrorMacro gives items without tokens | [rule] |

### 3.6 Handed (left/right) parts **[rule]**
- **Names carry no LH/RH marker.** An opposite-hand copy made with MirrorMacro gets a **new number** in the existing series.
- **Kits:** default is one past the highest kit number in the group (K11 in A31 → K23). The alternative is the first free number counting up from the source (→ K16).
- **Groups:** the next free A-number (A31 → A33; A01 → A04; A40A → A42A).
- **When a group is renamed,** every descendant's group token changes and kit numbers stay the same.
- **Where handedness shows:** only in descriptions ("Left Side Plate Kit", "Right leg kit") or in free-text names (`ARC103-Torque Arm Left`).
- **Mirror depth:**
  - Layer 1 = a kit (parts only): its `K` number changes.
  - Layer 2 = a group of kits: it gets a new `A` number.
  - Anything deeper is refused. Shared hardware is reused, not copied.
- **Output folder:** mirrored copies go in `<host folder>\Mirrored\Run <n>\`.

### 3.7 Example names
- `ARC103-A01-K1-BL`: kit 1 of group A01 (Tail Section), welded and painted Sparta Blue as a kit. It is both the kit assembly and its main bent part.
- `ARC103-A01-K2-BL` contains `ARC103-2LF` (laser → weld) and `ARC103-3LBF` (laser → bend → weld). These are project-level reusable plates, so they have no group or kit token. They take the kit's paint.
- `ARC103-A01-13LBP-YL`: a single part, laser → bend → paint, Sparta Yellow.
- `ARC103-A35-K1-BL-YD`: a hopper panel kit, Sparta Blue. It's a **yard** item: assembled on site, not in the shop.
- `PD43-K1-BL-YD`: a column weldment, a yard item (old-style job, no group token).
- `ARC103-A01-Z1-NP`: the tail pulley assembly, a Z item (assembly/machining only), **no paint**.

## 4. Product structure and classification

### 4.1 Hierarchy **[rule]**
```
Work Order (top-level assembly, SW level 0)
└─ Assembly (level 1) ─ e.g. ARC103-SA1, ARC103-A35-Chute, ARC103-A40-Legs
   └─ Sub_Assembly_1 … Sub_Assembly_n
      └─ Kit (-K, deepest tier) ─ Kit_Part …
      └─ Single_Part / ERP_Part / Misc_Part …
```
- **Production level (`Prod_Level`):**
  - The root is `WorkOrder`.
  - Level 1 is `Assembly`.
  - Level L ≥ 2 is `Sub_Assembly_<L-1>`.
  - **Every leaf assembly (no assembly children) at level ≥ 2 moves to the deepest tier**, so kits line up on one tier even when they sit at different depths.
- **Build order:** the shop builds deepest tier first, and the workbook lists sub-assembly tiers in that order.
- **Components left out:** suppressed components, components with an empty path, and Toolbox components are dropped and never counted.

### 4.2 Part class (`Prod_PartClass`), first match wins **[rule]**

| # | Condition | Class | Where it goes |
|---|---|---|---|
| 1 | Configuration *Exclude from BOM* | `BOM_Excl` | Nowhere |
| 2 | Has an ERP number (§4.3) | `ERP_Part` | **Purchase_Parts** (purchasing) |
| 3 | Sheet metal, no `-Z` in its own name, **and** the direct parent is a deepest-tier `-K` assembly | `Kit_Part` | Sheet-metal lists, kits |
| 4 | Sheet metal, no `-Z`, otherwise | `Single_Part` | Sheet-metal lists, Kit & Single |
| 5 | Everything else (solids, `-Z` sheet metal) | `Misc_Part` | **Misc_Parts** |

"Sheet metal" means the feature tree has a native sheet-metal feature (`SheetMetal`, `SMBaseFlange`, `EdgeFlange`, `Hem`, `Jog`, `FlatPattern`, ...). An **imported** STEP or IGES plate therefore reads as `Solid`. **[rule]**

### 4.3 ERP number **[rule]**
The ERP number is read from the `BOM Name` custom property (configuration first, then the file):
1. `BOM Name` is exactly 6 digits → use it.
2. The file name has 6+ consecutive digits, and `BOM Name` is empty or equal to the file name → use the file name.
3. `BOM Name` equals the file name → no ERP number (a Sparta-made part).
4. Otherwise → use `BOM Name` as written. `KB302036`-style hardware codes come through this rule.

Sparta's part template links `BOM Name` to the file name, which is why fabricated parts fall under rule 3.

### 4.4 Quantities **[rule]**
- **`Qty_Local`:** instances of one file + configuration under its **immediate** parent.
- **`Qty_Total`:** `Qty_Local` × the `Qty_Local` of **every ancestor** up to the work order. It answers "how many does this work order need". For example, a bracket ×2 in a kit ×3 has `Qty_Total = 6`.
- **Every cut list, purchase total, or nesting run must use `Qty_Total`.** Summing local quantities under-counted by 783 vs 2,752 on a real job.
- **Weight is per unit.** It is never multiplied by quantity.

## 5. What a kit is

- **Definition [rule]:** an assembly whose name contains `-K`, **and** that sits on the **deepest sub-assembly tier**.
  - Its direct sheet-metal children (not `-Z`, no ERP number) are **kit parts**.
  - Everything outside kits that is sheet metal is a **single part**.
- **In practice [observed]:** a kit is the set of laser-cut plates that the shop **fabricates into one piece**, usually a weldment:
  - a **main part named like the kit** (usually the bent piece),
  - `LF`/`LBF` plates,
  - sometimes weld nuts (ERP parts).

  Kit descriptions: "Side Plate Kit", "Adjustable Takeup Kit", "Torque Arm Kit", "HOPPER PANEL", "Bottom Cross Brace", and on PD43, "COLUMN WELDMENT", "BEAM WELDMENT", "KNEE BRACE", "BOLT ON PLATE WELDMENT".
- **The kit carries the paint colour; its parts don't.** Welded (`F`) parts are painted as a kit; parts that aren't welded are painted as parts. So kits and single parts are the paintable units, which is what the `Color` field and the `Kit_And_Single_Part` sheet show. **[rule]**
- **Gotchas [rule]:**
  - **A `-K` assembly directly under the top-level assembly (level 1) is not classed as a kit.** All 54 `PD43-K#-BL-YD` weldments are "Assembly". Old-style jobs such as PD43 have no group level.
  - The `-K` test is a plain substring match, so a name like `...-KC60...` would also match. It only matters on assemblies.
  - The older `Kit_Single` field uses a looser structural test (the parent is a leaf assembly, whether or not it has `-K`), so it can disagree with `Prod_PartClass`.
  - The legacy MasterMacro treated any leaf assembly containing only parts as a kit, and highlighted a `-K` assembly only if it had 2+ sheet-metal parts.

## 6. Shipping assemblies

- **Naming [observed]:** `-SA<n>`, placed at whatever level the split happens:
  - `ARC103-SA1` "Conveyor Shipping Assembly" (level 1, holds the tail, mid and head sections)
  - `ARC103-A40-SA1` and `ARC103-A41-SA1` "Leg Shipping Assembly" (level 2)
  - `ARC103-A41A-SA1` / `-SA2` (level 3)
- **The SOLIDWORKS macros have no shipping logic.** Shipping assemblies are classified as ordinary assemblies. **[rule]**
- **How the split is decided:** DriveWorks encodes it per product. **[rule]** (DriveWorks project rules). Lengths are in inches; the rules write 40 ft and 48 ft as `40*12` and `48*12`.

| Product | Rule |
|---|---|
| **Kit Conveyor** | Incline section: **1** shipping assembly if incline length ≤ 600 in (50 ft), else **2**. Horizontal section: **2** if > 48 ft, else **1**. Total = incline, plus horizontal if there's an elbow. **The torque arm ships outside** the shipping assembly when there is more than 1. |
| **Hopper conveyor** | Same thresholds. Total = incline + horizontal. |
| **Light Duty Conveyor** | Incline: 1 if ≤ 40 ft, else 2. Horizontal: 2 if > 40 ft, else 1. Total = incline + horizontal. **The motor ships in** the shipping assembly unless there's an elbow or total length ≥ 40 ft. |
| **Platforms** | The drafter gives each platform module a **shipping assembly number**, and its A-number defaults to that × 100. Each connection point (front/back/left/right, `F1..B3`) records the neighbour's A-number, so `ConnectedTo / 100` is the neighbour's shipping assembly. **On a moment connection, the plates (`35LP-YD`) are added only where neighbours are in different shipping assemblies**: 2 for "Bottom Only", otherwise 4, and 0 within the same one. *Platform Layout* counts the shipping assemblies (max of the list) and gathers the onsite bolt kits between them. |
| **Apron** | The chain has its own shipping assembly (`Releasechainshippingassembly`). |

- **What is assembled on site:**
  - `-YD` (yard) items need no in-house assembly and are assembled only on site. **[rule]**
  - Onsite bolt assemblies (`-Bolt Onsite Asm`, "with Onsite Bolts" kits) are the field-install hardware. **[observed]**
- Whether length is the only limit, and the rules for manually drawn jobs, are **[confirm]**.

## 7. What each department gets: the extraction workbook **[rule]**
One `.xlsx` per job. Each sheet is a filter over the same records, and quantities are always `Qty_Total`.

| Sheet | Contents | For |
|---|---|---|
| `BOM_Flat` | All parts except excluded ones. Grouped Solid → Sheet Metal (Material → Thickness, thickest first) → Name. | Engineering, the full parts list |
| `BOM_Hierarchy` | Indented tree with per-level and total quantities. Kits are highlighted amber. | Engineering and production structure |
| `Sheet_Metal_Parts` | Kit and single parts. Material → Thickness → Name, with subtotals. | Sheet-metal shop |
| `Flat_Sheet_Metal` | The same rows plus flat-pattern data: blank size, cut-outs, cut length, areas | **Laser / nesting / quoting** |
| `Bend_Sheet_Metal` | Parts with `needs_bending = Yes`, plus bend count, radius and allowance | **Press brake** |
| `Kit_And_Single_Part` | Two sections, kits then single parts, with colour | Fabrication / paint |
| `Purchase_Parts` | ERP parts with ERP number | **Purchasing** |
| `Misc_Parts` | Misc parts. Rows are not merged, so summing them double-counts. | Stores / purchasing / machining |
| `Sub_Assembly_<n>` | One tab per tier, **deepest first** ("what gets built first on the shop floor"). The deepest tab leaves kits out. | **Production build order** |
| `Assembly`, `WorkOrder` | Level-1 assemblies and the root, with weight and bounding box | Job summary, envelope sizes |
| `Legend`, `SW_Hierarchy` | Colour key; raw dump of every field | Everyone / data |

Useful measures:
- The laser cut path is `total_edge_length_in`.
- Paint or coating area is an assembly's `surface_area_in2` (the "Surface Area Paint" property on parts).
- Stock size is the blank or oriented bounding box.

## 8. Sheet-metal standards

- **Materials [observed]:**
  - Steel for almost all sheet metal. Also Rubber (skirting), Nyloil, UHMW, 1045 Steel CR (round stock), Zinc (hardware), Galvanize.
  - The DriveWorks `Material` table lists `Steel` and `QT 100` from the `Sparta Materials` library.
- **Gauges [observed]:** the gauge label is the thickness as a fraction:

| Gauge | Thickness (in) |
|---|---|
| `1/8"GA.` | 0.125 |
| `3/16"GA.` | 0.1875 (the most common) |
| `1/4"GA.` | 0.25 |
| `3/8"GA.` | 0.375 |
| `1/2"GA.` | 0.5 |

  The mapping is one-to-one across 179 records. Reports round thickness to 2 decimals.
- **Bending [observed]:**
  - All bends use a **K-factor** (no bend tables or deductions). K = **0.4** is typical; 0.495 and 0.58 also occur on 1/4".
  - Inside radius by thickness:

| Thickness | Inside radius (in) |
|---|---|
| 1/8" | 0.156 |
| 3/16" | 0.234 |
| 3/8" | 0.468 |
| 1/4" | 0.39 or 0.468 |

  - Bend direction (up/down) matters to the press-brake operator, because a wrong-way bend scraps the part.
  - The cut-list "Bend Radius" is only the document default, not the actual bend radius.
- **Density [confirm]:** the library's Steel is 7850 kg/m³, but older parts carry an embedded 7800. The material-library owner should choose one.
- **Single-body:** all of Sparta's own sheet-metal parts are single-body. Multi-body parts come from clients. **[observed]**

## 9. Custom properties on Sparta parts **[rule]**
Sparta's sheet-metal property template (from MirrorMacro, "transcribed from a known-good original part"):

| Property | Source |
|---|---|
| `Description`, `Process`, `Color`, `Length`, `USEDON` | **Typed by the drafter.** They can't be derived. |
| `Material` | `SW-Material` |
| `Weight`, `Sheetmetal Weight` | `SW-Mass` |
| `Surface Area Paint` | `SW-SurfaceArea` |
| `Type` | `Sheetmetal` or `Part` |
| `BOM Name` | `$PRP:"SW-File Name"` (the file name; the ERP number goes here for bought parts) |
| `Height`, `Width`, `Thick` | Cut-list bounding-box length and width, and sheet-metal thickness |
| `Number of Bend`, `Outer Cutting Length`, `Inner Cutting Length`, `Cutouts` | Cut-list `SW-Bends`, `SW-Cutting Length-Outer`, `SW-Cutting Length-Inner`, `SW-Cut Outs` |
| `Number of Pierce`, `Total Cut Perimeter` | Equations: `"Number of Pierce eq" = "Cutouts" + 4`, `"Total Cut Perimeter eq" = Outer + Inner` |

- **Equation:** there is also `"Process1" = IIF("Number of Bend" = 0, 5, 54)`. What 5 and 54 mean (process or routing codes?) is **[confirm]**.
- **Other properties seen:** `Date`, `Onsite Assembly`. The designer comes from the root assembly's *Author*.
- **Reset macro:** `ResetSheetMetalProps` rewrites the 7 cut-list-linked properties against the part's real cut-list folder. It's based on Jonathan's February 2022 macro.

## 10. How DriveWorks follows these conventions
For automating the DriveWorks projects in this repo:
- **File names:**
  - They are built from `DWVariablePrefixClientWO` / `PrefixFileNameWithA` / `...WithAandK`, then a part code, then `DWVariableColorCode`, then `-YD`.
  - `"Delete"` removes the component.
  - A leading `*` in a file-name rule is a DriveWorks convention *(meaning not verified here)*.
- **Group tables encode the standards:**
  - `ClientProjects`: client, project, work order, WO prefix
  - `Colors`: the colour-code table in §3.4
  - `Material`
  - `StairTreads`, `HelicalBevelNordGearbox`, `Bracing`
- **Shipping-split logic** lives in project variables (§6). Any new product should follow the same pattern.
- **A new captured model should be named in this grammar** (`<prefix>-A<n>-K<n>-<index><process letters>-<colour>[-YD|-NP]`) so that DataExtraction classifies its output correctly and the shop reads the route from the name. Pick the process letters from the part's real route (§3.3): for example `LBF` if it's bent and welded into a kit, `LP` if it's a flat part painted alone.

## 11. Open questions (to confirm with engineering)
1. **Shipping assemblies in manually drawn jobs**: who decides the split, and what limits apply (length, width, truck, crane)?
2. **PD43-style jobs**: should `-K` weldments directly under the root count as kits? Today they don't.
3. **`K0`**: is it a deliberate convention for single parts directly in a group?
4. **`Process1` = 5 / 54**: what process codes are these?
5. **Steel density**: 7850 or 7800?
6. **`Color`**: should DataExtraction distinguish all the colour codes in §3.4, instead of only Yellow and Custom?
7. **`D` (Detailing) and `S` (Subbed)**: which operations count as detailing, and is a subbed part named differently otherwise? No `S` part appears in the sample jobs.

*Answered by Jonathan on 2026-09-23: `-YD`, `-NP`, the process index, `-Z`, and top-level names (customer conveyor names, outside the convention).*

## 12. Sources
In `C:\Users\jonars\GitHub Projects\Solidworks_Automation\`:
- `modules\sw_macros\_archive\MasterMacro\MasterMacro_Summary.md`: original `-K`/`-Z`/ERP rules and hierarchy
- `modules\sw_macros\src\DataExtraction\Project_Blueprint.md` and `DataExtractionLogic.bas`: current classification (`DE_AssignProductionLevels`, `DE_AssignProdClassification`, `DE_AssignProdAssemblyClass`, `DE_AssignColor`)
- `doc\Data-Pipeline.md`, `doc\fields\Field-Reference.md`, `modules\spa_format\spec\v5\fields.md`: field meanings and quantity rules
- `modules\sw_macros\src\MirrorMacro\MirrorNaming.bas`, `MirrorNamingTest.bas`, `MirrorPropertiesLogic.bas`, `MirrorStep5.bas`: name grammar, numbering, property template
- `modules\spa_xlsx_report\src\sheets\*.js`: workbook sheets and who uses them
- `modules\sw_macro_runner\README.md`, `lib\PdmShell.ps1`, `doc\PdmShell-Notes.md`: vault layout, job folders, root naming
- `doc\Issue-Log.md`, `doc\Back-Log.md`, `modules\spa_format\CHANGELOG.md`: decisions and open questions
- `modules\spa_xlsx_report\tests\fixtures\arc103-v4.1\`, `pd43-v1.1\`: real job data (ARC103 = job 12599-103, PD43 = job 12227-43)

In this repo, the DriveWorks sources:
- Group tables `ClientProjects`, `Colors`, `Material` in `DriveWorks Files/Sparta DW Group for Claude.drivegroup`
- Shipping and naming rules in the Kit Conveyor, Hopper, Light Duty Conveyor, Platform (Straight, Picking, Layout, Bolts), Apron and Ladder projects. Find them with `Find-DwRule` / `Get-DwVariable`.
