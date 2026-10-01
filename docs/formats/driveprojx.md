# `.driveprojx`: DriveWorks project file

> Reverse-engineered from the 19 Sparta projects (DriveWorks 24, `Version="14.0"`). This isn't official documentation.
> Anything marked *(inferred)* is a best guess from observation.

## Container

An **OPC package**, the same container format as `.docx`. It's a ZIP with `[Content_Types].xml` and `_rels/`. DriveWorks writes it with .NET `System.IO.Packaging`; you can tell from the `0xA220` "growth hint" extra field in the ZIP headers.
Always read and write it with `System.IO.Packaging` (`WindowsBase.dll`), never with a generic zip tool. `DwTools` does this for you.

| Part | Content | Relationship type |
|---|---|---|
| `/driveProj/project.xml` | Forms, controls, documents, macros, flow, categories, tables | `http://schemas.driveworks.co.uk/project/` (package root) |
| `/driveProj/designMaster.xml` | **Variables, constants**, special variables, navigation | `DriveWorksDesignMaster` (package root) |
| `/driveProj/componentTasks.xml` | Model generation tasks (before/after tasks per component) | `ComponentTasks` (package root) |
| `/driveProj/customSections.xml` | Editor metadata (Form Designer guides, etc.) | `http://schemas.driveworks.co.uk/project-metadata/` (from `project.xml`) |
| `/driveProj/components/<n>.xml` | Driven model rules, one part per captured top-level component | `http://schemas.driveworks.co.uk/p-component/` (from `project.xml`) |

Byte-level facts that matter when writing:
- Parts differ in whether they have a **UTF-8 BOM**. For example, `componentTasks.xml` has one and `project.xml` doesn't.
- Parts differ in **compression**. `customSections.xml` is `Normal`, and most others are `NotCompressed`.
- `DwTools` preserves both, plus the newline style. The round-trip test shows the output is byte-identical.

## `project.xml`

Root: `<project:Project xmlns:project="http://schemas.driveworks.co.uk/project/">` with attributes:

| Attribute | Example |
|---|---|
| `Version` | `14.0` (file format version; `Web Kit Conveyor` is `10.0`) |
| `GroupConnectionString` | `Provider=RemoteGroupProvider;Server=SPA-DWP;Name=Sparta Manufacturing Group;` |
| `MetadataDirectoryName` | `DriveWorksFiles` |
| `ReportingLevel` | `Verbose` |

Top-level sections, all under the `project:` namespace:
`DataTables`, `VariableCategories`, `ConstantCategories`, `Documents`, `ComponentSets`, `ChildSpecificationDefinitions`, `ItemListDefinitions`, `SpecificationProperties`, `Forms`, `SpecificationMacros`, `SpecificationMacroCategories`, `SpecificationFlowOverride`, `CalculationTables`, and `ProjectReferences` (in 5 of 19 projects).

**Simple tables.** In `project.xml`, a simple table is only a stub: `<project:DataTable Type="DriveWorks.SimpleDataTable…"><…DirectInputDataTable/>`.
- Its **data** is in `designMaster.xml`, under `/TDM/Tables/Table[@Name='DWLookup<Name>']`.
- The data is a CDATA block of comma-separated rows.
- Row 1 is the header that `TableGetColumnIndexByName` searches.
- Rules refer to the table as `DwLookup<Name>`.

### Forms and controls

```xml
<project:Forms>
  <Form Name="Details">
    <Visible IsStatic="True"><Value>True</Value></Visible>   <!-- form-level properties -->
    ...
    <Controls>
      <CheckBox Name="DevRelease">
        <Left IsStatic="False"><Rule>=Release.Left - DevRelease.Width - 10</Rule></Left>
        <Width IsStatic="True"><Value>135</Value></Width>
        <Visible IsStatic="False"><Rule>=DWVariableIsUserInDevelopement</Rule></Visible>
        ...
```

- **Namespace trap:** `Form`, `Controls`, each control, and each property element are in the **default namespace `pa-namespace:DriveWorks.Forms,DriveWorks.Engine`**. Plain XPath such as `//Form` matches *nothing*. Use `Select-DwXml` with the `f:` prefix, for example `//f:Form[@Name='Details']/f:Controls/*`.
- **Control element name = control type**: `CheckBox`, `TextBox`, `Label`, `PictureBox`, `ComboBox`, `NumericTextBox`, `FrameControl`, `MacroButton`, `SpinButton`, `Slider`, `DataTableControl`, `SpecificationHostControl`, `Hyperlink`, `PreviewControl`, `ToggleSwitch`.
- **Every property is a child element** holding **either `<Value>` (static) or `<Rule>` (formula starting with `=`)**. `IsStatic="True"` properties *never* hold a rule. Read it as "this property can't be rule-driven". `Set-DwControlProperty` enforces this. Counts across all projects:
  - `IsStatic="True"` + `<Value>`: 69,087
  - `IsStatic="False"` + `<Value>`: 18,869 *(a rule-capable property currently holding a plain value)*
  - `IsStatic="False"` + `<Rule>`: 7,499
  - Occasionally `<Rule>` + `<Comment>`, or empty.
