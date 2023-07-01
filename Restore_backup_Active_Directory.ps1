# Spécifiez les informations de la sauvegarde
$backupPath = "C:\Backup\ActiveDirectory"
$sourceServerName = "PreviousServer"
$targetServerName = "NewServer"

# Copier les fichiers de sauvegarde vers le nouveau serveur
Copy-Item -Path "$backupPath\*" -Destination "\\$targetServerName\$backupPath" -Recurse

# Restaurer les fichiers de sauvegarde sur le nouveau serveur
$sourceBackupPath = "\\$targetServerName\$backupPath"

# Démarrer la restauration de l'état du système
Invoke-Command -ComputerName $targetServerName -ScriptBlock {
    # Remplacer les variables avec les chemins appropriés sur le nouveau serveur
    $sourceBackupPath = "\\$using:targetServerName\$using:backupPath"
    $targetServerName = $using:targetServerName

    # Mettre le serveur en mode de récupération
    Restart-Computer -Force -Confirm:$false -Wait

    # Restaurer l'état du système à partir des fichiers de sauvegarde
    wbadmin start systemstaterecovery -version:01/01/2022 -backupTarget:$sourceBackupPath
}

# Attendre la fin de la restauration
Start-Sleep -Seconds 60

# Redémarrer le nouveau serveur
Restart-Computer -ComputerName $targetServerName -Force -Confirm:$false

# Vérifier l'état d'Active Directory sur le nouveau serveur
Write-Host "Vérification de l'état d'Active Directory sur $targetServerName..."

# Attendre que le service Active Directory soit disponible
$adService = Get-Service -ComputerName $targetServerName -Name "ADWS" -ErrorAction SilentlyContinue
while ($adService.Status -ne "Running") {
    Start-Sleep -Seconds 10
    $adService = Get-Service -ComputerName $targetServerName -Name "ADWS" -ErrorAction SilentlyContinue
}

# Vérifier l'état d'Active Directory en utilisant d'autres commandes ou outils, par exemple :
# - Test-ComputerSecureChannel
# - DCDiag
# - Ldp.exe

Write-Host "Restauration d'Active Directory terminée sur $targetServerName."
