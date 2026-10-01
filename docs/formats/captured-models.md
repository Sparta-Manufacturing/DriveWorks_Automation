# Captured models and model rules

How a SOLIDWORKS capture, which lives in the **group**, connects to the model rules, which live in the **project**. Everything here is verified against the Sparta sandbox group, which has 3,658 captures.

```
SOLIDWORKS + DriveWorks add-in
        | capture
        v
.drivegroup  CapturedComponents.Data  (XML, ns c-component)        project .driveprojx  components/<n>.xml  (ns p-component)
  <ccomp:C Id=CC  P=model path>   <---------------- CCRef --------------  <pcomp:PC CCRef=CC>
    <ccomp:E Id=E  N A T S>       <---------------- CERef --------------    <pcomp:PE CERef=E>
      <ccomp:P Id=P N A T S/>     <---------------- CPRef --------------      <pcomp:PP CPRef=P RId><pcomp:R>=rule</pcomp:R></pcomp:PP>
```

`Get-DwModelRule` does this join for you. Ids appear with and without dashes, so always normalise before comparing.

## Capture XML (`CapturedComponents.Data`)

| Element | Attributes |
|---|---|
| `ccomp:C` | `Id`, `P` (model path), `T` (`PartFactory` / `AssemblyFactory` / `DrawingFactory`) |
| `ccomp:E` (element) | `Id`, `N` (DriveWorks name), `A` (SOLIDWORKS name), `T` (element type), `S` (for features, the SOLIDWORKS feature type, e.g. `HoleWzd`, `Cut`, `LibraryFeature`) |
| `ccomp:P` (parameter) | `Id`, `N` (DriveWorks name, e.g. `CageHeight`), `A` (SOLIDWORKS name, e.g. `CageHeight@Sketch1`), `T` (parameter type), `S` (e.g. `.STEP` for a file format) |
| `ccomp:A` | `N`, `V`: extra attributes (e.g. file format extension) |

The root `E` has an all-zero `Id`. Feature **suppression** parameters have no name of their own; the name is on the parent feature `E`.

`CapturedComponents.ReferenceData` = the ids of **referenced child captures**, as concatenated 16-byte GUIDs (the assembly/drawing reference tree). 4,378 of 4,379 resolve.

## Type ids

From `DriveWorks.SolidWorks.Components.Constants` (read from the DriveWorks 24.0.1.4 IL). `DwTools` maps these to the short names in the **Kind** column.

| Kind | Constant | Id |
|---|---|---|
| Dimension | `ID_PARAM_TYPE_DIMENSION` / `ID_EL_TYPE_DIMENSION` | `4ee71b52374c40f6a28fe97326eb46a4` |
| Feature (element) | `ID_EL_TYPE_FEATURE` | `c0a701eca33f43cd8fc30900650eae7d` |
| FeatureSuppressionState | `ID_PARAM_TYPE_FEATURE_SUPPRESSION_STATE` | `d1d950c05a6a44e1b316a9a6ed3470d4` |
| FeatureExtra (pattern spacing, skipped instances) | `ID_PARAM_TYPE_FEATURE_EXTRA` | `ee14582e29fc4b44b670d98a910463f5` |
| FeatureAdditionalState | `ID_PARAM_TYPE_FEATURE_ADDITIONAL_STATE` | `1a11269b24d646fcbbe723ba02021004` |
| CustomProperty | `ID_PARAM_TYPE_CUSTOM_PROP` | `ccf239a84e644c9283ce945c547b84bb` |
| Configuration | `ID_PARAM_TYPE_CONFIGURATION` | `16512885644f463fb548b53e6df9ba67` |
| Instance (assembly component) | `ID_PARAM_TYPE_INSTANCE` | `7849e9c8e07146938b2636da17112d5c` |
| ComponentReference (replacement) | `ID_PARAM_TYPE_COMP_REF` | `f2c4e8f5ae0a4ca1bf0d4e36d3aceb2f` |
| FileFormats (element) / FileFormat | `ID_EL_TYPE_FORMATS` / `ID_PARAM_TYPE_FILE_FORMAT` | `ade7b1ae…` / `63a61a18…` |
| DimensionValue, DimensionTolerance* | `ID_PARAM_TYPE_DIMENSION_VALUE`, `…_TOL_TYPE/LOWER/UPPER`, `ID_EL_TYPE_DIMENSION_TOL` | `8c59824a…`, `40045e6b…`, `615c8532…`, `a9ccb4a2…`, `6bd70a08…` |
| Drawing: Sheet, SheetState, View, ViewState, ViewTop/Left, ViewScaleNumerator/Denominator, ViewDimension, ViewBreakLine*, Layer, LayerVisibility, DrawingAnnotation | `ID_EL_TYPE_SHEET`, `ID_PARAM_TYPE_SHEET_STATE`, ... | see `$script:CaptureTypes` in `DwTools.psm1` |
| Tasks (element) | `ID_EL_TYPE_TASKS` | `338ac69ce248468c84fd0cb7399abb1e` |

