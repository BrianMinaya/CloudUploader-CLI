#!/bin/bash

# Determine the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Path to the .env file
ENV_FILE="$SCRIPT_DIR/.env"

# Source the .env file to load environment variables
source "$ENV_FILE"

# Validate that necessary environment variables are set
if [ -z "$AZURE_CLIENT_ID" ] || [ -z "$AZURE_CLIENT_SECRET" ] || [ -z "$AZURE_TENANT_ID" ] || [ -z "$AZURE_STORAGE_ACCOUNT" ] || [ -z "$AZURE_STORAGE_CONTAINER" ]; then
    echo "Error: Azure credentials or storage account details not found. Ensure AZURE_CLIENT_ID, AZURE_CLIENT_SECRET, AZURE_TENANT_ID, AZURE_STORAGE_ACCOUNT, and AZURE_STORAGE_CONTAINER are set."
    echo "Please run create_env.sh script if not done so already."
    exit 1
fi

# Parse Arguments
FILE_PATH=$1
ENCRYPT=false
GENERATE_LINK=false

# Function to show usage
usage() {
    echo "Usage: $0 /path/to/file [--encrypt] [--generate-link]"
    echo "Options:"
    echo "  --encrypt        Encrypt the file before uploading."
    echo "  --generate-link  Generate and display a shareable link post-upload."
    exit 1
}

# Validate and process options
shift
while (( "$#" )); do
    case "$1" in
        --encrypt)
            ENCRYPT=true
            shift
            ;;
        --generate-link)
            GENERATE_LINK=true
            shift
            ;;
        -*|--*)
            echo "Error: Unsupported flag $1" >&2
            usage
            ;;
    esac
done

# Validate Arguments
if [ -z "$FILE_PATH" ]; then
    echo "Usage: $0 /path/to/file [--encrypt] [--generate-link]"
    echo "Please provide a proper file path."
    exit 1
fi

# Check if the file exists
if [ ! -f "$FILE_PATH" ]; then
    echo "Error: File '$FILE_PATH' not found!"
    exit 1
fi

# Authenticate with Azure CLI using service principal
az login --service-principal -u "$AZURE_CLIENT_ID" -p "$AZURE_CLIENT_SECRET" --tenant "$AZURE_TENANT_ID"

# Check if login was successful
if [ $? -ne 0 ]; then
    echo "Error: Azure CLI login failed. Please check your credentials."
    exit 1
fi

# Optionally encrypt the file
if [ "$ENCRYPT" == true ]; then
    ENCRYPTED_FILE_PATH="${FILE_PATH}.gpg"
    gpg --output "$ENCRYPTED_FILE_PATH" --symmetric "$FILE_PATH"
    if [ $? -ne 0 ]; then
        echo "Error: File encryption failed!"
        exit 1
    fi
    FILE_PATH="$ENCRYPTED_FILE_PATH"
fi

# Function to upload file with optional rename
upload_file() {
    local src_file="$1"
    local dest_name="$2"
    az storage blob upload --account-name "$AZURE_STORAGE_ACCOUNT" --container-name "$AZURE_STORAGE_CONTAINER" --file "$src_file" --name "$dest_name"
}

EXISTENCE=$(az storage blob exists --account-name "$AZURE_STORAGE_ACCOUNT" --container-name "$AZURE_STORAGE_CONTAINER" --name "$(basename "$FILE_PATH")" --query "exists")
if [ "$EXISTENCE" == "true" ]; then
    echo "File already exists in the cloud storage."
    echo "Choose an option: (O)verwrite, (S)kip, (R)ename"
    read -r choice
    case $choice in
        O|o)
            # Overwrite the existing file
            upload_file "$FILE_PATH" "$(basename "$FILE_PATH")" --overwrite
            ;;
        S|s)
            echo "Skipping upload."
            exit 0
            ;;
        R|r)
            echo "Enter new name for the file:"
            read -r new_name
            upload_file "$FILE_PATH" "$new_name"
            ;;
        *)
            echo "Invalid option. Exiting."
            exit 1
            ;;
    esac
else
    echo "File '$(basename "$FILE_PATH")' Uploading..."
    # Upload the file to Azure Blob Storage with its original name
    upload_file "$FILE_PATH" "$(basename "$FILE_PATH")"
fi

# Check if upload was successful
if [ $? -ne 0 ]; then
    echo "Error: Upload failed!"
    exit 1
else
    echo "Upload successful!"
fi

# Optionally generate and display a shareable link
if [ "$GENERATE_LINK" == true ]; then
    SAS_TOKEN=$(az storage blob generate-sas --account-name "$AZURE_STORAGE_ACCOUNT" --container-name "$AZURE_STORAGE_CONTAINER" --name "$(basename "$FILE_PATH")" --permissions r --expiry $(date -u -d "1 week" '+%Y-%m-%dT%H:%MZ') --output tsv)
    SHAREABLE_LINK="https://${AZURE_STORAGE_ACCOUNT}.blob.core.windows.net/${AZURE_STORAGE_CONTAINER}/$(basename "$FILE_PATH")?${SAS_TOKEN}"
    echo "Shareable link: $SHAREABLE_LINK"
fi
