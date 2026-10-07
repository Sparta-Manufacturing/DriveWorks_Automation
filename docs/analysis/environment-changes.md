# Environment changes: every rule to change, per project

*Generated 2026-10-06 from the dev copy of all 18 registered projects: 49 rules. Every new rule was evaluated in DriveWorks' rule engine with a test `Environments` table:*
- *8 become **relative paths**, like the other rules of the same kind. Each one, resolved against the project's folder, gives exactly today's prod file, and that file exists in dev.*
- *41 use the `Environments` **lookup**: location variables, SQL servers, debug exports and one email attachment. As prod, each gives today's value, except the 8 debug exports (marked **moved**), which leave the personal OneDrive folder on purpose. As dev, they point at the dev locations.*
- *No new rule is in error, in either group.*

*Decision record: [dev-prod-workflow.md](dev-prod-workflow.md). Tracked item: `env-no-hardcoded-prod-locations`.*

## 1. Group table `Environments` (create it in each group)

One row per group. Both groups get **both rows**, so copying the table either way does no harm. In rules, the table is `DWGroupTableEnvironments`.

| GroupName | Environment | InputRoot | OutputRoot | DbServer | DbServerDW |
|---|---|---|---|---|---|
| Sparta Manufacturing Group | Prod | `\\192.168.0.19\Driveworks Input Files\` | `\\192.168.0.19\Driveworks Output Files\` | `192.168.0.19\SQLEXPRESS` | `192.168.0.19\SQLEXPRESSDW` |
| Sparta DW Group for Claude | Dev | `C:\Users\jonars\GitHub Projects\DriveWorks_Automation\DriveWorks Files\` | `C:\Users\jonars\GitHub Projects\DriveWorks_Automation\DriveWorks Files\Specifications\` | `192.168.0.19\SQLEXPRESS` | `192.168.0.19\SQLEXPRESSDW` |

- **`GroupName` must be exactly what `GetGroupName()` returns.** Test it in each group first. The two names above are assumptions.
- **Folder values end with `\`.** The rules append sub-paths directly (`… & "Apron\"`).
- **Dev uses the production database for now** (decision 2026-10-06), so both rows have the same server. Change the dev row when a dev copy of SpartaDWdata exists.

## 2. New variable in every project (create it in Administrator)

**`IsProductionEnvironment`**, category Environment. Rule:

```
IfError(
   DWVLookup(GetGroupName()
      ,DWGroupTableEnvironments
      ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
      ,TableGetColumnIndexByName(DWGroupTableEnvironments,"Environment")
      ,FALSE)
   = "Prod"
   ,FALSE)
```

**TRUE only in a group whose `Environments` row says `Prod`.** An unknown group, or a missing table, gives **FALSE**. No rule uses it yet: the email changes are on hold (decision 2026-10-06). It's the switch for anything that should behave differently in dev later. The lookups in section 3 read the table directly by group name, so a missing row makes them fail instead of falling back to production.

## 3. Rules to change (one block per item)

The table is an index: click a number to jump to that item's old and new rules, below the table. Copy each **new rule** block as is, line breaks included; the rule builder keeps them. Rules are shown as the rule builder shows them, without the leading `=` that the project file stores on control, document and macro rules. The rule builder rejects a pasted `=`.