- Controls are flat inside a form. A `FrameControl` embeds *another form* by name (`FormName` property). It doesn't nest controls.

### Documents

`<project:Document Name="..." Type="<.NET type>, <assembly>">` contains `<project:ProviderData>` (type-specific settings) and `<project:Rules><project:Rule Id DisplayName><project:Formula>=...</project:Formula>`.
Types in use: `DriveWorks.Email` (28), `GroupTableExport` (18), `Thor...ThorProjectDocument` (7), `SqlServerExport` (7), `TriggeredAction` (5), `WordDocument` (4), `ReferencedFile` (2), `ExcelDocument` (2).

### Specification macros and flow

`<project:SpecificationMacro Name ConsistencyLevel>` contains `<project:Tasks><sf:Task Title Type Left Top>`. Each task has `sf:Properties`, `sf:Conditions`, and more. Most-used task types: `DriveControlValueTask`, `InvokeSpecificationTransitionTask`, `DesignMasterMacroTask`, `DriveConstantValueTask`, `CancelSpecificationTask`, `ReleaseDocumentsTask`.
`SpecificationFlowOverride/SpecificationFlow` holds `State`s with `Transitions`, `Operations`, and `OnEnterEvent`/`OnLeaveEvent`.

## `designMaster.xml`

Root `<TDM>`. It has no namespace.

```xml
<Constants><Constant DisplayName="ShortCornerOffset" StoreName="DWConstantShortCornerOffset" Value="2.125" Comment="" /></Constants>
<SpecialVariables><SpecialVariable StoreName="DWSpecification" Rule="DWVariablePrefixClientWO &amp; &quot;-&quot; &amp; ..." /></SpecialVariables>
<Variables><Variable DisplayName="Client" StoreName="DWVariableClient" Rule="If(DWVariableNewClientProject, ...)" Category="<category UniqueId>" Comment="" /></Variables>
<Navigation><Step Type="Start|Form|Finish" Name="Details" NextStepRule="&quot;Finish&quot;" ... /></Navigation>
<Messages/>  <Controls/>  <Tables/>
```

- `Category` is the `UniqueId` of a `project:Category` in `project.xml` under `VariableCategories`. Categories can nest.
- Variable rules here have **no leading `=`**, unlike control rules in `project.xml`.
- Multi-line rules live in attributes as `&#xD;&#xA;` entities, and tabs as `&#x9;`. `XmlDocument` decodes and re-encodes these losslessly.

## Rule naming conventions

| In a rule | Refers to |
|---|---|
| `DWVariable<Name>` | Variable `<Name>`; the `StoreName` is `DWVariable<Name>` |
| `DWConstant<Name>` | Constant `<Name>` |
| `DWSpecification`, `DWProjectName`, `DWSpecificationId`, `DWCurrentUserName`, ... | Special variables |
| `<ControlName>` or `<ControlName>.<Property>` | Form control value or property, bare name (for example, `Release.Left`) |

A rename means rewriting every occurrence across **all parts**. That's why renames belong to the API or Administrator (see [analysis](../analysis/api-vs-xml.md)).

## `components/<n>.xml` (driven models)

Namespace `pcomp = http://schemas.driveworks.co.uk/p-component/`, prefix `pcomp:` in `Select-DwXml`.
**The full, verified reference is in [captured-models.md](captured-models.md).** In short:
- `PC` (`CCRef` = capture id) holds the component-level rules: `CN` file name, `CP` path, `CT` tags, `LC` loop count.
- `PE` and `PP` mirror the capture's elements and parameters, with `PP/pcomp:R` holding the rule.
- **The top-level file-name rule is stored twice**, and the two copies are byte-identical in every Apron set:
  - `/p:Project/p:ComponentSets/p:ComponentSet/p:Rule` in `project.xml`;
  - the root `/pcomp:CS/pcomp:PC/pcomp:CN/pcomp:R` of the set's part, found via `ComponentSet/@RId` → `project.xml.rels`.

  Edit both copies together with `Set-DwComponentSetRule`.

Rules look like `<pcomp:R>=If(DWVariableNumberOfOpening&gt;1,TRUE,"Delete")</pcomp:R>`.
**Parameter names such as `CageHeight@Sketch1` are stored only in the group's capture data**, so resolve them with `Get-DwModelRule -Group <file.drivegroup>`.

## `componentTasks.xml`

`<comp-task:ComponentTasks>` contains `<comp-task:ComponentSpecific>` → `<comp-task:Task Id Type Name Location="Before|After" Index ComponentId>` with `Rules`, `ReleaseConditions`, and `RuntimeConditions`.
