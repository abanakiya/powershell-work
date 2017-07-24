# SO FAR ONLY SEARCHES TITLE AND DESCRIPTION, TO BE IMPROVED

$ErrorActionPreference = "SilentlyContinue"
$strDiv = "-" * 128

function inc-detail ($objInc) {
    $incID = $objInc.id
    if ($incID.length -lt 10 ) { $incID = $incID + (" " * (10 - $incID.length))} #ID=10 CHARS, FILL REST WITH SPACE
    $incTitle = $objInc.title
    if ($incTitle.length -lt 30 ) { $incTitle = $incTitle + (" " * (30 - $incTitle.length))} #TITLE=30 CHARS, FILL REST WITH SPACE
    $incDesc = $objInc.description
    if ($incDesc.length -lt 80 ) { $incDesc = $incDesc + (" " * (80 - $incDesc.length))} #DESC=80 CHARS, FILL REST WITH SPACE
    $incDesc = $incDesc -replace "`n|`r" #REMOVE ALL LINE BREAKS
    write-host $incID (get-date -uFormat "%Y%m%d" -date ($objInc.createddate))"   "(($objInc.status.displayname).substring(0,1))"   "($incTitle.Substring(0,24))"   "($incDesc.Substring(0,69))
    $strDiv
}

# ***GET INCIDENT DATA***
Write-Host -ForegroundColor Green "Searching Incident Title and Description.."
$strS = Read-Host -Prompt "Enter Search Word"
try { 
    $Incident = Get-SCSMobject -Class (Get-SCSMClass -Name system.workitem.incident) `
        | where {$_.description -like "*$strS*" -or $_.title -like "*$strS*"}
}
catch {
    Write-Host -ForegroundColor Red "Error occured. TERMINATING..."
    Write-Host -ForegroundColor Red "Error message: $Error[0].exception.message"
    pause
    exit
}
finally{}

# FORMATTED OUTPUT:
Write-Host -ForegroundColor Green "Displaying all incidents containing word $strS"
$strDiv
Write-Host -ForegroundColor Green "ID         OPENED       STAT  TITLE                        DESCRIPTION"
$strDiv

switch (@($Incident).Count) {
    0 {}
    1 { inc-detail ($Incident) }
    default {
        for ($i=0; $i -lt $Incident.count; $i++) {
            inc-detail ($Incident[$i])
        }
    }
}

write-host "Number of record(s) found:" $Incident.Count