- **Relative paths** are used where a rule points straight at an input file (form pictures, a Drive3D file). DriveWorks resolves them against the project's own folder, which is how the other form pictures and Drive3D files already work (for example 252 of Kit Conveyor's 253 Drive3D rules). `..\` is the group content folder. They need no lookup, and they work in both groups.
- **Lookups** are used for every location variable (input and output folders), so a change of the dev location is one row in the table, and for the SQL servers and the email attachment. The lookup finds the group's row by the `GroupName` column by name, so column order in the table doesn't matter.

| # | Project | What to change | Note |
|---|---|---|---|
| [1](#item-1) | Apron Project | Control PictureBox1.FileName (form CommonSpecs) | relative |
| [2](#item-2) | Apron Project | Variable DataBaseServer | lookup |
| [3](#item-3) | Apron Project | Variable InputFileLocation | lookup |
| [4](#item-4) | HandRails | Variable ServerInputFileLocation | lookup; nothing reads this variable, so you could delete it instead |
| [5](#item-5) | HandRails | Variable ServerOutputFileLocation | lookup |
| [6](#item-6) | HandRails outside | Variable ServerInputFileLocation | lookup; nothing reads this variable, so you could delete it instead |
| [7](#item-7) | HandRails outside | Variable ServerOutputFileLocation | lookup |
| [8](#item-8) | Hopper Project | Variable DataBaseServer | lookup |
| [9](#item-9) | Hopper Project | Variable FilePath | lookup |
| [10](#item-10) | Hopper V2 | Variable DataBaseServer | lookup |
| [11](#item-11) | Hopper V2 | Variable ServerInputFileLocation | lookup; nothing reads this variable, so you could delete it instead |
| [12](#item-12) | Hopper V2 | Variable ServerOutputFileLocation | lookup |
| [13](#item-13) | Hopper V2 - Panels | Variable ServerInputFileLocation | lookup; nothing reads this variable, so you could delete it instead |
| [14](#item-14) | Hopper V2 - Panels | Variable ServerOutputFileLocation | lookup |
| [15](#item-15) | Kit Conveyor Project | Document EmailToCustomerCAD (rule) | lookup: an email attachment; relative attachment paths aren't confirmed to resolve against the project folder |
| [16](#item-16) | Kit Conveyor Project | Document SpartaKitConveyorWeb (rule) | relative |
| [17](#item-17) | Kit Conveyor Project | Variable DataBaseServer | lookup |
| [18](#item-18) | Ladder | Variable InputFileLocation | lookup |
| [19](#item-19) | Order Project | Variable DataBaseServer | lookup |
| [20](#item-20) | Picking Conveyor Project | Control AddSliderbedheightpic.FileName (form Conveyor Options) | relative |
| [21](#item-21) | Picking Conveyor Project | Control PictureBox1.FileName (form 3DWindow) | relative |
| [22](#item-22) | Picking Conveyor Project | Control PictureBox2.FileName (form 3DWindow) | relative |
| [23](#item-23) | Picking Conveyor Project | Variable FilePath | lookup |
| [24](#item-24) | Platform - Picking | Control SpartaLogo.FileName (form Details) | relative |
| [25](#item-25) | Platform - Picking | Variable ServerInputFileLocation | lookup |
| [26](#item-26) | Platform - Picking | Variable ServerOutputFileLocation | lookup |
| [27](#item-27) | Platform - Straight | Control SpartaLogo.FileName (form Details) | relative |
| [28](#item-28) | Platform - Straight | Macro CloseAddMode / task 'Specification PowerPack: Export a Table Array To a text file' / Target File Name | lookup; **moved**: prod value becomes `\\192.168.0.19\Driveworks Output Files\Debug\Platform.txt` |
| [29](#item-29) | Platform - Straight | Macro CloseAddMode / task 'Specification PowerPack: Export a Table Array To a text file1' / Target File Name | lookup; **moved**: prod value becomes `\\192.168.0.19\Driveworks Output Files\Debug\100.txt` |
| [30](#item-30) | Platform - Straight | Macro CloseEditMode / task 'Specification PowerPack: Export a Table Array To a text file' / Target File Name | lookup; **moved**: prod value becomes `\\192.168.0.19\Driveworks Output Files\Debug\Platform.txt` |
| [31](#item-31) | Platform - Straight | Macro CloseEditMode / task 'Specification PowerPack: Export a Table Array To a text file1' / Target File Name | lookup; **moved**: prod value becomes `\\192.168.0.19\Driveworks Output Files\Debug\100.txt` |
| [32](#item-32) | Platform - Straight | Variable ServerInputFileLocation | lookup |
| [33](#item-33) | Platform - Straight | Variable ServerOutputFileLocation | lookup |
| [34](#item-34) | Platform Bolts | Variable ServerInputFileLocation | lookup; nothing reads this variable, so you could delete it instead |
| [35](#item-35) | Platform Bolts | Variable ServerOutputFileLocation | lookup |
| [36](#item-36) | Platform Layout | Control SpartaLogo.FileName (form Details) | relative |
| [37](#item-37) | Platform Layout | Macro ReleaseAllRailingSub / task 'Specification PowerPack: Export a Table Array To a text file1' / Target File Name | lookup; **moved**: prod value becomes `\\192.168.0.19\Driveworks Output Files\Debug\0-CalcTable.txt` |
| [38](#item-38) | Platform Layout | Macro ReleaseAllRailingSub / task 'Specification PowerPack: Export a Table Array To a text file11' / Target File Name | lookup; **moved**: prod value becomes `\\192.168.0.19\Driveworks Output Files\Debug\0-PlatformList.txt` |
| [39](#item-39) | Platform Layout | Macro ReleaseAllRailingSub / task 'Specification PowerPack: Export a Table Array To a text file111' / Target File Name | lookup; **moved**: prod value becomes `\\192.168.0.19\Driveworks Output Files\Debug\0-RailingList.txt` |
| [40](#item-40) | Platform Layout | Macro ReleaseAllRailingSubSub / task 'Specification PowerPack: Export a Table Array To a text file' / Target File Name | lookup; **moved**: prod value becomes `\\192.168.0.19\Driveworks Output Files\Debug\00.txt` |
| [41](#item-41) | Platform Layout | Variable DataBaseServer | lookup |
| [42](#item-42) | Platform Layout | Variable ServerInputFileLocation | lookup; it points at the *Output* share today, so it reads OutputRoot; nothing reads this variable, so you could delete it instead |
| [43](#item-43) | Platform Layout | Variable ServerOutputFileLocation | lookup |
| [44](#item-44) | Select Project | Variable DataBaseServer | lookup |
| [45](#item-45) | Start Leg | Variable InputFileLocation | lookup |
| [46](#item-46) | Start Leg | Variable OutputFileLocation | lookup |
| [47](#item-47) | Light Duty Conveyor | Variable DataBaseServer | lookup |
| [48](#item-48) | Light Duty Conveyor | Variable KitConveyorDrive3DLocation | lookup |
| [49](#item-49) | Light Duty Conveyor | Variable LightDutyConveyorDrive3DLocation | lookup |

### Apron Project

<a id="item-1"></a>

**1. Control PictureBox1.FileName (form CommonSpecs)** (relative)

Old rule:

```
"\\192.168.0.19\Driveworks Input Files\Apron\Form Design Documents\nnn.png"
```

New rule:

```
"Form Design Documents\nnn.png"
```

<a id="item-2"></a>

**2. Variable DataBaseServer** (lookup)

Old rule:

```
"192.168.0.19\SQLEXPRESS"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"DbServer")
   ,FALSE)
