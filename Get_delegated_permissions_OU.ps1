#To get delegated permissions for an Organizational Unit (OU) using PowerShell, you can use the following steps:


Import-Module ActiveDirectory
$OU = Get-ADOrganizationalUnit -Identity "OU=MyOU,DC=example,DC=com" -Properties nTSecurityDescriptor
$OU.nTSecurityDescriptor.Access

#For example, to list only the trustee names and their corresponding permissions, you can use the following code snippet:

$OU.nTSecurityDescriptor.Access | ForEach-Object {
    $ace = $_
    $trustee = $ace.IdentityReference.Value
    $permissions = $ace.FileSystemRights
    [PSCustomObject]@{
        Trustee = $trustee
        Permissions = $permissions
    }
}


#To apply the same delegated permissions from one Organizational Unit (OU) to a different OU using PowerShell, you can follow these steps:

$sourceOU = Get-ADOrganizationalUnit -Identity "OU=SourceOU,DC=example,DC=com" -Properties nTSecurityDescriptor
$destinationOU = Get-ADOrganizationalUnit -Identity "OU=DestinationOU,DC=example,DC=com"

$destinationOU | Set-ADOrganizationalUnit -Replace @{nTSecurityDescriptor = $sourceOU.nTSecurityDescriptor}
