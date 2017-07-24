$ErrorActionPreference = "Stop"

$c_object = ""
$tou_object = ""

# Get Target_Computer:
$computer_name = Read-Host -Prompt "Enter Computer Name: "
try {$computer_name = Get-ADComputer -Filter * | where {$_. name -like "*" + $computer_name + "*"} | sort name}
catch {
    Write-Host -ForegroundColor Red "Error occured, terminating..."
    Write-Host -ForegroundColor Red "Error message:"$Error[0].Exception.Message
    exit
}
finally {}

if (@($computer_name).Count -eq 0) {
    Write-Host -ForegroundColor Magenta "No computer found with that name. TERMINATING..."
    pause
    exit
}

if (@($computer_name).Count -gt 1) {
    Write-Host -ForegroundColor Magenta "More than one Computer with that name found, please select which computer: `n>>>"

    for ($i=1; $i -le $computer_name.Length; $i++) {
        "$i - " +  $computer_name[$i-1].distinguishedname
    }
    $intSel = Read-Host -Prompt "Enter number in front of computername: "
    $intSel -=1
    $c_object = $computer_name[$intSel]
    Write-Host -ForegroundColor Magenta "Computer selected: " + $c_object.name
}
else {
    $c_object = $computer_name
    Write-Host -ForegroundColor Magenta "Computer selected: " + $c_object.DistinguishedName
}

# Get Target OU:
$target_ou = Read-Host -Prompt "Enter target OU: "
try { $target_ou = Get-ADOrganizationalUnit -Filter * | where{$_. name -like "*" + $target_ou + "*"} | sort name }
catch {
    Write-Host -ForegroundColor Red "Error Occured. Terminating..."
    Write-Host -ForegroundColor Red "Error Message:"$Error[0].Exception.Message
    pause
    exit
}
finally {}

if (@($target_ou).Count -eq 0) {
    Write-Host -ForegroundColor Magenta "No OU found with that name, terminating..."
    exit
}

if (@($target_ou).Count -gt 1) {
    Write-Host -ForegroundColor Magenta "More than one OU with that name found, please select which OU to move to: `n>>>"

    for ($i=1; $i -le $target_ou.Length; $i++) {
        "$i - " +  $target_ou[$i-1].distinguishedname
    }
    $intSel = Read-Host -Prompt "Enter OU number: "
    $intSel -=1
    $tou_object = $target_ou[$intSel]
    Write-Host -ForegroundColor Magenta "Computer will be moved to the following OU: " + $tou_object.DistinguishedName
}
else {
    $tou_object = $target_ou
    Write-Host -ForegroundColor Magenta "Computer will be moved to the following OU: " + $tou_object.DistinguishedName
}

# MOVING OU
try {
    Move-ADObject -Identity $c_object -TargetPath $tou_object
    Write-Host -ForegroundColor Green "Move completed. Refreshing AD Computer Object..."
    @(Get-ADComputer -Filter * | where{$_. name -eq $c_object.Name}).distinguishedname
}
catch {
    Write-Host -ForegroundColor Red "Move failed. Please check if you are logged in as admin.xx account. `nPlease kindaly report errors to gep@douglascollege.ca, thank you! :)"
}
finally {Pause}