```

<a id="item-3"></a>

**3. Variable InputFileLocation** (lookup)

Old rule:

```
"\\192.168.0.19\Driveworks Input Files\Apron\"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"InputRoot")
   ,FALSE)
& "Apron\"
```

### HandRails

<a id="item-4"></a>

**4. Variable ServerInputFileLocation** (lookup; nothing reads this variable, so you could delete it instead)

Old rule:

```
"\\192.168.0.19\Driveworks Input Files\"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"InputRoot")
   ,FALSE)
```

<a id="item-5"></a>

**5. Variable ServerOutputFileLocation** (lookup)

Old rule:

```
"\\192.168.0.19\Driveworks Output Files\"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"OutputRoot")
   ,FALSE)
```

### HandRails outside

<a id="item-6"></a>

**6. Variable ServerInputFileLocation** (lookup; nothing reads this variable, so you could delete it instead)

Old rule:

```
"\\192.168.0.19\Driveworks Input Files\"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"InputRoot")
   ,FALSE)
```

<a id="item-7"></a>

**7. Variable ServerOutputFileLocation** (lookup)

Old rule:

```
"\\192.168.0.19\Driveworks Output Files\"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"OutputRoot")
   ,FALSE)
```

### Hopper Project

<a id="item-8"></a>

**8. Variable DataBaseServer** (lookup)

Old rule:

```
"192.168.0.19\SQLEXPRESS"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"DbServer")
   ,FALSE)
```

<a id="item-9"></a>

**9. Variable FilePath** (lookup)

Old rule:

```
"\\192.168.0.19\Driveworks Output Files\" & DWSpecification
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"OutputRoot")
   ,FALSE)
& DWSpecification
```

### Hopper V2

<a id="item-10"></a>

**10. Variable DataBaseServer** (lookup)

Old rule:

```
"192.168.0.19\SQLEXPRESSDW"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"DbServerDW")
   ,FALSE)
