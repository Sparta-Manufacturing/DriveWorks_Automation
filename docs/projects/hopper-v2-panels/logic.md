# DW Hopper V2 - Panels: logic diagrams

*Read from the project rules (2026-10-06 export) and replayed with `DwFormEngine` on the 10 panels of spec 46203, rev 6 and rev 7, 2026-10-08.*

DW Hopper V2 - Panels builds one drop-zone panel per spec, hosted by DW Hopper V2 (see [../hopper-v2/logic.md](../hopper-v2/logic.md), section 1). These diagrams show:
- how the inputs V2 sends pick one of the 147 panel shapes;
- how the top edge of a panel is computed;
- where the triangle panels break.

**Red nodes** are problems found. They are explained in [learnings.md](learnings.md). Every input is described in [../inputs/hopper-v2-panels-inputs.md](../inputs/hopper-v2-panels-inputs.md).

## 1. From V2's inputs to one panel family

```mermaid
flowchart TD
    IN["Inputs from V2's PanelListInput<br/>names matching a control set the control,<br/>names matching a constant set the constant (Hosted…, PushedDown…)"] --> SIDE["PanelSideLocation: R, L or B"]
    IN --> PROF["BackLineProfile, FrontLineProfile, SideProfile"]
    PROF --> NUM["PanelNomenclatureNumberEquivalent<br/>side wall: back × 100 + front × 10 + side<br/>back wall: back × 100 + 10 + front"]
    SIDE --> FAM["Family = letter + number<br/>e.g. R531, L615, B514"]
    NUM --> FAM
    FAM --> SETS["147 component sets: DW09B-xNNN-BL -with Onsite Bolts<br/>(56 R, 56 L, 35 B)<br/>file-name rule PanelWithOnsiteBoltName(letter, MyNumber(2))"]
    SETS -->|"the matching set"| KEEP["prefix-A3x-Krc-colour-YD-with Onsite Bolts"]
    SETS -->|"every other set"| DEL["Delete"]
    KEEP --> PARTS["The family's parts (1LBF, 2LF or 2LBF, 3LF or 3LBF):<br/>sizes, gussets, bolt-zone and flange-hole patterns"]
    IN --> REL["Macro Release (run by V2):<br/>transition ReleaseAutopilot or ReleaseLocal"]
    REDX["Red X in SOLIDWORKS on spec 46203:<br/>back bottom row B114 / B514, both revisions<br/>side K11 (x115 / x615) and K20 (x131), both revisions<br/>side K10 only as x531 (back angle on)"]:::bug
    PARTS -.-> REDX
    classDef bug fill:#fde2e2,stroke:#c0392b,color:#7b1d1d
```

- **On spec 46203:**
  - side K10 is family 131, or 531 with the back angle;
  - K11 is 115, or 615;
  - K20 is 131;
  - the back's bottom row is B114, or B514 (V2's profile number 124 becomes 114, because the back formula fixes the middle digit at 1);
  - the back's top row is B111, or B611.
- The dimension sweep found no zero or negative value that separates the panels with a red X from the ones without, except the triangle width below. Pattern counts of 0 also appear on panels that build fine (A30-K21/K31).

## 2. Top edge length (TopSideLength)

```mermaid
flowchart TD
    T0["TopSideLength starts at PanelLength"] --> FC{"First-column panel (K10, K11, K12)?"}
    FC -->|no| SP
    FC -->|yes| BL{"BackLineProfile"}
    BL -->|1| B1["+ 0"]
    BL -->|2| B2["+ H ÷ tan(BackAngle)"]
    BL -->|3| B3["+ End ÷ tan(BackAngle)<br/>− (H − End) × tan(90 − ConveyorAngle)"]
    BL -->|4| B4["+ (H − Start) ÷ tan(BackAngle)"]
    BL -->|5| B5["+ (End − Start) ÷ tan(BackAngle)<br/>− (H − End) ÷ tan(90 − ConveyorAngle)"]
    BL -->|6| B6["− H ÷ tan(BackAngle)"]
    BL -->|7| B7["− (H − Start) ÷ tan(BackAngle)"]
    B1 --> SP
    B2 --> SP
    B3 --> SP
    B4 --> SP
    B5 --> SP
    B6 --> SP
    B7 --> SP
    SP{"SideProfile"}
    SP -->|1| S1["− 0"]
    SP -->|"2, 3"| S2["− (H − CSideCutLength) ÷ tan(ConveyorAngle)"]
    SP -->|4| S4["− H ÷ tan(ConveyorAngle)"]
    SP -->|5| S5["− PanelLength (triangle: no top edge)"]
    BUG3["Profile 3 multiplies by tan(90 − ConveyorAngle)<br/>where profile 5 divides by it"]:::bug
    BUG2["Side profiles 2–4 use ConveyorAngle;<br/>TopCutAngle looks intended"]:::bug
    BUG5["Side 5 with back line 6: −0.675 in (rev 7, K11)"]:::bug
    B3 -.-> BUG3
    S2 -.-> BUG2
    S5 -.-> BUG5
    classDef bug fill:#fde2e2,stroke:#c0392b,color:#7b1d1d
```

- H = PanelHeight; Start and End = DimForStart/EndOfBackAngle.
- Neither revision of spec 46203 used side profiles 2–4 or back line 3, so those two suspicions are untested.

## 3. Triangle panels and the C-side flange

```mermaid
flowchart LR
    CUT["V2: the top cut runs corner to corner<br/>(SideProfile 5)"] --> CS["CSideCutLength = 0<br/>(no head edge left)"]
    CS --> W["x615-3LF Width@Sketch1<br/>= CSideCutLength − 2 × thickness − 1/32"]
    W --> NEG["0 − 0.25 − 0.031 = −0.281 in"]:::bug
    NEG --> ERR["Rebuild error on A31/A32-K11 (rev 7)"]:::bug
    classDef bug fill:#fde2e2,stroke:#c0392b,color:#7b1d1d
```

- **Likely fix:** delete the C-side part when `SideProfile = 5`, once SOLIDWORKS shows that the family's mates survive without it. Limiting V2's top cut (see [../hopper-v2/logic.md](../hopper-v2/logic.md), section 2) makes these triangles rarer, but K11 can still be one.
