# WILL LEAVE FOOTPRINT IN EV FROM GWMI
# WILL LEAVE FOOTPRINT IN EV FROM TEST3389 - ?
# FIX AT SOME POINT TO AVOID USING WRITE-HOST..

# NOTE (20170727): WORK COMPUTER IMAGE BY DEFAULT ONLY HAS 3389 OPEN
#   REST OF THE PORTS ARE OPENED BY SERVER SIDE SETTINGS

$ErrorActionPreference = "Stop"

clear

# TESTING RDC AVAILABILITY FOR REMOTE WORK, SCAN OTHER PORTS AS NEEDED
# MOST OF THIS FUNCTION COPIED FROM THE INTERWEBS
function test3389 ($strHost){
    $srv = $strHost
    $port = 3389
    $timeout = 300
    [switch]$verbose 
    
    # Create TCP client
    $tcpclient = New-Object system.net.sockets.tcpclient

    # Tell TCP client to connect to machine on port
    $iar = $tcpclient.BeginConnect($srv,3389,$null,$null)

    # Set the wait time
    $wait = $iar.AsyncWaitHandle.WaitOne($timeout,$false)

    # Check to see if the connection is done
    if(!$wait) {
        # Close the connection and report timeout
        $tcpclient.close()
        if($verbose) {Write-Host "Connection Timeout"}
        Return $false
    }
    else {
        # Close the connection and report the error if there is one
        $error.Clear()
        $tcpclient.EndConnect($iar) | Out-Null
        if(!$?) { if($verbose){Write-Host $error[0]}; $faile=$true }
        $tcpclient.Close()
    }

    # Return $true if connection established, else $false
    if ($faile) { return $false } else { return $true }
}

function get_details($computer) {
    $strCname = $computer.name
    $strEnabled = Get-ADComputer ($computer.name) | select enabled

    Write-Host -ForegroundColor yellow "+ COMPUTER FOUND: ---"$computer.name"------------------------------------------------------------"
    Write-Host "Computer Full AD Name:" $computer.distinguishedname
    write-host "Enabled                :"$strEnabled.enabled

    try {
        $strIP = Resolve-DnsName $strCname | select ipaddress
        Write-Host "IP Address             :"$strIP.IPAddress
    }
    catch {
        Write-Host -ForegroundColor DarkMagenta "Cannot Resolve IP Address"
    }
    finally {}

    $strCon3389 = test3389($strCname)
    if ($strCon3389 -contains "True") {
        Write-Host -ForegroundColor DarkGreen "Connection 3389 available."
        try {
            $aryCS = Get-WmiObject -class win32_computersystem -ComputerName $strCname | select username, model, totalphysicalmemory
            $aryNW = Get-WmiObject -class win32_networkadapterconfiguration -ComputerName $strCname | where{ ($_.IPaddress).length -gt 0 } | select index, servicename, dhcpenabled, IPaddress, macaddress
            $aryDR = Get-WmiObject -class win32_mappedlogicaldisk -ComputerName $strCname | select name, providername
            Write-Host "Computer Model         :" $aryCS.model
            Write-Host "Memory Size            :" $aryCS.totalphysicalmemory
            Write-Host "Current User           :" $aryCS.username
            Write-Host "Network Adapter(s)     :" $aryNW.servicename
            write-host "Adapter IP(s)          :" $aryNW.ipaddress
            Write-Host "Adapter MAC Address(es):" $aryNW.macaddress
            Write-Host "Mapped Drives          :" $aryDR

            #Get-WmiObject -class win32_computersystem -ComputerName $strCname | select username, model, totalphysicalmemory
            #Get-WmiObject -class win32_networkadapterconfiguration -ComputerName $strCname | where{ ($_.IPaddress).length -gt 0 } | select index, servicename, dhcpenabled, IPaddress, macaddress
            #Get-WmiObject -class win32_mappedlogicaldisk -ComputerName $strCname | select name, providername
            # REF-WIN32 CLASSES: https://msdn.microsoft.com/en-us/library/aa394084(v=vs.85).aspx
            # REF-WMI CLASSES: https://msdn.microsoft.com/en-us/library/aa394554(v=vs.85).aspx        
        }
        catch { Write-Host -ForegroundColor DarkMagenta "Cannot get additional information" }
        finally {}
    }
    else { 
        Write-Host -ForegroundColor Magenta "`nCannot establish connection to the computer" 
    }
}

# --- MAIN ------
$computername = Read-Host -Prompt "Enter B# or Room# get"
$computername = "*$computername*"
try { $computers = Get-ADObject -Filter {(name -like $computername) -and (ObjectClass -eq "computer")} | Sort name }
catch {
    Write-Host -ForegroundColor Red "Error occured. TERMINATING..."
    Write-Host -ForegroundColor Red "Error message: $Error[0].exception.message"
    pause
    exit
}
finally{}

switch (@($computers).Count) {
    0 {
        Write-Host -ForegroundColor DarkMagenta "No computer found. Terminating..."
        pause
        exit
    }
    1 { 
        get_details($computers) 
        Write-Host -ForegroundColor Yellow "-------------------------- SEARCH COMPLETE, PRESS ENTRE TO EXIT +"
        pause
        exit
    }
    default {
        for ($i=0; $i -lt $computers.Length; $i++) {
            get_details($computers[$i])
        }
        Write-Host -ForegroundColor Yellow "-------------------------- SEARCH COMPLETE, PRESS ENTRE TO EXIT +"
        pause
        exit
    }
}