```

<a id="item-11"></a>

**11. Variable ServerInputFileLocation** (lookup; nothing reads this variable, so you could delete it instead)

Old rule:

```
"\\192.168.0.19\Driveworks Input Files\"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"InputRoot")
   ,FALSE)
```

<a id="item-12"></a>

**12. Variable ServerOutputFileLocation** (lookup)

Old rule:

```
"\\192.168.0.19\Driveworks Output Files\"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"OutputRoot")
   ,FALSE)
```

### Hopper V2 - Panels

<a id="item-13"></a>

**13. Variable ServerInputFileLocation** (lookup; nothing reads this variable, so you could delete it instead)

Old rule:

```
"\\192.168.0.19\Driveworks Input Files\"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"InputRoot")
   ,FALSE)
```

<a id="item-14"></a>

**14. Variable ServerOutputFileLocation** (lookup)

Old rule:

```
"\\192.168.0.19\Driveworks Output Files\"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"OutputRoot")
   ,FALSE)
```

### Kit Conveyor Project

<a id="item-15"></a>

**15. Document EmailToCustomerCAD (rule)** (lookup: an email attachment; relative attachment paths aren't confirmed to resolve against the project folder)

Old rule:

```
ListJoin(
DWVariableStepForCustomer & "\" & DWVariableClientTeamName & "-" & ProjectNameReturn & 
If( DWVariableReleaseStepOnly = TRUE, EquipmentNameReturn, DWVariablePrefixClientWO) & "-" 
& InputClientNumberReturn & InputProjectNumberReturn & InputEquipmentNumberReturn & "-" & DWSpecificationId & ".x_t"
,
DWVariableStepForCustomer & "\" & DWVariableClientTeamName & "-" & ProjectNameReturn & "-" & EquipmentNameReturn & "-" & InputClientNumberReturn & InputProjectNumberReturn & InputEquipmentNumberReturn & "-" & DWSpecificationId & ".pdf"
,
"\\192.168.0.19\Driveworks Input Files\Kit Conveyor\Form Design Documents\Sparta Kit conveyor Features.pdf"
)
```

New rule:

```
ListJoin(
DWVariableStepForCustomer & "\" & DWVariableClientTeamName & "-" & ProjectNameReturn & 
If( DWVariableReleaseStepOnly = TRUE, EquipmentNameReturn, DWVariablePrefixClientWO) & "-" 
& InputClientNumberReturn & InputProjectNumberReturn & InputEquipmentNumberReturn & "-" & DWSpecificationId & ".x_t"
,
DWVariableStepForCustomer & "\" & DWVariableClientTeamName & "-" & ProjectNameReturn & "-" & EquipmentNameReturn & "-" & InputClientNumberReturn & InputProjectNumberReturn & InputEquipmentNumberReturn & "-" & DWSpecificationId & ".pdf"
,
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"InputRoot")
   ,FALSE)
& "Kit Conveyor\Form Design Documents\Sparta Kit conveyor Features.pdf"
)
```

<a id="item-16"></a>

**16. Document SpartaKitConveyorWeb (rule)** (relative)

Old rule:

```
"\\192.168.0.19\Driveworks Input Files\Kit Conveyor\3D Model Files\Belts\HeadSectionBeltW" & DWVariableConveyorWidth & "-DW01.DRIVE3D"
```

New rule:

```
"3D Model Files\Belts\HeadSectionBeltW" & DWVariableConveyorWidth & "-DW01.DRIVE3D"
```

<a id="item-17"></a>

**17. Variable DataBaseServer** (lookup)

Old rule:

```
"192.168.0.19\SQLEXPRESS"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"DbServer")
   ,FALSE)
```

### Ladder

<a id="item-18"></a>

**18. Variable InputFileLocation** (lookup)

Old rule:

```
"\\192.168.0.19\Driveworks Input Files\Ladder\"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"InputRoot")
   ,FALSE)
& "Ladder\"
```

### Order Project

<a id="item-19"></a>

**19. Variable DataBaseServer** (lookup)

Old rule:

```
"192.168.0.19\SQLEXPRESS"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"DbServer")
   ,FALSE)
