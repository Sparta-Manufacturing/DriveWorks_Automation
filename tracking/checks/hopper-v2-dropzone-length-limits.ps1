<#
Pass when Hopper V2's form limits Drop Zone Length to what 4 panel columns hold, and Before Elbow Length to at least
the drop zone, either with Maximum/Minimum rules or with Error messages. Text-box Min/Max may not be enforced
(platform rows hold 101 against a maximum of 100), so an Error rule also counts.
Case: spec 46203 rev 6 (ARD1652) entered Drop Zone Length 69 ft (meant as inches) with Before Elbow Length 18 ft;
V2 then built no transition and no mid section, without any message.
#>
param([Parameter(Mandatory)][string]$Project, [string]$Group)
Import-Module (Join-Path $PSScriptRoot '..\..\tools\DwTools\DwFormEngine.psm1')
$s = New-DwFormSession $Project -Group $Group -StartValues Saved -Inputs @{ ConveyorType = 'Light Duty Conveyor'; DropZoneLengthRight = 69; BeforeElbowLength = 18 }
function V($slot) { $v = Get-DwFormValue $s $slot; if ($v.IsError) { $null } else { "$($v.Value)" } }
function Flagged($slot) { $e = V $slot; $e -and $e -notin '0', 'FALSE' }
$problems = New-Object System.Collections.Generic.List[string]
$dzMax = V 'DropZoneLengthRightMax'
if (-not ((Flagged 'DropZoneLengthRightError') -or ($dzMax -and [double]$dzMax -lt 69))) { $problems.Add("Drop Zone Length 69 ft accepted (Maximum $dzMax, no Error)") }
$beMin = V 'BeforeElbowLengthMin'
if (-not ((Flagged 'BeforeElbowLengthError') -or ($beMin -and [double]$beMin -gt 18))) { $problems.Add("Before Elbow Length 18 ft accepted below a 69 ft drop zone (Minimum $beMin, no Error)") }
[pscustomobject]@{ Pass = ($problems.Count -eq 0); Detail = $(if ($problems.Count) { $problems -join '; ' } else { "69 ft drop zone is limited or flagged (max $dzMax), and so is an 18 ft Before Elbow Length (min $beMin)" }) }
