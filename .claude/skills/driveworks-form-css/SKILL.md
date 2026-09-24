---
name: driveworks-form-css
description: Author or edit DriveWorks form CSS (ProjectStyles.css / GroupStyles.css) for DriveWorks Live and web forms - dw- custom elements, ::part() selectors, data-metadata tokens, :host design tokens. Use when styling DriveWorks forms or controls, or when asked about the Metadata property's CSS effect.
---

# DriveWorks form CSS

*Ported from `DriveWorks Files/.github/copilot-instructions.md` (written for DriveWorks Pro 23). The live file is `DriveWorks Files/ProjectStyles.css`.*
Official docs: [CSS Styling for User Forms](https://docs.driveworkspro.com/Topic/ProjectEditorFormDesign#HowTo), [Customize DriveWorks Live Form CSS](https://docs.driveworkspro.com/Topic/CustomizeDriveWorksLiveFormCSS).

## Files
- `ProjectStyles.css` sits next to the `.driveprojx` it styles.
- `GroupStyles.css` sits in the group content folder and applies to every project. It uses the same format.
- Both reload live: saving updates the Form Designer preview immediately.

## File structure (keep this order)
1. `:host { ... }` design tokens. Use **`:host`, never `:root`** (Shadow DOM).
2. Template metadata rules (navigation buttons, summary headers).
3. Animation helpers: `[data-metadata*="animate*"]`.
4. One section per `dw-` element, **alphabetical**, with the header comment `/* Control Name ---...--- */`.
5. Sparta-specific overrides at the bottom.

## Targeting controls
Controls are custom elements with Shadow DOM. **Style internals with `::part()`**. Descendant selectors can't pierce the shadow root.

```css
dw-text-box[data-metadata*="styled"]::part(input) { ... }   /* correct */
dw-text-box[data-metadata*="styled"] input { ... }          /* WRONG - no effect */
```

| Control | Tag | Parts |
|---|---|---|
| Check Box | `dw-check-box` | `checkbox`, `check` |
| Combo Box | `dw-combo-box` | `select`, `arrow` |
| Data Table | `dw-data-table-control` | `list`, `list-view`, `header`, `row`, `row-selected`, `heading-cell`, `heading-action`, `row-cell`, `row-selected-cell`, `arrow-up`, `arrow-down` |
| Date Picker | `dw-date-picker` | `input`, `native-input`, `icon` |
| List Box | `dw-list-box` | `list-box`, `list-item`, `list-item-selected` |
| Macro Button | `dw-macro-button` | `button`, `picture`, `text` |
| Measurement Text Box | `dw-measurement-text-box` | `measurement-input`, `input`, `select` |
| Numeric Text Box | `dw-numeric-text-box` | `input` |
| Option Button | `dw-option-button` | `option`, `radio`, `dot` |
| Option Group | `dw-option-group` | `legend`, `fieldset`, `option`, `radio`, `dot` |
| Slider | `dw-slider` | `caption`, `handle`, `min-label`, `max-label` |
| Spin Button | `dw-spin-button` | `spin-button`, `input`, `button` |
| Text Box | `dw-text-box` | `input` |
| Upload Control | `dw-upload-control` | `button` |

DriveWorks doesn't guarantee its markup between versions. **Target `data-metadata`, never generated ids.**

## Metadata tokens
The control's `(Metadata)` property becomes `data-metadata`. In the project XML this is the control's `<Metadata>` property, which you can set with `Set-DwControlProperty -Property Metadata -Value 'styled alt'`.
Prefer `*=` (contains) so a control can carry several tokens. Use `=` for exact matches and `~=` for whole words.

| Token | Purpose |
|---|---|
| `styled` | Base design-system styles |
| `alt` | Outline button variant |
| `animate` / `animate-layout` / `animate-size` / `animate-width` / `animate-height` / `animate-position` | Transitions: all / width+height+margin / width+height / width / height / margin |
| `navigation-button` | Sidebar nav button, icon plus collapsible text |
| `summary-header` | Header button with reversed icon layout |
| `project-list-style` | Card-style data-table rows with shadow |

## Design tokens (`:host`)
Use only the variables. To retheme, change `:host`, not individual rules.
`--control-color-primary` (#374151), `-primary-hover`, `-primary-text`, `--control-color-light`, `-light-hover`, `--control-color-border`, `-border-hover`, `--control-radius`, `--input-radius`, `--button-radius` (100rem, pill), `--control-padding`, `--input-padding`, `--button-padding`, `--input-gap`, `--input-size`, `--icon-color`, `--icon-size`, `--animation-speed` (100ms), `--animation-curve` (ease).

## Conventions
- Use `rem` for spacing and sizing. Use `px` only for borders and shadow offsets.
- Hover, active, and focus states transition via `--animation-speed` and `--animation-curve`.
- Reset with `border: none`, then add borders back selectively.
- Use `!important` **only** to beat an inline `style=""` that DriveWorks injects, for example the `::part(row)` background on `project-list-style`.

## Adding a style
1. Set the control's Metadata, for example `styled my-token`.
2. Add a rule in the control's alphabetical section: `dw-<control>[data-metadata*="my-token"]::part(<part>) { ... }`.
3. Use `:host` variables for all visual values.
