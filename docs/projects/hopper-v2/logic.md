# DW Hopper V2: logic diagrams

*Read from the project rules and replayed with `DwFormEngine` on production spec 46203 (ARD1652 rev 6, ARD1653 rev 7), 2026-10-08.*

These diagrams show how DW Hopper V2 goes from form inputs to the panels it builds. They cover the release loop that hosts DW Hopper V2 - Panels, the drop-zone geometry, the values sent to each panel, the bolt zones, and the sections after the drop zone.

**Red nodes** are problems found on spec 46203. Each one is explained in [learnings.md](learnings.md), and the fixes proposed so far are listed there. The panel project's side is in [../hopper-v2-panels/logic.md](../hopper-v2-panels/logic.md). Every input is described in [../inputs/hopper-v2-inputs.md](../inputs/hopper-v2-inputs.md).

Names in the diagrams are the project's own (variables without `DWVariable`). "K*rc*" is a drop-zone kit: column *r* (1–4, from the back wall) and row *c* (0–2, from the bottom), so K21 is column 2, row 2. Assemblies: A32 right side, A31 left side, A30 back.

## 1. Release: one Panels spec per drop-zone panel

```mermaid
flowchart TD
    A["Spec enters state Completed"] --> B["Run Macro: ReleaseAllPanels"]
    B --> C{"Run Macro in a Loop<br/>counter = 1 … NumberOfLoopPanels<br/>(counter constant ReleaseAllChildsCounter)"}
    C -->|each pass| D["ReleaseAllPanelsSub:<br/>drive PanelSelectorSpinButton = counter"]
    D --> E["SelectedSide, SelectedKitNumber<br/>= the row with that Counter in CleanPanelListTable"]
    E --> F["DWCalcPanelListInput<br/>64 Name/Value rows for that panel"]
    F --> G["Set Specification Host Control<br/>SinglePannelHostControl = DW Hopper V2 - Panels<br/>InputValues = DWCalcPanelListInput"]
    G --> H["Run macro Release in the hosted spec"]
    H --> I["Panels: transition ReleaseAutopilot or ReleaseLocal<br/>builds prefix-A3x-Krc-colour-YD-with Onsite Bolts.sldasm"]
    I --> C
    C -->|done| J["Completed state, next tasks:<br/>Release Documents, Release Emails"]
    J --> K["Release Models: DW09B-Hopper Main Assembly"]
    K --> L["Each dummy instance:<br/>ReplaceDropZone(Side)Formula(MyNumber(3))"]
    L -->|"panel enabled"| M["ReplaceFile: the panel file from the spec folder"]
    L -->|"not enabled"| N["Delete"]
    O["Rev 6 (69 ft): 7 dummies kept though their rule said Delete,<br/>and right K11 missing. Cause unknown."]:::bug
    L -.-> O
    classDef bug fill:#fde2e2,stroke:#c0392b,color:#7b1d1d
```

- **Dummy numbering.** The digit runs in `DW09B-Hopper Main Assembly\DW09B-Right Side Drop Zone Assy Dummy-n` are 09, 09 and n, so `MyNumber(3)` is the instance number n. Dummy n is panel n of that side:
  - sides: 1 = K10, 2 = K11, 3 = K12, 4 = K20 … 12 = K42;
  - back: 1 = K10 … 9 = K32.
- **The panel files must exist before V2's model is built.** The loop runs first in the Completed state, then the documents, emails and models.
- **The transition, mid and elbow kits are V2's own parts.** Only the drop-zone panels come from DW Hopper V2 - Panels.

## 2. Drop-zone geometry: which panels exist

