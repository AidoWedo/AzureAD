#requires -version 1
<#
.SYNOPSIS
  Add Users to Azure AD Groups
.DESCRIPTION
  Add Users to Azure AD Groups using Microsoft Graph API
.PARAMETER <Parameter_Name>
    None
.INPUTS
  None
.OUTPUTS
  Application Log and C:\logs
.NOTES
  Version:        1.0
  Author:         Richard B
  Creation Date:  13/12/2022 (UK FORMAT)
  Purpose/Change: Initial script development
  Standardise logging
  
.EXAMPLE
  Add Azure AD user to Group using Microsoft Graph API
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
try { New-EventLog -LogName Application -Source 'AzureADScript' }
catch {
    Write-Host "An error occured:"
    Write-Host $_
    }

# Check Meets Requirements of Powershell and Script Version
if ($versionMinimum -gt $PSVersionTable.PSVersion -AND $sScriptVersion -eq $RequireScriptVersion) 
{
    # Check PowerShell Version and Script Version
    

    Write-EventLog -LogName Application -Source 'AzureADScript' -EntryType Information -EventId 1 -Message "Powershell Version $versionMinimum installed"
}
else
{
    Write-EventLog -LogName Application -Source 'AzureADScript' -EntryType Information -EventId 1 -Message "Powershell Version $versionMinimum Not available"
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
# Get a list of DepartmentNames
# Get all users from Azure and Export as csv
# Specify location of output
$csvoutput = 'C:\Users\bob\Documents\GitHub\Azure\AzureADGroupsList.csv' 
# Get Users Departments and export to csv
# $AllDepartments = Get-MgUser -All -Property Department | Select-Object Department -Unique | Export-Csv $csvoutput
# Import Departments list and Create Groups
# Skip if Group already there
# Get the CSV file and convert it to an array
$csvGroupFilePath = $csvoutput
# Import csv
$Departments = Import-Csv -Path $csvGroupFilePath

# Search Users for a Particular Department i.e. Sales - Information only
# $Users = Get-MgUser -ConsistencyLevel eventual -Search '"Department:Sales"' | Format-List  UserPrincipalName

# Connect to Azure AD
Connect-MgGraph -Scopes "User.Read.All", "Group.ReadWrite.All", "Directory.ReadWrite.All" -UseDeviceAuthentication

# Loop through the users and add them to a group
ForEach ($Department in $Departments)
{
    # Does this Group Exist

    $currentDepartment = Get-MgGroup -Filter "DisplayName eq '$Department.Department'"

    # Check if current user is found
    if (($currentDepartment -eq $null) -or ($currentDepartment -ne $department.Department))
    {
        Import-Module Microsoft.Graph.Users
        $GroupOwner = (Get-MgUser -UserId admin@training100.safemarch.com).Id # Update the Group Owner
        $Owner = "https://graph.microsoft.com/v1.0/users/" + $GroupOwner
        $newDepartmentParams = @{
            DisplayName = $Department.Department
            MailEnabled = $false
            MailNickName = $Department.Department+ '.team'
            Description = $Department.Department+ ' team'
            SecurityEnabled = $true
            "owners@odata.bind" = @($Owner)

        } 
        New-MgGroup -BodyParameter $newDepartmentParams}
    else
    {
        LogWrite "$Date The Department $currentDepartment already exists moving on"
    }
}
# Add users to Groups
# Fetch all Groups in Azure
$groups = @(Get-MgGroup)

# Fetch All Users in Azure
Select-MgProfile beta
$users = @(Get-MgUser | Select-object Id, DisplayName, Department, JobTitle, MemberOf)
# loop through groups and add users
Import-Module Microsoft.Graph.Groups
Import-Module Microsoft.Graph.Users
ForEach($user in $users)
    {
    $targetGroupName = $($user.department)
    $currentUser = $user.DisplayName
    foreach ($group in $groups) {
        if($group.DisplayName -contains $targetGroupName)
        {
        New-MgGroupMember -GroupID $group.id -DirectoryObjectId $User.id
    continue
        }
    else {
        LogWrite "$Date The User $currentUser is part of this group $group.displayname"
    }
}
    }    
# Disconnect from Graph
# Disconnect-MgGraph