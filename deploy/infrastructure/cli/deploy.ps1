# set variables
# $resourceGroupPrefix = "myagi-2-rg-"
# $location = "eastus"
# $rgIndex = 1
# $subscriptionId = "8e620752-fda6-4e8a-964f-16ba80e797ae"

param (
    [string]$resourceGroupPrefix = "myagi-1-rg-",
    [string]$location = "eastus",
    [string]$resourceGroupCount = 1,
    [string]$subscriptionId = "SubscriptionId is required"
)

# print variables

Write-Host "resourceGroupPrefix: $resourceGroupPrefix"
Write-Host "location: $location"
Write-Host "resourceGroupCount: $resourceGroupCount"
Write-Host "subscriptionId: $subscriptionId"

# set rgIndex to resourceGroupCount

$rgIndex = $resourceGroupCount

# set all these to false the first time you run this script. After that you can set them to true to skip creating resources that already exist
$skipRg = "false"
$skipOpenAI = "false"
$skipEmbeddingModelDeployment = "false"
$skipCompletionModelDeployment = "false"
$skipcognitiveSearch = "false"


# create resource groups in a loop for rgIndex
# if skipRg is true, skip creating resource group

if ($skipRg -eq "true") {
    Write-Host "Skipping resource group creation"
}
else {

    for ($i = 1; $i -le $rgIndex; $i++) {
        Write-Host "Creating resource group $resourceGroupPrefix$i in $location"
        az group create --name "$resourceGroupPrefix$i" --location $location
    }
}
   
# create Azure Open AI service resource for each resource group

for ($i = 1; $i -le $rgIndex; $i++) {
    # if skipRg is true, skip creating resource group
    if ($skipOpenAI -eq "true") {
        Write-Host "Skipping OpenAI resource creation"
    }
    else {
        Write-Host "Creating Azure Open AI service resource in $resourceGroupPrefix$i"
    
        az cognitiveservices account create `
            --name "MyOpenAIResource-$i" `
            --resource-group "$resourceGroupPrefix$i" `
            --kind "OpenAI" `
            --sku "s0" `
            --subscription $subscriptionId 
    }
    
    # if skipEmbeddingModelDeployment is true, skip embedding model deployment

    if ($skipEmbeddingModelDeployment -eq "true") {
        Write-Host "Skipping embedding model deployment"
    }
    else {
        # deploy embedding model

        Write-Host "Deploying embedding model "MyEmbeddingModel$i""

        az cognitiveservices account deployment create `
            --name "MyOpenAIResource-$i" `
            --resource-group  "$resourceGroupPrefix$i" `
            --deployment-name "MyEmbeddingModel$i" `
            --model-name text-embedding-ada-002 `
            --model-version "2"  `
            --model-format "OpenAI" `
    
    }
    
    # if skipCompletionModelDeployment is true, skip completion model deployment

    if ($skipCompletionModelDeployment -eq "true") {
        Write-Host "Skipping completion model deployment"
    }
    else {
        # deploy completion model

        Write-Host "Deploying completion model "MyCompletionModel$i""

        az cognitiveservices account deployment create `
            --name "MyOpenAIResource-$i" `
            --resource-group  "$resourceGroupPrefix$i" `
            --deployment-name "MyCompletionModel$i" `
            --model-name "gpt-35-turbo" `
            --model-version "0301"  `
            --model-format "OpenAI" `
      
    }

    # if skipcognitiveSearch is false, create cognitive search service with semantic search capability

    if ($skipcognitiveSearch -eq "true") {
        Write-Host "Skipping cognitive search service creation"
    }
    else {
        
        Write-Host "Creating cognitive search service mycognitivesearchservice-$i in $resourceGroupPrefix$i"
        
        az deployment group create `
        --resource-group "$resourceGroupPrefix$i" `
        --template-file "./bicep/search-service.bicep" `
        --parameters "searchServiceName=mycognitivesearchservice-$i"
            
     
    }

 

}




