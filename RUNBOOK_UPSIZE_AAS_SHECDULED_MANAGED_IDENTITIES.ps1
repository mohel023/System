# Set the Azure Analysis Services instance information
$resourceGroupName = "YourResourceGroup"
$serverName = "YourAnalysisServicesServer"

# Get the access token for the Azure Analysis Services resource using Managed Identity
$accessToken = Invoke-RestMethod -Method GET -Headers @{Metadata="true"} -Uri "$env:MSI_ENDPOINT?resource=https://*.asazure.windows.net&api-version=2017-09-01"

# Scale up the Azure Analysis Services instance from S0 to S1 using the access token
$scaleUrl = "https://management.azure.com/subscriptions/YourSubscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.AnalysisServices/servers/$serverName?api-version=2016-05-16"
$scaleBody = @{
    properties = @{
        sku = @{
            name = "S1"
        }
    }
} | ConvertTo-Json
Invoke-RestMethod -Method PATCH -Headers @{Authorization = "Bearer $accessToken"} -Uri $scaleUrl -ContentType "application/json" -Body $scaleBody

Write-Output "Successfully scaled up the Azure Analysis Services instance to S1."