```

### Picking Conveyor Project

<a id="item-20"></a>

**20. Control AddSliderbedheightpic.FileName (form Conveyor Options)** (relative)

Old rule:

```
"\\192.168.0.19\Driveworks Input Files\Picking Conveyor\Form Design Documents\AddSliderbedheight1.png"
```

New rule:

```
"Form Design Documents\AddSliderbedheight1.png"
```

<a id="item-21"></a>

**21. Control PictureBox1.FileName (form 3DWindow)** (relative)

Old rule:

```
If(CheckBox_ElbowReturn,"\\192.168.0.19\Driveworks Input Files\Picking Conveyor\Form Design Documents\pcii.png","\\192.168.0.19\Driveworks Input Files\Picking Conveyor\Form Design Documents\pch.png")
```

New rule:

```
If(CheckBox_ElbowReturn,"Form Design Documents\pcii.png","Form Design Documents\pch.png")
```

<a id="item-22"></a>

**22. Control PictureBox2.FileName (form 3DWindow)** (relative)

Old rule:

```
"\\192.168.0.19\Driveworks Input Files\Picking Conveyor\Form Design Documents\DW Picking Conveyor Project.png"
```

New rule:

```
"Form Design Documents\DW Picking Conveyor Project.png"
```

<a id="item-23"></a>

**23. Variable FilePath** (lookup)

Old rule:

```
"\\192.168.0.19\Driveworks Output Files\" & DWSpecification
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"OutputRoot")
   ,FALSE)
& DWSpecification
```

### Platform - Picking

<a id="item-24"></a>

**24. Control SpartaLogo.FileName (form Details)** (relative)

Old rule:

```
"\\192.168.0.19\Driveworks Input Files\Images\Sparta_Logo_White.png"
```

New rule:

```
"..\Images\Sparta_Logo_White.png"
```

<a id="item-25"></a>

**25. Variable ServerInputFileLocation** (lookup)

Old rule:

```
"\\192.168.0.19\Driveworks Input Files\"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"InputRoot")
   ,FALSE)
```

<a id="item-26"></a>

**26. Variable ServerOutputFileLocation** (lookup)

Old rule:

```
"\\192.168.0.19\Driveworks Output Files\"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"OutputRoot")
   ,FALSE)
```

### Platform - Straight

<a id="item-27"></a>

**27. Control SpartaLogo.FileName (form Details)** (relative)

Old rule:

```
"\\192.168.0.19\Driveworks Input Files\Images\Sparta_Logo_White.png"
```

New rule:

```
"..\Images\Sparta_Logo_White.png"
```

<a id="item-28"></a>

**28. Macro CloseAddMode / task 'Specification PowerPack: Export a Table Array To a text file' / Target File Name** (lookup; **moved**: prod value becomes `\\192.168.0.19\Driveworks Output Files\Debug\Platform.txt`)

Old rule:

```
"C:\Users\oligod\OneDrive - Sparta Manufacturing\Desktop\text\Platform"&DWConstantAssemblyNumber&".txt"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"OutputRoot")
   ,FALSE)
& "Debug\Platform"&DWConstantAssemblyNumber&".txt"
```

<a id="item-29"></a>

**29. Macro CloseAddMode / task 'Specification PowerPack: Export a Table Array To a text file1' / Target File Name** (lookup; **moved**: prod value becomes `\\192.168.0.19\Driveworks Output Files\Debug\100.txt`)

Old rule:

```
"C:\Users\oligod\OneDrive - Sparta Manufacturing\Desktop\text\"&AssemblyNumberReturn&".txt"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"OutputRoot")
   ,FALSE)
& "Debug\"&AssemblyNumberReturn&".txt"
```

<a id="item-30"></a>

**30. Macro CloseEditMode / task 'Specification PowerPack: Export a Table Array To a text file' / Target File Name** (lookup; **moved**: prod value becomes `\\192.168.0.19\Driveworks Output Files\Debug\Platform.txt`)

Old rule:

```
"C:\Users\oligod\OneDrive - Sparta Manufacturing\Desktop\text\Platform"&DWConstantAssemblyNumber&".txt"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"OutputRoot")
   ,FALSE)
& "Debug\Platform"&DWConstantAssemblyNumber&".txt"
```

<a id="item-31"></a>

**31. Macro CloseEditMode / task 'Specification PowerPack: Export a Table Array To a text file1' / Target File Name** (lookup; **moved**: prod value becomes `\\192.168.0.19\Driveworks Output Files\Debug\100.txt`)

Old rule:

```
"C:\Users\oligod\OneDrive - Sparta Manufacturing\Desktop\text\"&AssemblyNumberReturn&".txt"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"OutputRoot")
   ,FALSE)
