### SOURCE : https://technet.microsoft.com/fr-fr/library/dd298065(v=exchg.150).aspx
$admin? = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")

if ($admin? -like "*False*"){write-host "Veuillez lancez le script en tant qu'administrateur"}
else{

$Server = read-host "Merci de renseigner le serveur à mettre en maintenance. Exemple : Exchange01"

write-host -foregroundcolor White  "Etape 1/9 - Processus  drainage des files d’attente de transport"
Set-ServerComponentState $Server -Component HubTransport -State Draining -Requester Maintenance
Pause

write-host -foregroundcolor White "Etape 2/9 - Lancement du drainage des files d’attente de transport"
Restart-Service MSExchangeTransport
pause

write-host -foregroundcolor White "Etape 3/9 - Redirection des messages en attente de remise dans les files d’attente locales vers un autre serveur"
$Server2 = read-host "Meci de renseigner le nom du serveur vers lequel rediriger les files d'attentes, exemple : Exchange01.mydomain.local"
Redirect-Message -Server $Server -Target $Server2
Pause

write-host -foregroundcolor White "Etape 4/9 - Empecher le serveur d’être et de devenir le PAM (Primary Active Manager)"
Suspend-ClusterNode $Server
Get-ClusterNode $Server | fl
Pause

write-host -foregroundcolor White "Etape 5/9 - Déplacement de toutes les bases de données actives"
Set-MailboxServer $Server -DatabaseCopyActivationDisabledAndMoveNow $True
Pause

Write-host -foregroundcolor White "Etape 6/9 - Etape pour empêcher le serveur d’héberger des copies de base de données active"
Set-MailboxServer $Server -DatabaseCopyAutoActivationPolicy Blocked
pause

Write-host -foregroundcolor White "Etape 7/9 - Mise en mode maintenance du serveur"
Set-ServerComponentState $Server -Component ServerWideOffline -State Inactive -Requester Maintenance

Write-host -foregroundcolor White "Etape 8/9 - Verification que le serveur est en mode maintenant"
Get-ServerComponentState $Server | ft Component,State -Autosize

Write-host -foregroundcolor White "Etape 9/9 - Vérification des files d'attente"
Get-Queue

Write-host -foregroundcolor Green "Il faut patienter quelques minutes le temps que les bascules s'effectuent"}


