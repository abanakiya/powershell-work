# TO BE IMPROVED
# RE-WRITE USING GET-ADOBJECT INSTEAD OF GET-PRINTER


$ErrorActionPreference = "SilentlyContinue"

function formOutput ($objPrinter) {
#GET STATUS
    $strSrv = $objPrinter.shortservername
    $strPname = $objPrinter.printername
    $strStat = (Get-printer -ComputerName $strSrv | where{$_.name -like "*$strPName*" -and $_.DeviceType -eq "Print"}).PrinterStatus

    write-host "Printername:"$objPrinter.name
    write-host "Desc.      :"$objPrinter.description
    write-host "Port       :"$objPrinter.portname
    Write-Host "Status     :"$strStat
    write-host "Driver Name, Version: "$objPrinter.drivername" ver."$objPrinter.driverversion
    Write-Host "Created    :"$objPrinter.whencreated
    Write-host "Modified   :"$objPrinter.whenchanged
    Write-Host "Trays      :"$objPrinter.printbinnames
    write-host "Colour     :"$objPrinter.printcolor
    write-host "Duplex     :"$objPrinter.printduplexsupported
    Write-Host "Stapler    :"$objPrinter.printstaplingsupported
    Write-Host "Print Queue:"
    Get-PrintJob -ComputerName $strSrv $strPname | ft ID, UserName, SubmittedTime, JobStatus, Size, TotalPages, DocumentName
    Write-Host "-------------------------------------------------------------------------------------------------"
}

$strSearch = Read-Host -Prompt "Searching All Printers.. Enter printer or room number#"
$strSearch = "*$strSearch*"
try { 
    $dcPrinters = Get-ADObject -Filter {(name -like $strSearch) -and (objectclass -eq "printqueue")} -Properties * | sort name
}
catch {
    Write-Host -ForegroundColor Red "Error occured. TERMINATING..."
    Write-Host -ForegroundColor Red "Error message: $Error[0].exception.message"
    pause
    exit
}
finally{}

#FORMATTED OUTPUT:
Write-Host -ForegroundColor Green "--------- SEARCH RESULT ---------"

if ($dcPrinters.Count -ge 1) {
    for ($i=0; $i -lt $dcPrinters.length; $i++) {
        formoutput($dcPrinters[$i])
    }

    Write-Host "Total number of printer(s) found:"$dcPrinters.Count
}
else {
    if (($dcPrinters.name).length -ne 0) { 
        formOutput($dcPrinters)
        Write-Host "Total number of printer(s) found: 1"
    }
    else { Write-Host -ForegroundColor Magenta "No printer found"}
}

