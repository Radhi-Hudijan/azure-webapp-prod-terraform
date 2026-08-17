#!/bin/bash

set -euo pipefail  # Exit on error, unset variable, or error in a pipeline

RESOURCE_GROUP_NAME=tfstate1
STORAGE_ACCOUNT_NAME=tfstate$RANDOM
CONTAINER_NAME=tfstate1
LOCATION=eastus

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME \
 --name $STORAGE_ACCOUNT_NAME  \
 --sku Standard_LRS \
  --encryption-services blob \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false

# Enable blob versioning 
az storage account blob-service-properties update \
 --resource-group $RESOURCE_GROUP_NAME \
 --account-name $STORAGE_ACCOUNT_NAME \
 --enable-versioning true


# Create blob container
az storage container create \
 --name $CONTAINER_NAME \
 --account-name $STORAGE_ACCOUNT_NAME \
 --auth-mode login \

 # print the storage account name and container name for reference
 echo "----------"
 echo "Backend created successfully!✅"
 echo "Storage Account Name: $STORAGE_ACCOUNT_NAME"
 echo "Container Name: $CONTAINER_NAME"