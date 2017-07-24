function getUser ($objUser) {
    $strUID = $objUser.cn
    $strUName = $objUser.displayname
    $strUType = $objUser.employeetype
    $strUCDate = $objUser.whencreated
    $strUMDate = $objUser.whenchanged
    $strUEID = ""  #EMP ONLY INFO
    $strUTitle = ""  #EMP ONLY INFO
    $strUTel = ""  #EMP ONLY INFO
    $strUOffice = ""  #EMP ONLY INFO
    $strUExtEmail = ""  #STU ONLY INFO (STUDENT PERSONAL EMAIL)
    $strUEID = $objUser.employeeid
    $strUTitle = $objUser.title
    $strUTel = $objUser.telephonenumber
    $strUOffice = $objUser.physicaldeliveryofficename
    $strUExtEmail = $objUser.extensionattribute12

    $strUStatus = Get-ADUser $strUID | select enabled
    $strUStatus = ($strUStatus -replace "`n | `r").Substring(10)
    $strUStatus = $strUStatus.Substring(0, ($strUStatus.Length-1))
    if ($strUStatus -eq "True") {$strUStatus = "Enabled"}
    else {$strUStatus = "Disabled"}
    
    if ($strUStatus -eq "Disabled") { Write-Host -ForegroundColor DarkRed "Status:     $strUStatus" }
    else { Write-Host -ForegroundColor DarkGreen "Status:     $strUStatus" }
    Write-Host "CN:         $strUID"
    Write-Host "Name:       $strUName"
    Write-Host "Type:       $strUType"
    Write-Host "Created:    $strUCDate"
    Write-Host "Modified:   $strUMDate"

    # If student, display personal email address, else (employee display EID, title, office, tel.)
    if ($strUType -eq "STUDENT") { Write-Host "P.Email:    $strUExtEmail" } 
    else {
        Write-Host "Emp.ID:     $strUEID"
        Write-Host "Title:      $strUTitle"
        Write-Host "Office:     $strUOffice"
        Write-Host "Tel.:       $strUTel"
    }

    #if ($strUStatus -eq "Enabled") { Write-Host "$strUID, $strUName, $strUType, $strUStatus - (Employee Only): $strUEID - $strUtitle - $strUTel" }
    #else { Write-Host -ForegroundColor Gray "$strUID, $strUName, $strUType, $strUStatus - (Employee Only): $strUEID - $strUtitle - $strUTel" }
    "-" * 50
}

$strSearch = Read-Host -Prompt "Search User"
Write-Host -ForegroundColor Green "Displaying AD Users with Name containing $strSearch :`n"

$strSearch="*$strSearch*"
    
$aryUsers = Get-ADObject -Filter {((displayname -like $strSearch) -or (name -like $strSearch)) -and (ObjectClass -eq "user")} -Properties * | Sort-Object employeetype, displayname

switch (@($aryUsers).Count) {
    0 { Write-Host -ForegroundColor Yellow "No user found." }
    1 {
        getUser($aryUsers)
        Write-Host -ForegroundColor Yellow "Total user(s) found: 1"
    }
    default {
        for ($i=0; $i -lt ($aryUsers.count); $i++) {
        getUser( $aryUsers[$i])
        }
    }
}
Write-Host -ForegroundColor Green "Total user(s) found:" $aryUsers.count
