#To find expired tokens for each application in Azure AD, you can retrieve the list of applications using Azure PowerShell and then iterate through them to check for expired tokens. Here's an example script:

```powershell
# Install AzureAD module if not already installed
Install-Module -Name AzureAD

# Connect to Azure AD
Connect-AzureAD

# Get all applications in Azure AD
$applications = Get-AzureADApplication

# Loop through each application
foreach ($application in $applications) {
    $applicationId = $application.AppId
    $accessToken = (Get-AzureADServicePrincipalCredential -ObjectId $application.ObjectId).SecretText

    # Get the token lifetime policies for the application
    $url = "https://graph.microsoft.com/v1.0/applications/$applicationId/tokenLifetimePolicies"
    $response = Invoke-RestMethod -Uri $url -Headers @{Authorization = "Bearer $accessToken"}

    # Filter expired tokens
    $expiredTokens = $response.value | Where-Object { $_.validUntil -lt (Get-Date) }

    # Output expired tokens for the current application
    if ($expiredTokens) {
        Write-Host "Expired tokens for application: $($application.DisplayName)"
        $expiredTokens | Select-Object displayName, validUntil
        Write-Host
    }
}
```

