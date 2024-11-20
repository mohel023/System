$OU = read-host "OU Cible ?"

$UNC = read-host "Veuillez indiquer le chemin déjà existant où exporter les PST (exemple : \\192.168.1.150\PST\ )"  ################# !!!!!!!!!!!!!! #####################

#Controle du partage
$try = New-Item -ItemType file -Value "Test" $UNC\test.txt -ErrorAction SilentlyContinue
$try = get-content $UNC\test.txt -ErrorAction SilentlyContinue
if($try -eq $null)
{write-host -ForegroundColor Yellow "Le chemin UNC n'est pas valide"
& '.\Exchange.ps1'
}
else{Remove-Item $UNC\test.txt}

write-host -ForegroundColor Yellow "Les export se font 3 par 3. Ne fermez pas la fênetre Powershell avant la fin."

Get-Mailbox -OrganizationalUnit labexchange.local/labexchange/$OU | Out-GridView -OutputMode Multiple -Title "Choisissez les boites à exporter" | %{   ################# !!!!!!!!!!!!!! #####################

$Address = $_.PrimarySmtpAddress
write-host "Export de la boite $_"
New-MailboxExportRequest -Mailbox "$Address" -FilePath "$UNC$Address.pst"

do{
$try = Get-MailboxExportRequest -Status InProgress
start-sleep 10
}
until($try.count -lt "3")
}
pause