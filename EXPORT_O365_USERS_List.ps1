# Connect to Exchange Online
$credentials = Get-Credential
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credentials -Authentication "Basic" -AllowRedirection
Import-PSSession $session -AllowClobber

# Get all Office 365 users
$users = Get-Mailbox -ResultSize Unlimited | Select-Object UserPrincipalName

# Output user information with licenses
$report = @()
foreach ($user in $users) {
    $userPrincipalName = $user.UserPrincipalName
    $license = (Get-MsolUser -UserPrincipalName $userPrincipalName).Licenses | Select-Object -ExpandProperty AccountSkuId
    $report += [PSCustomObject]@{
        UserPrincipalName = $userPrincipalName
        License = $license
    }
}

# Disconnect from Exchange Online
Remove-PSSession $session

# Export the report to a CSV file
$report | Export-Csv -Path "C:\UsersAndLicenses.csv" -NoTypeInformation
