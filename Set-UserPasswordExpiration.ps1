#requires -version 1
<#
.SYNOPSIS
  Set Password Expiration to be disabled via Microsoft Graph API
.DESCRIPTION
  Set Password Policy for user(s) to not expire via Microsoft Graph API
.PARAMETER <Parameter_Name>
    None
.INPUTS
  None
.OUTPUTS
  Application Log and out to a log file at C:\log
.NOTES
  Version:        1.0
  Author:         Richard B
  Creation Date:  14/12/2022 (UK FORMAT)
  Purpose/Change: Initial script development
 
  
.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>

.TODO
 Choose what logging to use not both application and output to dile
#>## 

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = '1.0'
$RequireScriptVersion = '1.0'

# Powershell Version

$versionMinimum = '7.1'

#----------------------------------------------------------[Script]----------------------------------------------------------#
#Set Powershell Execution Policy
try { Set-ExecutionPolicy Unrestricted }
catch {
    Write-Host "An error occured:"
    Write-Host $_
    }

# Register New Log Source
try { New-EventLog -LogName Application -Source 'LabScript' }
catch {
    Write-Host "An error occured:"
    Write-Host $_
    }

# Check Meets Requirements of Powershell and Script Version
if ($versionMinimum -gt $PSVersionTable.PSVersion -AND $sScriptVersion -eq $RequireScriptVersion) 
{
    # Check PowerShell Version and Script Version
    

    Write-EventLog -LogName Application -Source 'LabScript' -EntryType Information -EventId 1 -Message "Powershell Version $versionMinimum installed"
}
else
{
    Write-EventLog -LogName Application -Source 'LabScript' -EntryType Information -EventId 1 -Message "Powershell Version $versionMinimum Not available"
}
# Install Microsoft Graph
# Install if not present
Install-Module Microsoft.Graph -Scope CurrentUser

# Date and time for logging
$Date = Get-Date -Format "dddd MM/dd/yyyy HH:mm K"

# Logging Function
# $Logfile = "C:\Path\to\Logs\$$(gc env:computername).log"
$Logfile = "C:\Logs\$(Get-Content env:computername).log"

Function LogWrite
{
   Param ([string]$logstring)

   Add-content $Logfile -value $logstring
}
# Connect to Azure AD
Connect-MgGraph -Scopes User.ReadWrite.All
Udate-MgUser -PasswordPolicies DisablePasswordExpiration