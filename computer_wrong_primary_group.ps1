##To find a computer with a wrong primary group in Active Directory using PowerShell, you can use the following script:


# Import the Active Directory module
Import-Module ActiveDirectory

# Set the name of the primary group
$primaryGroupName = "Domain Computers"

# Get all computer objects from Active Directory
$computers = Get-ADComputer -Filter * -Property PrimaryGroup

# Loop through each computer object
foreach ($computer in $computers) {
    # Check if the primary group is different from the specified group
    if ($computer.PrimaryGroup -ne (Get-ADGroup $primaryGroupName).DistinguishedName) {
        Write-Host "Computer Name: $($computer.Name)"
        Write-Host "Primary Group: $($computer.PrimaryGroup)"
        Write-Host "====================="
    }
}
