### SOURCE : https://technet.microsoft.com/fr-fr/library/dd298065(v=exchg.150).aspx
$admin? = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")

if ($admin? -like "*False*"){write-host "Veuillez lancez le script en tant qu'administrateur"}
else{
$Server = read-host "Merci de renseigner le nom du serveur à remettre en production. Exemple : MUTCVXSRPEXC001"

write-host -foregroundcolor White "Etape 1/7 Indique que le serveur n’est pas en mode maintenance"
Set-ServerComponentState $Server -Component ServerWideOffline -State Active -Requester Maintenance
write-host -foregroundcolor White "Etape 2/7 Verification que le serveur n'est pas en mode maintenance"
Get-ServerComponentState $Server | ft Component,State -Autosize
Pause

write-host -foregroundcolor White "Etape 3/7 Reprise du node dans le cluster"
Resume-ClusterNode $Server
Pause

write-host -foregroundcolor White  "Etape 4/7 Permettre aux bases de données de devenir actives sur le serveur"
Set-MailboxServer $Server -DatabaseCopyActivationDisabledAndMoveNow $False
Get-MailboxServer $Server | ft databasecopyacti* -AutoSize
Pause

write-host -foregroundcolor White "Etape 5/7 Autorise le serveur à avoir des bases actives"
Set-MailboxServer $Server -DatabaseCopyAutoActivationPolicy Unrestricted
Get-MailboxServer $server| ft databaseCopyAutoActivationPolicy -AutoSize
Pause

Write-host -foregroundcolor White "Etape 6/7 Active les files d’attentes de transport et autorise le serveur à accepter et à traiter les messages"
Set-ServerComponentState $Server -Component HubTransport -State Active -Requester Maintenance
Pause

Write-host -foregroundcolor White "Etape 7/7 Restart du service transport"
Restart-Service MSExchangeTransport

Write-host "Remise en maintenance terminée"

Function information{
do {
    do {
        write-host -ForegroundColor Cyan "Que voulez vous faire ?"
        write-host ""
        write-host -ForegroundColor white "1 - Lancer la bascule des databases maintenant via le script Microsoft"
        write-host -ForegroundColor white "2 - Quitter le script"
        write-host -ForegroundColor Cyan -nonewline "Faite votre choix: "
        
        $choice = read-host
        
        write-host ""
        
        $ok = $choice -match '^[12]+$'
        
        if ( -not $ok) { write-host "Invalid selection" }
    } until ( $ok )
    
    switch -Regex ( $choice ) {  
    
         "1"        { & 'C:\Program Files\Microsoft\Exchange Server\V15\Scripts\RedistributeActiveDatabases.ps1'-BalanceDbsByActivationPreference -ShowFinalDatabaseDistribution ;break}
         "2"        { &  write-host "Pour la bascule des boites il est conseillé de passer par le script Microsoft : C:\Program Files\Microsoft\Exchange Server\V15\Scripts\RedistributeActiveDatabases.ps1'-BalanceDbsByActivationPreference -ShowFinalDatabaseDistribution";break}
    }
} until ( $choice -notmatch "X" )}
$Information = information
$Information
}
<#

Si vous installez une mise à jour Exchange et que l’opération échoue, certains composants de serveur peuvent rester dans un état inactif, 
ce qui sera affiché dans les résultats de la cmdlet Get-ServerComponentState ci-dessus. Pour résoudre ce problème, exécutez les commandes suivantes :

Set-ServerComponentState <ServerName> -Component ServerWideOffline -State Active -Requester Functional 
Set-ServerComponentState <ServerName> -Component Monitoring -State Active -Requester Functional 
Set-ServerComponentState <ServerName> -Component RecoveryActionsEnabled -State Active -Requester Functional 

#>