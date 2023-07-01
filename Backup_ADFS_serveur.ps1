# Spécifiez le chemin de sauvegarde
$backupPath = "C:\Backup\ADFS"

# Créer le dossier de sauvegarde s'il n'existe pas
New-Item -ItemType Directory -Path $backupPath -ErrorAction Stop

# Sauvegarder la configuration d'ADFS
Backup-ADFSSyncConfiguration -Path "$backupPath\ADFSConfiguration.zip" -Force
Backup-ADFSRelyingPartyTrust -Path "$backupPath\RelyingPartyTrusts.xml" -Force
Backup-ADFSCertificate -Path "$backupPath\Certificates" -Force

Write-Host "La sauvegarde d'ADFS a été effectuée avec succès."
