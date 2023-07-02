# Vérification de l'espace disque disponible sur le lecteur C:
$drive = "C:"
$threshold = 10  # Seuil d'espace disque bas en pourcentage

$disk = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='$drive'"
$freeSpacePercent = ($disk.FreeSpace / $disk.Size) * 100

# Comparaison avec le seuil
if ($freeSpacePercent -lt $threshold) {
    Write-Host "CRITICAL - Low disk space on drive $drive: $freeSpacePercent%"
    exit 2  # Code de retour pour Centreon en cas d'erreur critique
} else {
    Write-Host "OK - Disk space on drive $drive: $freeSpacePercent%"
    exit 0  # Code de retour pour Centreon en cas de succès
}
