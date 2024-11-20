$OU = read-host "Nom de l'OU ?"

Write-host -ForegroundColor Yellow "OK pour actualiser / Annuler pour quitter"

$RapportImportPST = Get-MailboxImportRequest | ?{$_.Mailbox -like "*$OU*"} | Get-MailboxImportRequestStatistics | Sort-Object -Property @{Expression = "StatusDetail"; Descending = $True} | select FilePath,StatusDetail,PercentComplete,Message | Out-GridView -PassThru -Title "OK pour actualiser" 

do{
if($RapportImportPST -eq $null) {
& '.\Exchange.ps1'
}
else {
$RapportImportPST = Get-MailboxImportRequest | ?{$_.Mailbox -like "*$OU*"} | Get-MailboxImportRequestStatistics | Sort-Object -Property @{Expression = "StatusDetail"; Descending = $True} | select FilePath,StatusDetail,PercentComplete,Message | Out-GridView -PassThru -Title "OK pour actualiser" }
}
until(1 -eq 2)
clear