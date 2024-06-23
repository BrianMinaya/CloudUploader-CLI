#!/bin/bash

# Prompt for Azure environment variables
read -p "Enter Azure Client ID: " AZURE_CLIENT_ID
read -p "Enter Azure Client Secret: " AZURE_CLIENT_SECRET
read -p "Enter Azure Tenant ID: " AZURE_TENANT_ID
read -p "Enter Azure Storage Account Name: " AZURE_STORAGE_ACCOUNT
read -p "Enter Azure Storage Container Name: " AZURE_STORAGE_CONTAINER

# Validate if all variables are provided
if [ -z "$AZURE_CLIENT_ID" ] || [ -z "$AZURE_CLIENT_SECRET" ] || [ -z "$AZURE_TENANT_ID" ] || [ -z "$AZURE_STORAGE_ACCOUNT" ] || [ -z "$AZURE_STORAGE_CONTAINER" ]; then
    echo "Error: Please provide all required values."
    exit 1
fi

# Save the environment variables to a .env file
cat << EOF > .env
AZURE_CLIENT_ID="$AZURE_CLIENT_ID"
AZURE_CLIENT_SECRET="$AZURE_CLIENT_SECRET"
AZURE_TENANT_ID="$AZURE_TENANT_ID"
AZURE_STORAGE_ACCOUNT="$AZURE_STORAGE_ACCOUNT"
AZURE_STORAGE_CONTAINER="$AZURE_STORAGE_CONTAINER"
EOF

# Displays saved environment variables to user
echo "AZURE_CLIENT_ID: $AZURE_CLIENT_ID"
echo "AZURE_CLIENT_SECRET: ********"
echo "AZURE_TENANT_ID: $AZURE_TENANT_ID"
echo "AZURE_STORAGE_ACCOUNT: $AZURE_STORAGE_ACCOUNT"
echo "AZURE_STORAGE_CONTAINER: $AZURE_STORAGE_CONTAINER"

# Secure the .env file
chmod 600 .env   # Restrict file permissions

echo "Environment variables saved securely to .env file."

