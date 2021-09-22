#######################################################
#                                                     #       
#                                                     #
#   Provide Admin Consent for Azure AD Applications   #
#              Programmatically.                      #
#                                                     #
#                                                     #    
#          Using Client Credentials                   #
#                                                     #
#                                                     #
# Note: Currently this script works for Microsoft     #
# Graph API, but it can be changed by modifying the   #
# resourceID variable with appropriate                #
# servicePrincipal id of the required API             #
#######################################################

Connect-AzureAD 
$clientId = "" # ---> This App Id is used to request a token from AAD for performing the operation using client_credential flow.
$clientSecret = ""
$tenantId = ""

$tokenEndpoint = "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token"

$targetApp = Read-Host -Prompt "Enter Application Name (for which Admin Permissions to be granted) "
$targetAppid = (Get-AzureADApplication -SearchString $targetApp).AppId
$targetAppServicePrincipalID = (Get-AzureADServicePrincipal -All $true | where {$_.AppId -eq $targetAppid}).ObjectId

#Resource ID --> The who would be consuming the token for eg: the API. 
#Here the $resourceID variable holds the value of GraphAggregatorService's ServicePrincipalID 
$resourceID = "68edd7c9-8274-4a52-90c6-3d45aa573a4e"

$scope = "Group.Read.All, Directory.ReadWrite.All"

$TokenRequestBody = @{
    Grant_Type     = "client_credentials"
    Scope          = "https://graph.microsoft.com/.default"
    client_Id      = $clientId
    client_Secret  = $clientSecret
}

$Token = Invoke-RestMethod -Uri $tokenEndpoint -Method Post -Body $TokenRequestBody

#update the startTime and expiryTime in current UTC time
$apiBody = @{
    clientId    = $targetAppServicePrincipalID
    consentType = "AllPrincipals"
    principalId = $null
    resourceId  = $resourceID
    scope       = $scope
    startTime   = "2020-08-10T07:45:00Z"
    expiryTime  = "2020-08-10T10:37:00Z"
}

$apiHeader = @{
    Authorization = "$($Token.token_type) $($Token.access_token)"
}

$apiUrl = "https://graph.microsoft.com/beta/oauth2PermissionGrants"
Invoke-RestMethod -Uri $apiUrl -Headers $apiHeader -Method Post -Body $($apiBody | ConvertTo-Json) -ContentType "application/json" -Verbose