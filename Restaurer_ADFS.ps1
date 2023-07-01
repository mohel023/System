# Spécifiez le chemin de sauvegarde
$backupPath = "C:\Backup\ADFS"

# Restaurer la configuration d'ADFS
Restore-ADFSSyncConfiguration -Path "$backupPath\ADFSConfiguration.zip" -Force
Restore-ADFSRelyingPartyTrust -Path "$backupPath\RelyingPartyTrusts.xml" -Force
Restore-ADFSCertificate -Path "$backupPath\Certificates" -Force

Write-Host "La restauration d'ADFS à partir de la sauvegarde a été effectuée avec succès."
