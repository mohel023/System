$UserCredential = Get-Credential labexchange\administrator
Set-ExecutionPolicy RemoteSigned
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://mail.comiky.fr/PowerShell/ -Authentication Basic -Credential $UserCredential
Import-PSSession $Session

Import-Csv -Path C:\Scripts\creation.csv -Delimiter "," | %{

$Lastname = $_.LastName
$FirstName = $_.FirstName
$primarySmtpAddress = $_.PrimarySmtpAddress
$Password = $_.Password
$Localisation = $_.Localisation
$Name = "$firstname $LastName"
$Alias = "$firstname.$LastName"
$Type = $_.Type

if((Get-Recipient $primarysmtpaddress -ErrorAction Silentlycontinue) -eq $null){

###MAILBOX
if($type -eq "mailbox"){
    write-host -ForegroundColor Cyan "Création mailbox $Name"
    New-Mailbox -Name "$FirstName $LastName" -DisplayName "$Name" -FirstName "$FirstName" -LastName "$LastName" -UserPrincipalName $primarySmtpAddress -Password (ConvertTo-SecureString -String $Password -AsPlainText -Force) -Alias $Alias -OrganizationalUnit "labexchange.local/labexchange/$Localisation" -PrimarySmtpAddress $primarySmtpAddress -AddressBookPolicy "ABP-$Localisation"
}

#### GROUP
if($type -eq "groupe"){
$GroupMembers = $_.GroupMembers -split ","
    write-host -ForegroundColor Cyan "Création groupe $Name"
    New-DistributionGroup -Name "$Name" -Alias "$Alias" -ManagedBy @('admin@comiky.fr') -OrganizationalUnit "labexchange.local/labexchange/$Localisation" -MemberJoinRestriction 'Open' -MemberDepartRestriction 'Open' -PrimarySmtpAddress $primarySmtpAddress

$GroupMembers | %{
    write-host -ForegroundColor Yellow "Ajout de $_ dans le groupe $Name"
    Add-DistributionGroupMember $Alias -Member $_
}}

###ROOM
if($type -eq "Room"){
    write-host -ForegroundColor Yellow "Creation de la salle $Name"
    $Capacity = $_.Capacity
    New-Mailbox -Name "$Name" -DisplayName "$Name" -ResourceCapacity "$capacity" -Alias "$Alias" -OrganizationalUnit "labexchange.local/labexchange/$Localisation" -Room:$true -PrimarySmtpAddress $primarySmtpAddress
}

###EQUIPMENT
if($type -eq "Equipment"){
    write-host -ForegroundColor Yellow "Creation de l'équipement $Name"
    New-Mailbox -Name "$Name" -DisplayName "$Name" -Alias "$Alias" -OrganizationalUnit "labexchange.local/labexchange/$Localisation" -Equipment:$true -PrimarySmtpAddress $primarySmtpAddress
}

###Contact
if($type -eq "Contact"){
    write-host -ForegroundColor Yellow "Creation du contact $Name"
    New-MailContact -ExternalEmailAddress "$primarySmtpAddress" -Alias "$alias" -FirstName "$firstname" -LastName "$lastname" -Name "$Name" -DisplayName "$Name" -OrganizationalUnit "labexchange.local/labexchange/$Localisation"
}

###Shared
if($type -eq "shared"){
    $Fullaccess = $_.FullAccess -split ","
    write-host -ForegroundColor Yellow "Creation de la boite partagée $Name"
    New-Mailbox -Name "$name" -DisplayName "$Name" -Shared:$true -Alias "$alias" -OrganizationalUnit "labexchange.local/labexchange/$Localisation" -PrimarySmtpAddress $primarySmtpAddress 
    $Fullaccess | %{
    Add-MailboxPermission $primarySmtpAddress -User $_ -AccessRights 'FullAccess'
    }
}}
else{write-host -ForegroundColor Red "$Name existe déjà"}
}
