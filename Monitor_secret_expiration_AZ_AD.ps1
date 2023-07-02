# Install required module
Install-Module -Name Microsoft.Graph.Authentication -Force

# Import required modules
Import-Module -Name Microsoft.Graph.Authentication

# Define the client application ID and secret
$clientId = "<Your_Client_ID>"
$clientSecret = "<Your_Client_Secret>"

# Define the tenant ID
$tenantId = "<Your_Tenant_ID>"

# Define the application (client) scope
$scopes = "https://graph.microsoft.com/.default"

# Define the resource URI
$resourceUri = "https://graph.microsoft.com/v1.0/"

# Define the secret ID
$secretId = "<Your_Secret_ID>"

# Authenticate with the client application
$authProvider = New-Object Microsoft.Graph.Authentication.DeviceCodeAuthProvider($clientId, $tenantId)
$accessToken = $authProvider.GetAccessToken($scopes)

# Configure the API request headers
$headers = @{
    'Authorization' = "Bearer $accessToken"
    'Content-Type' = 'application/json'
}

# Construct the API request URL
$apiUrl = $resourceUri + "applications/$clientId"

# Send the API request to retrieve the application details
$response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get

# Retrieve the secrets from the application details
$secrets = $response.passwordCredentials

# Find the secret by ID
$secret = $secrets | Where-Object { $_.id -eq $secretId }

# Check if the secret is expired
$expirationDateTime = [datetime]::parse($secret.endDateTime)
$currentTime = Get-Date

if ($expirationDateTime -lt $currentTime) {
    Write-Host "The secret has expired."
} else {
    $remainingDays = ($expirationDateTime - $currentTime).Days
    Write-Host "The secret is valid. Expires in $remainingDays days."
}
