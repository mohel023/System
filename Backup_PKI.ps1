Voici un exemple de script PowerShell qui crée une tâche planifiée pour effectuer une sauvegarde régulière de la PKI en y incluant la date dans le nom du fichier de sauvegarde :

```powershell
# Spécifiez les chemins de sauvegarde
$backupPath = "C:\Backup\PKI"
$certExportPath = "$backupPath\Certificates"
$caConfigPath = "$backupPath\CAConfig"

# Créer les dossiers de sauvegarde s'ils n'existent pas
New-Item -ItemType Directory -Path $backupPath -ErrorAction Stop
New-Item -ItemType Directory -Path $certExportPath -ErrorAction Stop
New-Item -ItemType Directory -Path $caConfigPath -ErrorAction Stop

# Obtenir la date actuelle
$date = Get-Date -Format "yyyyMMdd"

# Exporter tous les certificats de l'ordinateur
$certificates = Get-ChildItem -Path Cert:\LocalMachine\My -ErrorAction Stop
$certificates | ForEach-Object {
    $fileName = "$certExportPath\$($_.Thumbprint)_$date.cer"
    Export-Certificate -Cert $_ -FilePath $fileName -Force
}

# Sauvegarder la configuration de l'autorité de certification (CA)
$caConfig = Get-CARoleService | Export-CARoleService -Path "$caConfigPath\CAConfig_$date.xml" -Force

Write-Host "La sauvegarde de la PKI a été effectuée avec succès le $date."
```

Ce script est similaire à l'exemple précédent, mais il ajoute la date au nom des fichiers de sauvegarde. La date est obtenue à l'aide de la commande `Get-Date` avec le format "yyyyMMdd", ce qui donne une date sous la forme "20230603".

Assurez-vous de spécifier les chemins de sauvegarde appropriés en modifiant les variables `$backupPath`, `$certExportPath`, et `$caConfigPath` selon vos besoins.

Pour créer une tâche planifiée exécutant ce script, vous pouvez utiliser la commande `Register-ScheduledTask` de PowerShell. Par exemple :

```powershell
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File ""C:\Path\to\YourScript.ps1"""
$trigger = New-ScheduledTaskTrigger -Daily -At "23:00"  # Exécution quotidienne à 23h00
Register-ScheduledTask -TaskName "PKI Backup" -Action $action -Trigger $trigger -User "DOMAIN\Username" -Password "Password" -RunLevel Highest
```

Assurez-vous de spécifier le chemin d'accès complet de votre script dans l'argument `-Argument` de la commande `New-ScheduledTaskAction`. Modifiez également le déclencheur (`$trigger`) selon vos besoins.

N'oubliez pas de remplacer "DOMAIN\Username" par le nom d'utilisateur et le domaine appropriés, et "Password" par le mot de passe du compte qui exécutera la tâche planifiée.
