# Spécifiez les informations de connexion au serveur Linux via WinSCP
$linuxServer = "linux.example.com"
$linuxUsername = "username"
$linuxPassword = "password"
$linuxDestinationPath = "/path/to/destination"

# Spécifiez le chemin de sauvegarde local
$backupPath = "C:\Backup\SystemState"

# Créer le dossier de sauvegarde s'il n'existe pas
New-Item -ItemType Directory -Path $backupPath -ErrorAction Stop

# Sauvegarder le System State du contrôleur de domaine
Backup-ADDSForest -BackupPath $backupPath -Force

# Ajouter la date à la destination du dossier de sauvegarde
$date = Get-Date -Format "yyyyMMdd"
$destinationPathWithDate = "$linuxDestinationPath\$date"

# Créer une session WinSCP
$sessionOptions = New-Object WinSCP.SessionOptions -Property @{
    Protocol = [WinSCP.Protocol]::Sftp
    HostName = $linuxServer
    UserName = $linuxUsername
    Password = $linuxPassword
}
$session = New-Object WinSCP.Session
$session.Open($sessionOptions)

# Copier le dossier de sauvegarde vers le serveur Linux
$transferOptions = New-Object WinSCP.TransferOptions
$transferOptions.TransferMode = [WinSCP.TransferMode]::Binary
$transferResult = $session.PutFiles($backupPath, $destinationPathWithDate, $False, $transferOptions)

# Vérifier si la copie s'est bien déroulée
if ($transferResult.IsSuccess) {
    Write-Host "La sauvegarde du System State et la copie vers le serveur Linux ont été effectuées avec succès."
} else {
    Write-Host "La copie du dossier de sauvegarde vers le serveur Linux a échoué. Erreur : $($transferResult.Failures[0].Message)"
}

# Fermer la session WinSCP
$session.Dispose()
