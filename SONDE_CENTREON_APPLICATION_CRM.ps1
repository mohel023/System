# Vérification de l'état de l'application CRM
$crmStatus = Get-CrmStatus

# Vérification du statut de l'application CRM
if ($crmStatus -eq "Running") {
    Write-Host "OK - CRM application is running"
    exit 0  # Code de retour pour Centreon en cas de succès
} else {
    Write-Host "CRITICAL - CRM application is not running"
    exit 2  # Code de retour pour Centreon en cas d'erreur critique
}