## Project side (`components/<n>.xml`)

The serializer class names come from `DriveWorks.Engine.dll` (`DriveWorks.Projects.Components.*`).

| Element | Class | Meaning |
|---|---|---|
| `pcomp:CS` | `ComponentSetRootElement` | Root. One part per top-level component set. |
| `pcomp:PC CCRef TrId LoopEnabled LoopFileFormats` | `ComponentElement` | A driven component. It nests: child components are `PC` children of the parent `PC`. |
| `pcomp:CN` | `ComponentNameElement` | **New file name** rule (`"Delete"` removes the component) |
| `pcomp:CP` | `ComponentPathElement` | **Output folder** rule |
| `pcomp:CT` | `ComponentTagsElement` | **Tags** rule |
| `pcomp:LC` | `LoopCountElement` | **Loop count** rule |
| `pcomp:PE CERef` | `ComponentElementElement` | Mirrors a capture `E` |
| `pcomp:PP CPRef RId` | `ComponentParameterElement` | Mirrors a capture `P`. `pcomp:R` = the rule, `pcomp:C` = the comment. A `PP` can exist with no rule. |

**A captured parameter with no rule is left alone.** DriveWorks does nothing to it, so the item keeps the state saved in the SOLIDWORKS model. At Sparta, parts and instances are **usually saved unsuppressed**, so an instance with no rule normally **stays in**. (Confirmed by Jonathan, 2026-09-23.) When you analyse a project, treat "no rule" as "present", not "absent".

**How DriveWorks reads an instance rule result.** Checked in `DriveWorks.SolidWorks.dll`, `DriveWorks.SolidWorks.Components.ReleasedAssembly.ReleaseInstance`, on 2026-09-30 (this corrects the 2026-09-28 note, which described the Engine's component file-name handler instead):
- The result is split on `|`. Each part is trimmed and handled on its own, so one rule can both replace and set a state. For example, `"S|<Replace>DW10-A50"` means replace with the `DW10-A50` set and **suppress** it.
- **Order doesn't matter.** A `<Replace>` part is registered wherever it sits, and the state is kept in one slot. `"<Replace>DW10-A50|S"` is identical. With two state words (`"S|U"`), the **last one wins**.
- Replace: `<Replace>ComponentSet` or `<ReplaceFile>path`, as a case-insensitive prefix.
- State words are matched case-insensitively and must be the **whole part**:
  - delete: `delete`;
  - suppress: `suppress`, `s`, or `false`;
  - unsuppress: `unsuppress`, `u`, or `true`;
  - hide / show: `hide` / `show`.
- **No angle-bracket state words here.** `<delete>`, `<suppress>` and the other bracketed forms are read only by Engine code (`ReleaseComponentHelper` for component file-name rules, `DocumentUtility.IsSuppressionResult`, `TriggeredAction`). In an instance rule they fall through as an unrecognised part. No Sparta instance rule uses them (checked 2026-09-30).
- A boolean rule such as `If(cond, TRUE, "Delete")` therefore works: `TRUE` means unsuppress.
- After the loop, DriveWorks rewrites the value as `<state>|<last unrecognised part>` and passes that on to generation.

**A newly captured parameter has no `PP` until someone gives it a rule.** `Get-DwModelRule -Unassigned` lists those parameters. Writing a rule onto a new `PP` means creating the `PP`, and possibly the `PE`, with a new `RId`. That isn't implemented yet and needs validation in Administrator first (see [the analysis](../analysis/api-vs-xml.md)).

## Numbers (sandbox, 19 projects excl. `Restored Files`)

- 103,409 model rules resolved to named parameters.
- 32 rules point at a parameter id that is no longer in the capture, and 52 at a capture no longer in the group. These are probably stale rules from re-captures or removed models, and are worth an audit.
