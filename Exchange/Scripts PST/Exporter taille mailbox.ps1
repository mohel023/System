$OU = read-host "OU cible ?"

Remove-Item  C:\Scripts\$OU.csv -ErrorAction SilentlyContinue  ################# !!!!!!!!!!!!!! #####################

$header=@"
Address,Nom d'affichage,Dernière connexion,Taille en GB
"@

$header | Add-Content  "C:\Scripts\$OU.csv"  ################# !!!!!!!!!!!!!! #####################

Get-Mailbox -OrganizationalUnit labexchange.local/labexchange/$OU | ?{$_.RecipientTypeDetails -eq "UserMailbox"} | Sort-Object TotalItemSize  | %{  ################# !!!!!!!!!!!!!! #####################

$Address = $_.PrimarySmtpAddress

$List = Get-MailboxStatistics "$Address"

$DisplayName = $List.DisplayName  

$LastLogonTime = $List.LastLogonTime

$TotalSize = $List.TotalItemSize.Value

$TotalSize = $TotalSize.ToString().Split(“(“)[1].Split(” “)[0].Replace(“,”,””)/1GB

$TotalSize  = [math]::Round($TotalSize,2)

Add-Content C:\Scripts\$OU.csv -Value "$Address,$DisplayName,$LastLogonTime,$TotalSize"

}

Write-host -ForegroundColor Green "Rapport pret ici : C:\Scripts\$OU.csv"  ################# !!!!!!!!!!!!!! #####################

Pause

Clear

& '.\Exchange.ps1'
