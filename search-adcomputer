# WILL LEAVE FOOTPRINT IN EV FROM GWMI
# WILL LEAVE FOOTPRINT IN EV FROM TEST3389 - ?
# FIX AT SOME POINT TO AVOID USING WRITE-HOST..

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
    $c_object = $computer
    $strCname = $computer.name

    Write-Host -ForegroundColor yellow "+ COMPUTER FOUND: ---------------------------------------------------------------"
    Write-Host "Computer Full AD Name:"
    Write-Host "$c_object.distinguishedname, $c_object.enabled"
    # ADD OTHER FIELDS AS NEEDED: https://msdn.microsoft.com/en-us/library/aa394102(v=vs.85).aspx

    if (($c_object.enabled) -eq "True") {
        try {
            Write-Host "IP Information:" 
            Resolve-DnsName $strCname
        }
        catch {
            Write-Host -ForegroundColor DarkMagenta "Cannot Resolve IP Address"
        }
        finally {}
    }
    else { Write-Host -ForegroundColor DarkMagenta "Cannot Resolve IP Address" }
    
    if ((test3389($strCname)) -like "True") {  # OR -CONTAINS
        try { 
            Write-Host -ForegroundColor Green "Connection(s) available."
            gwmi win32_computersystem -ComputerName $strCname | select username, model, totalphysicalmemory
        }
        catch { Write-Host -ForegroundColor DarkRed "`nNo access to additional information (error occured)." }
        finally {}
    }
    else { Write-Host -ForegroundColor Magenta "`nCannot establish connection to the computer" }
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
