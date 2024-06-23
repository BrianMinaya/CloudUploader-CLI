# CloudUploader-CLI

CloudUploader CLI is a Bash-based command-line tool for securely uploading files to Azure Blob Storage.

## Overview

This tool allows users to upload files to Azure Blob Storage using a service principal for authentication. It supports optional features like file encryption before upload and generating shareable links post-upload.

## Prerequisites

Before using CloudUploader CLI, ensure you have the following:

- Azure account with permissions to create and manage service principals, storage accounts, and blob containers.
- Bash shell (Linux or macOS environment).
- `az` command-line tool installed. You can install it using Azure CLI installation instructions: [Install Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli).

## Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd CloudUploader

Create environment variables:
Run the create_env.sh script to set up Azure environment variables. Ensure you have your Azure service principal credentials and storage account details handy.

bash

    ./create_env.sh

    This script will prompt you to enter values for:
        AZURE_CLIENT_ID
        AZURE_CLIENT_SECRET
        AZURE_TENANT_ID
        AZURE_STORAGE_ACCOUNT
        AZURE_STORAGE_CONTAINER

    These values will be stored securely in a .env file in the project directory.

##Usage

To upload a file to Azure Blob Storage, use the cli_uploader.sh script with the following command:

##bash

./cli_uploader.sh /path/to/file [--encrypt] [--generate-link]

##Options:

    --encrypt: Encrypts the file before uploading using GPG symmetric encryption.
    --generate-link: Generates and displays a shareable link after successful upload.

Example:

Upload a file /path/to/local/file.txt to Azure Blob Storage:

bash

./cli_uploader.sh /path/to/local/file.txt --encrypt --generate-link

## Troubleshooting

If you encounter issues during setup or usage, consider the following:

    Verify Environment Variables: Ensure all required environment variables in the .env file are correctly set.
    Azure CLI Authentication: If authentication fails, run az login --service-principal manually and check for any error messages.
    File Upload Errors: Check Azure Blob Storage permissions and network connectivity.
    General Issues: Review the script's output for specific error messages and refer to Azure CLI documentation for troubleshooting tips.

## Contributing

Contributions are welcome! Fork the repository, make your changes, and submit a pull request.

### Explanation:

- **Overview:** Provides a brief introduction to what the CloudUploader CLI does.
- **Prerequisites:** Lists what is needed before using the tool.
- **Installation:** Step-by-step instructions on cloning the repository and setting up environment variables.
- **Usage:** Instructions on how to use the CLI tool, including optional flags.
- **Troubleshooting:** Guidance on common issues and how to resolve them.
- **Contributing:** Encourages others to contribute to the project.

Adjust the paths, commands, and descriptions based on your actual project setup and specific requirements. This README.md file serves as a comprehensive guide for users and contributors to understand, install, and use your CloudUploader CLI tool effectively.