```mermaid
flowchart TD
    subgraph IN["Inputs (right side; the left copies it when Same Left Side As Right Side is on)"]
        H["DropZoneHeight (in)"]
        OW["Offset on/off, width, angle,<br/>bottom bend on/off and height"]
        L["DropZoneLength (ft)"]
        CT["ConveyorType"]
        TC["Angled top cut on/off, angle"]
        BA["Back angle on/off, angle, direction,<br/>end of back angle on/off and height"]
    end
    OW --> TOP["TopOfOffSetHeight<br/>= bend + tan(offset angle) × offset width"]
    H --> ROWS["HowManyRows (1–3)<br/>with an offset: row 1 = offset top, the rest above it<br/>without: rows of at most 36 in, in 6 in steps"]
    TOP --> ROWS
    CT --> ADJ["K1XLengthModificationByTypeOfConveyor<br/>Kit −1, Light Duty −1.6875, Picking +0.25 in"]
    L --> DZL["DZLength = typed whole feet + adjustment ÷ 12 (ft)<br/>capped at the last whole foot before the top cut comes down to PanelMinHeight (4 in),<br/>so later sections stay on the conveyors' 12 in bolt grid"]
    ADJ --> DZL
    TC --> DZL
    DZL --> COLS["Columns K1X … K4X<br/>K1X up to K1XMaxLength (48 in, less when the back leans backward)<br/>then 48, 48, and the remainder"]
    BA --> LEAN["Back lean offsets<br/>K11/K12/K13 OriginZDiff"]
    ROWS --> PTS["Corner points of each kit Krc<br/>Origin, TopTail, TopHead, BottomHead"]
    COLS --> PTS
    LEAN --> PTS
    TC --> CUT["Cut line: Y(z) = DZHeight − tan(cut angle) × (z − K13OriginZDiff)"]
    LEAN --> CUT
    CUT --> PTS
    ROWS --> ONOFF["Krc OnOff = its column exists AND its row exists"]
    COLS --> ONOFF
    ONOFF --> EN["DropZonePanelList.Enable<br/>sides: OnOff AND origin below the cut line<br/>back: OnOff"]
    CUT --> EN
    EN --> CLEAN["CleanPanelListTable = the enabled rows<br/>NumberOfLoopPanels = their count"]
    PTS --> PROF["Panel profile digits<br/>BackLine, FrontLine, Side (see section 3)"]
    EN --> REP["Dummy n → kit → Enable?<br/>ReplaceFile or Delete (section 1)"]
    FIX1["Fixed in dev 2026-10-08: the drop zone stops where the cut reaches PanelMinHeight,<br/>so no gap before the transition and no triangle to 0"]:::fixed
    BUG2["No limit: DropZoneLength can exceed 4 columns (about 16 ft)<br/>or Before Elbow Length (the user adds the limits)"]:::bug
    FIX3["Fixed in dev 2026-10-08: Enable needs PanelMinHeight (4 in) under the cut;<br/>slivers and short rows are dropped"]:::fixed
    DZL -.-> FIX1
    L -.-> BUG2
    EN -.-> FIX3
    classDef bug fill:#fde2e2,stroke:#c0392b,color:#7b1d1d
    classDef fixed fill:#e2f4e5,stroke:#2e7d32,color:#1b4d20
```

- **Spec 46203:** a 24 in side over an 18.5 in offset gives rows of 18.5 and 5.5 in. With a 20° cut, the side reached 0 at 59.1 in, but the drop zone ran to 70.3 in (rev 7), leaving an 11.2 in gap before the 12 in transition.
- **Since 2026-10-08 (dev),** the drop zone stops at the last whole foot before the side drops under 4 in: 4 ft (46.3 in) on rev 7, where the side is 4.66 in. The transition (at 48 in) and mid section (at 96 in) fill the rest, on the 12 in bolt grid.
- **OnOff is not "built".** A panel can be on (its row and column exist) yet sit wholly above the cut. It is then left out by `Enable` only, and its corner variables can be negative.

## 3. What V2 sends each panel (PanelListInput)

```mermaid
flowchart TD
    S["PanelSelectorSpinButton = n"] --> SEL["SelectedSide, SelectedKitNumber"]
    SEL --> PLI["DWCalcPanelListInput: Name/Value rows"]
    PLI --> P1["Size: PanelHeight, PanelLength,<br/>CSideCutLength (head edge height), BottomFlangeWidth"]
    PLI --> P2["Profiles: BackLineProfile, FrontLineProfile, SideProfile, TopProfile<br/>→ the panel family in Panels"]
    PLI --> P3["Back angle: BackAngle, DimForStart/EndOfBackAngle, ConveyorAngle"]
    PLI --> P4["Offset, top cut angle, bolt zones 1A … 3C (section 4)"]
    P3 --> Q1{"Backward AND End Of Back Angle on<br/>AND the angle ends at or below this panel?"}
    Q1 -->|yes| A1["BackAngle = 90 − ConveyorAngle<br/>(plumb on an inclined conveyor)"]
    Q1 -->|no| Q2{"Backward AND<br/>end height − panel start ≤ 0?"}
    Q2 -->|yes| A2["BackAngle = 90 − ConveyorAngle"]
    Q2 -->|no| A3["BackAngle = DZBackAngleDeg<br/>(0 when Back Angle is off)"]
    BUGB["Backward stays TRUE while Back Angle is off and the box is hidden,<br/>so the back top row is sent 83° (hidden Conveyor Angle 7).<br/>No model effect: the vertical back family ignores BackAngle"]:::bug
    Q2 -.-> BUGB
    classDef bug fill:#fde2e2,stroke:#c0392b,color:#7b1d1d
```

