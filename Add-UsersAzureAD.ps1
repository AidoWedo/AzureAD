# MS Doc Reference
# https://learn.microsoft.com/en-us/powershell/module/azuread/new-azureaduser?view=azureadps-2.0
# Install Azure AD PowerShell Module is deprecated

# Install if not present
# Install-Module az

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

# Set csv path 'C:\Path\to\users.csv'
$csvFilePath = 'C:\Users\bob\Documents\GitHub\Azure\AzureADUserCreateTemplatePowerShell.csv' 
 
# Get the CSV file and convert it to an array
$csvData = Import-Csv -Path $csvFilePath
 
# Connect to Azure AD
Connect-MgGraph -Scopes "User.Read.All", "Group.ReadWrite.All", "Directory.ReadWrite.All" -UseDeviceAuthentication
        
# Loop through each user in the array
foreach ($user in $csvData)
{
    # Get the current user
    $currentUser = Get-MgUser -UserId $user.UserPrincipalName | select-object UserPrincipalName

    # Check if current user is found
    if ($currentUser -eq $null)
    {
        Import-Module Microsoft.Graph.Users
        $newUserParams = @{
            DisplayName = $user.DisplayName
            UserPrincipalName = $user.UserPrincipalName
            AccountEnabled = $true
            GivenName = $user.GivenName
            Surname = $user.Surname
            MailNickName = $user.MailNickName
            JobTitle = $user.JobTitle
            CompanyName = $user.CompanyName
            Department = $user.Department
            StreetAddress = $user.StreetAddress
            State = $user.State
            Country = $user.Country
            City = $user.City
            PostalCode = $User.PostalCode
            BusinessPhones = $user.TelephoneNumber
            PasswordProfile = @{
                ForceChangePasswordNextSignIn = $false
                Password = "User-123!"}
        } 
        New-MgUser -BodyParameter $newUserParams}
    else
    {
        LogWrite "$Date The UserPrincipalName $currentUser already exists moving on"
    }
}
# Disconnect from Graph
Disconnect-MgGraph