& "Debug\"&AssemblyNumberReturn&".txt"
```

<a id="item-32"></a>

**32. Variable ServerInputFileLocation** (lookup)

Old rule:

```
"\\192.168.0.19\Driveworks Input Files\"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"InputRoot")
   ,FALSE)
```

<a id="item-33"></a>

**33. Variable ServerOutputFileLocation** (lookup)

Old rule:

```
"\\192.168.0.19\Driveworks Output Files\"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"OutputRoot")
   ,FALSE)
```

### Platform Bolts

<a id="item-34"></a>

**34. Variable ServerInputFileLocation** (lookup; nothing reads this variable, so you could delete it instead)

Old rule:

```
"\\192.168.0.19\Driveworks Input Files\"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"InputRoot")
   ,FALSE)
```

<a id="item-35"></a>

**35. Variable ServerOutputFileLocation** (lookup)

Old rule:

```
"\\192.168.0.19\Driveworks Output Files\"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"OutputRoot")
   ,FALSE)
```

### Platform Layout

<a id="item-36"></a>

**36. Control SpartaLogo.FileName (form Details)** (relative)

Old rule:

```
"\\192.168.0.19\Driveworks Input Files\Images\Sparta_Logo_White.png"
```

New rule:

```
"..\Images\Sparta_Logo_White.png"
```

<a id="item-37"></a>

**37. Macro ReleaseAllRailingSub / task 'Specification PowerPack: Export a Table Array To a text file1' / Target File Name** (lookup; **moved**: prod value becomes `\\192.168.0.19\Driveworks Output Files\Debug\0-CalcTable.txt`)

Old rule:

```
"C:\Users\oligod\OneDrive - Sparta Manufacturing\Desktop\text\"&String(SpinButton1Return)&"-CalcTable.txt"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"OutputRoot")
   ,FALSE)
& "Debug\"&String(SpinButton1Return)&"-CalcTable.txt"
```

<a id="item-38"></a>

**38. Macro ReleaseAllRailingSub / task 'Specification PowerPack: Export a Table Array To a text file11' / Target File Name** (lookup; **moved**: prod value becomes `\\192.168.0.19\Driveworks Output Files\Debug\0-PlatformList.txt`)

Old rule:

```
"C:\Users\oligod\OneDrive - Sparta Manufacturing\Desktop\text\"&String(SpinButton1Return)&"-PlatformList.txt"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"OutputRoot")
   ,FALSE)
& "Debug\"&String(SpinButton1Return)&"-PlatformList.txt"
```

<a id="item-39"></a>

**39. Macro ReleaseAllRailingSub / task 'Specification PowerPack: Export a Table Array To a text file111' / Target File Name** (lookup; **moved**: prod value becomes `\\192.168.0.19\Driveworks Output Files\Debug\0-RailingList.txt`)

Old rule:

```
"C:\Users\oligod\OneDrive - Sparta Manufacturing\Desktop\text\"&String(SpinButton1Return)&"-RailingList.txt"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"OutputRoot")
   ,FALSE)
& "Debug\"&String(SpinButton1Return)&"-RailingList.txt"
```

<a id="item-40"></a>

**40. Macro ReleaseAllRailingSubSub / task 'Specification PowerPack: Export a Table Array To a text file' / Target File Name** (lookup; **moved**: prod value becomes `\\192.168.0.19\Driveworks Output Files\Debug\00.txt`)

Old rule:

```
"C:\Users\oligod\OneDrive - Sparta Manufacturing\Desktop\text\"&String(SpinButton1Return&SpinButton2Return)&".txt"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"OutputRoot")
   ,FALSE)
& "Debug\"&String(SpinButton1Return&SpinButton2Return)&".txt"
```

<a id="item-41"></a>

**41. Variable DataBaseServer** (lookup)

Old rule:

```
"192.168.0.19\SQLEXPRESS"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"DbServer")
   ,FALSE)
