# Connect to Azure using the Automation Run As account
$connection = Get-AutomationConnection -Name 'AzureRunAsConnection'
Connect-AzAccount -ServicePrincipal -TenantId $connection.TenantId -ApplicationId $connection.ApplicationId -CertificateThumbprint $connection.CertificateThumbprint

# Set the Azure Analysis Services model information
$resourceGroupName = "YourResourceGroup"
$serverName = "YourAnalysisServicesServer"
$databaseName = "YourDatabaseName"

# Refresh the Azure Analysis Services model
$refreshJob = Invoke-ASCmd -Server $serverName -Database $databaseName -Refresh

if ($refreshJob.Status -eq "Succeeded") {
    Write-Output "Refresh succeeded."
} else {
    Write-Output "Refresh failed."
}
