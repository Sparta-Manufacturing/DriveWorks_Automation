# How forms run in DriveWorks' rule engine

*Read from `DriveWorks.Engine.dll` and `Titan.Rules.dll` (24.0.1.4) on 2026-10-02, and checked by running the real engine through `tools/DwTools/DwFormEngine.psm1`.*

DriveWorks evaluates every variable, constant and control property in one spreadsheet-like engine, **Titan** (`Titan.Rules.Execution.ExecutionEngine`). Each item is a named **slot** that holds a rule or a value. Slots sit in **scopes**. A slot recalculates when anything its rule refers to changes.

## Slot names

| Item | Slot | Example |
|---|---|---|
| Variable | global `DWVariable<Name>` | `DWVariablenone` |
| Constant | global `DWConstant<Name>` | `DWConstantftMaximumSectionLength` |
| Special variable | global, its store name | `DWCurrentUserName`, `DWSpecificationId` |
| Project lookup table | global `DWLookup<Name>`, a 2-D array whose first row is the header | `DWLookupSkimaintenancePosition` |
| Group table | global `DWGroupTable<Name>` | `DWGroupTableColors` |
| Control property, non-store | `<Control>.<Property>`, inside a scope named after the control | `CommonSpecsFrame.Height`, `skimaintenance.DefaultValue` |
| Control property, store | a **global** slot, named control + suffix | see the next table |

Store properties (`DynamicProperty.GetStandardStoreName`):

| Store | Global slot | Properties that use it |
|---|---|---|
| Source | `<Control>`, the bare name | `SelectedItemSource`, `CheckedSource`, `TextSource`, `ValueSource`, `Source`: **the raw user input** |
| Value | `<Control>Return` | `SelectedItem`, `Checked`, `Text`, `DisplayValue`, `Value` |
| ListData | `<Control>ListData` | `Items` |
| Minimum / Maximum | `<Control>Min` / `<Control>Max` | |
| Increment | `<Control>Default` (legacy name) | |
| Enabled / Visible | `<Control>Enabled` / `<Control>Visible` | |
| MessageCode | `<Control>Error` | `Error` |

So in a rule:
- `skimaintenance` is the box's **raw input**, and `skimaintenanceReturn` is its **value**.
- `beltsup.Height` reads a property.
- `OilerPositionListData` is the item list as a pipe string.
- Names are case-insensitive: `beltsup.top` works.

A form is a control too (type `Form`), with its own store slots.

## Loading (`TitanControlDataProvider.LoadCore`)

- A property with a `<Rule>` gets that rule, with the leading `=` stripped. One with only a `<Value>` gets the value.
- A missing Value-store property gets the default rule `IF(<Control>="","",<Control>)`: the value is the raw input.
- When the user types, DriveWorks sets the Source slot. **Setting a value on a slot clears its rule.**

## List controls (`ListControlBase.Validate`)

ComboBox and the other list controls re-check their selection whenever their items change:
1. If the value is still in the list, keep it. Matching is exact (`Array.IndexOf`, case-sensitive). A blank value counts only if `AllowClearSelectedItem` is on.
2. If `SelectedItem` has a rule other than the default one, stop. The value stays invalid.
3. If a value removed earlier is selectable again, restore it. Otherwise remember the current value for later.
4. Otherwise pick the first item if `SelectedItemRemovedBehavior` is `SelectFirst` (the default), or clear the value.

`Items` is split on `|` and **keeps empty entries**: `"None|"` is `None` plus a blank item, and `"|A21"` starts with a blank. Two lists joined without a `|` merge their touching items: `"None" & "A02|A03"` gives `NoneA02|A03`.

## Numeric controls

`Validate()` writes the control's **effective value** back to its value. Read from the IL on 2026-10-09.

| Control | Effective value | Rounding property |
|---|---|---|
| `Slider` | Clamped to Minimum and Maximum, then `Round(value / Increment, 0) * Increment` | `Increment` (0.01 keeps hundredths; 1 gives whole numbers) |
| `NumericTextBox` | Rounded to `EffectiveDecimalPlaces`, then clamped to Minimum and Maximum | `DecimalPlaces`. -1 (the default) or anything outside 0–15 means 15, so no rounding. |

- **`NumericTextBox` has no Increment in the engine.** The `<Increment>` element saved with it is ignored.
- **A changed `DefaultValue` resets a numeric text box's value** (`OnValueChanged`). So a box whose DefaultValue is a slider's `Return` ends up with the slider's snapped value, and takes the slider's step.
- `DwFormEngine` doesn't run `Validate()`, so it doesn't show this snapping.

## Evaluation facts that matter for rules

- `MyName()` and `MyNumber(i)` read the **owner's name**: the variable name without `DWVariable`, the calculation-table cell, or in a model rule `<component set>\<instance>` (for example `SA5 (Apron Conveyor Assembly)\DummyASMA -11`; confirmed for instance rules only). Numbers are runs of adjacent digits. Index 1 counts from the left, -1 from the right.
  - The engine needs an `IMyNameNumberProvider`, passed to the `ExecutionEngine` constructor. Titan's default provider throws, which stops the whole update.
  - `DwFormEngine` supplies `DwNameNumberProvider`.
- `If(c, a, b)` is lazy: an error in the branch not taken doesn't propagate. `IfError(x, y)` and `IfEmpty` are built into the parser, not functions.
- **An error propagates through every rule that reads it.** One failing Height breaks every Top/Height sum after it. On a form, that means every frame below it.
- Arithmetic: `5 + FALSE` = 5, `5 + TRUE` = 6, but **`5 + ""` is an error** (`ConvertFailed`).
- String `=` ignores case (`"None"="none"` is TRUE). `Value.IsEqual` calls `String.Compare(a, b, ignoreCase: true, culture)`.
- `ExtractNumber` returns a Double: `"A03"` → 3, `"NoneA02"` → 2, `"None"` and `""` → NaN. So `Indirect("X" & ExtractNumber(""))` fails with `ValueException`.
- `Indirect` of a name that doesn't exist gives `UnrecognizedReference`.
- `RoundUp(-0.1, 0)` = −1 and `Mod(-1, -1)` = 0.

## Calculation tables (`ProjectCalculationTableSlotTable`)

- **Structure.** A calculation table is a Titan `SlotTable` named `DWCalc<Name>` with `RowCount + 1` rows. Row 0 holds the column names, which is how `TableGetColumnIndexByName` works. Data row r (1-based) gets the column's rule for XML `RowIndex` r−1, or else the column's `CommonRule`.
- **Relative references.** Cell rules can point at neighbouring cells: `[1U]` is one row up, `[1D]` one row down, `[2L]` two columns left, `[1R]` one column right, and they combine as `[1U,1L]` or `[7L,1D]`. They depend on single cells.
- **Never read the table from inside itself.** A formula inside the table that reads the table by name, directly or through a variable such as `TableFilter(DWCalcX, …)`, is circular, because the table value depends on every cell. To look past rows, add a helper column computed with relative references (see `apron-sa-last-marker` in `tracking/items.json`).
- **Indexing.** `TableGetValue(table, column, row)` takes the **column first**. Columns are 1-based. Row 0 is the header and returns blank.

## Not modelled by DwFormEngine

Macros, the specification flow, documents, model rules, database queries (`QueryData` returns blank) and Pro Server functions (`SppGetTeamsDataForUser` returns the `-Teams` you pass). A new specification starts each control at its evaluated `DefaultValue`, else at its saved Source value. That matches what Administrator shows, but the code that applies defaults wasn't found.
