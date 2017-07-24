# RETURNS INCIDENT DETAILS INCL. UPDATES

$ErrorActionPreference = "SilentlyContinue"

$Inc = Read-Host -Prompt "Enter Incident#"
try { $Incident = Get-SCSMobject -Class (Get-SCSMClass -Name system.workitem.incident) -Filter "name -like *$inc*" }
catch {
    Write-Host -ForegroundColor Red "Error occured. TERMINATING..."
    Write-Host -ForegroundColor Red "Error message: $Error[0].exception.message"
    pause
    # exit
}
finally{}

$Incident | Add-Member -MemberType NoteProperty -Name "AssignedToUser" -Value ""
$Incident | Add-Member -MemberType NoteProperty -Name "AffectedUser" -Value ""
$Incident | Add-Member -MemberType NoteProperty -Name "CreatedByUser" -Value ""

$relAs = Get-SCSMRelationship -DisplayName "Assigned to user"
$relAf = Get-SCSMRelationship -DisplayName "Affected User"
$relAc = Get-SCSMRelationship -DisplayName "Created by User"
$Incident.AssignedToUser = Get-SCSMRelatedObject -SMObject $Incident -Relationship $relAs
$Incident.AffectedUser = Get-SCSMRelatedObject -SMObject $Incident -Relationship $relAf
$Incident.CreatedByUser = Get-SCSMRelatedObject -SMObject $Incident -Relationship $relAc

$cDate = Get-Date($Incidents.object.createddate).addhours(-8)
$Incidents.createddate = $cDate

Write-Host -ForegroundColor Green "Incident Detail:"
$Incident | fl ID, createddate, createdbyuser, status, priority, affecteduser, assignedtouser, tierqueue, lastmodified, title, description

# ***GET ACTION LOG *** 
Write-Host -ForegroundColor Green "Action Log:"

$CommentRel = Get-SCSMRelationshipClass "System.WorkItem.troubletickethasfileattachment"
$ActionLogComments = Get-SCSMRelatedObject -smobject $Incident -Relationship  $CommentRel | Sort-Object lastmodified

$ActionLogComments | fl lastmodified, ActionType, enteredby, displayname, description
