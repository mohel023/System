# Connect to Azure using the Automation Run As account
$connection = Get-AutomationConnection -Name 'AzureRunAsConnection'
Connect-AzAccount -ServicePrincipal -TenantId $connection.TenantId -ApplicationId $connection.ApplicationId -CertificateThumbprint $connection.CertificateThumbprint

# Set the Azure Analysis Services instance information
$resourceGroupName = "YourResourceGroup"
$serverName = "YourAnalysisServicesServer"

# Scale up the Azure Analysis Services instance from S0 to S1
$scaledInstance = Set-AzAnalysisServicesServer -ResourceGroupName $resourceGroupName -Name $serverName -Tier "S1" -Force

if ($scaledInstance) {
    Write-Output "Successfully scaled up the Azure Analysis Services instance to S1."
} else {
    Write-Output "Failed to scale up the Azure Analysis Services instance."
}
