# Spécifiez les chemins de sauvegarde
$backupPath = "C:\Backup\PKI"
$certExportPath = "$backupPath\Certificates"
$caConfigPath = "$backupPath\CAConfig"

# Restaurer les certificats
$certFiles = Get-ChildItem -Path $certExportPath -Filter "*.cer"
foreach ($certFile in $certFiles) {
    $thumbprint = $certFile.BaseName.Split("_")[0]
    $cert = Import-Certificate -FilePath $certFile.FullName -CertStoreLocation Cert:\LocalMachine\My -Exportable
    Set-Location Cert:\LocalMachine\My
    $existingCert = Get-ChildItem -Path . -Recurse | Where-Object { $_.Thumbprint -eq $thumbprint }
    if ($existingCert) {
        Write-Host "Certificat avec le même empreinte digitale déjà présent. Suppression en cours..."
        Remove-Item -Path $existingCert.PSPath -Recurse -Force
    }
    Import-Certificate -Cert $cert -CertStoreLocation Cert:\LocalMachine\My
    Write-Host "Certificat restauré : $($certFile.Name)"
}

# Restaurer la configuration de l'autorité de certification (CA)
$configFiles = Get-ChildItem -Path $caConfigPath -Filter "*.xml"
foreach ($configFile in $configFiles) {
    $config = Import-CARoleService -Path $configFile.FullName -Force
    Set-CARoleService -Path . -Configuration $config
    Write-Host "Configuration de l'autorité de certification restaurée : $($configFile.Name)"
}

Write-Host "La restauration de la PKI à partir de la sauvegarde a été effectuée avec succès."