```

<a id="item-42"></a>

**42. Variable ServerInputFileLocation** (lookup; it points at the *Output* share today, so it reads OutputRoot; nothing reads this variable, so you could delete it instead)

Old rule:

```
"\\192.168.0.19\Driveworks Output Files\"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"OutputRoot")
   ,FALSE)
```

<a id="item-43"></a>

**43. Variable ServerOutputFileLocation** (lookup)

Old rule:

```
"\\192.168.0.19\Driveworks Output Files\"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"OutputRoot")
   ,FALSE)
```

### Select Project

<a id="item-44"></a>

**44. Variable DataBaseServer** (lookup)

Old rule:

```
"192.168.0.19\SQLEXPRESS"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"DbServer")
   ,FALSE)
```

### Start Leg

<a id="item-45"></a>

**45. Variable InputFileLocation** (lookup)

Old rule:

```
"\\192.168.0.19\Driveworks Input Files\"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"InputRoot")
   ,FALSE)
```

<a id="item-46"></a>

**46. Variable OutputFileLocation** (lookup)

Old rule:

```
"\\192.168.0.19\DriveWorks Output Files\"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"OutputRoot")
   ,FALSE)
```

### Light Duty Conveyor

<a id="item-47"></a>

**47. Variable DataBaseServer** (lookup)

Old rule:

```
"192.168.0.19\SQLEXPRESS"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"DbServer")
   ,FALSE)
```

<a id="item-48"></a>

**48. Variable KitConveyorDrive3DLocation** (lookup)

Old rule:

```
"\\192.168.0.19\Driveworks Input Files\Kit Conveyor\3D Model Files\"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"InputRoot")
   ,FALSE)
& "Kit Conveyor\3D Model Files\"
```

<a id="item-49"></a>

**49. Variable LightDutyConveyorDrive3DLocation** (lookup)

Old rule:

```
"\\192.168.0.19\Driveworks Input Files\Light Duty Conveyor\3D Model Files\"
```

New rule:

```
DWVLookup(GetGroupName()
   ,DWGroupTableEnvironments
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"GroupName")
   ,TableGetColumnIndexByName(DWGroupTableEnvironments,"InputRoot")
   ,FALSE)
& "Light Duty Conveyor\3D Model Files\"
```

## 4. SQL export documents: not a rule, decision needed

These documents store their server as a fixed setting (`Server="192.168.0.19\SQLEXPRESS"`, database `SpartaDWdata`), not as a rule. A release in dev writes into the production database. **Decision 2026-10-06: accepted for now, no change.**

| Project | Document | Table written |
|---|---|---|
| Hopper Project | EquipmentListExport | EquipmentListData |
| Kit Conveyor Project | DWKitConveyorData | DWKitConveyorData |
| Kit Conveyor Project | EquipmentListExport | EquipmentListData |
| Order Project | ProjectListExport | ProjectListData |
| Platform Layout | DWPlatformLayoutData | DWPlatformLayout |
| Platform Layout | EquipmentListExport | EquipmentListData |
| Select Project | AddNewTeamInSQL | ClientListData |

Options:
1. **Don't release them outside prod.** Wherever a release step names them, or releases all documents (`*`), make that list a rule that leaves them out when `DWVariableIsProductionEnvironment` is FALSE. **Recommended.**
2. Point them at a dev database in dev. That means editing the document in dev and changing it back before each release. It's error-prone.

The group-table exports (`NewClientProjects`, `NewColourSpecs`) write into the running group's own tables, so they need no change.

## 5. Already safe or not covered

- **The 8 `EmailToAdminForTracking` emails** already go to `jonathan.arsenault@spartaway.com`.
- **Email recipients: no change for now** (decision 2026-10-06). The costing and quoting emails still go to the application engineer from dev too.
- **The 17 client emails (done, CAD, summary, layout) need no change.** They go to `ClientEmail`, which falls back to `DWCurrentUserEmailAddress`, the logged-in user. Parent projects pass the same value to their children. In dev, each developer receives their own test emails, as long as each logs in with their own DriveWorks user and that user has an email address in security.
- **Apron, Kit Conveyor and Light Duty save models under `DWSpecificationFullPath`,** which follows each group's specification folder.
- **Form pictures referenced in `C:\Sparta SW Vault\…`** (Hopper and the HandRails logos) are the PDM vault's local view, the same on every PC. They need no change for dev and prod, but they do need the vault on the PC that runs the form.