- **Profile digits (inferred from the rules):**
  - Front line: 1 plain, 3 side wall with an offset, 4 back wall following the offset.
  - Back line: 1 vertical, 2–7 the back-angle cases (leaning, starting or ending inside the panel).
  - Side: 5 is a triangle under the top cut.
- **Proposed fix for the 83°,** tested by replay: only the two back top panels change, and rev 7 doesn't change at all.
  ```
  DZBackAngleDirectionBackward = If( DWVariableDZBackAngleOnOff = TRUE AND DWVariableDZBackAngleDirection = "Backward" , TRUE , FALSE )
  ```

## 4. Bolt zones

```mermaid
flowchart TD
    BZT["BoltZoneTable: zones 1A … 3C for Right and Left<br/>Enable, StartYDim, EndYDim, ZoneHeight"] --> SHARE["Share of each zone in each row<br/>InX0/InX1/InX2 BackPanel (back rows)<br/>InX0/InX1/InX2 SidePanel (side rows)"]
    SHARE --> FILT["BoltZoneTableCurrentSide<br/>SppTableFilterByColumnComparison(table, 2, 14, TRUE):<br/>rows where Side = the SelectedSide column"]
    FILT --> PICK{"Selected panel"}
    PICK -->|"back panel, any column (Mod(kit, 10))"| BV["BoltZone1A … 3C = InX(row)BackPanel"]
    PICK -->|"side panel K10, K11, K12"| SV["BoltZone1A … 3C = InX(row)SidePanel"]
    PICK -->|"side panel K20 and up"| NV["FALSE: no vertical bolt zones<br/>(likely intended: only the first column meets the back wall)"]
    BUGZ["InX0SidePanel returns the zone's end height when the zone starts above row 1<br/>→ every side K10 gets zone C = 39.5 in on an 18.5 in panel<br/>→ with the back angle on (R531) it adds 3 holes past a 2.5 in section: likely the rev 7 K10 red X"]:::bug
    SHARE -.-> BUGZ
    classDef bug fill:#fde2e2,stroke:#c0392b,color:#7b1d1d
```

- Back panels' zones add up to their height (24 = 2.5 + 16 + 5.5 on rev 6). Side K10's zones add an extra 39.5 in, the back wall's height.
- `SppTableFilterByColumnComparison` is a Pro Server function, so `DwFormEngine` needs a stand-in. See [../../learnings.md](../../learnings.md), 2026-10-08.

## 5. After the drop zone: transition, mid panels, elbow

```mermaid
flowchart TD
    DZ["DZLength (ft)"] --> TR{"Offset on AND DZLength < BeforeElbowLength?"}
    BE["BeforeElbowLength (ft), with the same conveyor adjustment"] --> TR
    TR -->|no| T0["Transition = 0"]
    TR -->|yes| T4["Transition = 4 ft, or what is left before the elbow"]
    T4 --> SH["TransitionShape: B or A with an offset bottom bend, C or D without<br/>(A and D when the transition is taller than the offset top)"]
    T4 --> DT{"Double Transition Piece on<br/>AND transition taller than the mid panels?"}
    DT -->|yes| DT4["Second transition (K60): 4 ft, or what is left"]
    DT -->|no| DT0["0"]
    DZ --> ST["StartOfMidPannelsIncline = DZLength + transitions"]
    T0 --> ST
    T4 --> ST
    DT4 --> ST
    DT0 --> ST
    ST --> PL["BeforeElbowPatternLength = BeforeElbowLength − start<br/>(− 3 ft elbow section when Elbow is on)"]
    PL --> QTY["Pattern qty = RoundDown(length ÷ 4 ft)<br/>K70 mid panels, patterned"]
    QTY --> LAST["BeforeElbowLastPanelLength = length − 4 × qty"]
    LAST -->|"≠ 0"| K80["K80 last panel kept, at that length"]
    LAST -->|"= 0 (rounding noise counts as 0)"| K80D["K80 deleted"]
    EL["Elbow on"] --> AE["After the elbow: (AfterElbowLength − 3 ft) in 4 ft panels<br/>+ a last panel (+6 in on a Kit Conveyor)"]
    BUGM["No check that DZLength < BeforeElbowLength:<br/>69 ft silently removed the whole mid section (rev 6)"]:::bug
    BUGL["No minimum for the last panel (a 3 in panel is possible)"]:::bug
    TR -.-> BUGM
    LAST -.-> BUGL
    classDef bug fill:#fde2e2,stroke:#c0392b,color:#7b1d1d
```

- **Rev 7 (6 ft drop zone, 18 ft before the elbow):** transition B 4 ft, two K70 pattern copies, last panel 0, so K80 is deleted. All of this matched the SOLIDWORKS tree.
