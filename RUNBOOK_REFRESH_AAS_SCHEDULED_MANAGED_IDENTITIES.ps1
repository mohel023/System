# Set the Azure Analysis Services model information
$resourceGroupName = "YourResourceGroup"
$serverName = "YourAnalysisServicesServer"
$databaseName = "YourDatabaseName"

# Get the access token for the Azure Analysis Services resource using Managed Identity
$accessToken = Invoke-RestMethod -Method GET -Headers @{Metadata="true"} -Uri "$env:MSI_ENDPOINT?resource=https://*.asazure.windows.net&api-version=2017-09-01"

# Refresh the Azure Analysis Services model using the access token
$refreshUrl = "https://$($serverName).asazure.windows.net/$($databaseName)/refreshes"
Invoke-RestMethod -Method POST -Headers @{Authorization = "Bearer $accessToken"} -Uri $refreshUrl

Write-Output "Refresh triggered successfully."
