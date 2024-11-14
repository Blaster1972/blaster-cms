#!/bin/bash

# Define the domain names and their webroot paths in WSL (update paths as necessary)
declare -A domains=( 
    ["blaster.ddns.net"]="/home/blaster/projects/blaster-cms/staticfiles_collected/.well-known/acme-challenge"
    ["droid7.ddns.net"]="/home/blaster/projects/blaster-cms/staticfiles_collected/.well-known/acme-challenge"
    ["mixitup-endpoint.ddns.net"]="/home/blaster/projects/blaster-cms/staticfiles_collected/.well-known/acme-challenge"
)

# Certbot path in WSL (assumes Certbot is installed in WSL)
certbotPath="/usr/bin/certbot"
email="newsithempire1@gmail.com"

# Define the base directory for the certs inside OneDrive (for cross-device access)
certDirBase="/mnt/c/Users/james/OneDrive/Documents/blaster-cms/nginx/certs"

# Define paths for Certbot config, work, and log directories
configDir="/home/blaster/certbot/config"
workDir="/home/blaster/certbot/work"
logsDir="/home/blaster/certbot/logs"

# Loop through each domain and request certificates
for domain in "${!domains[@]}"; do
    webrootPath="${domains[$domain]}"

    # Create the domain directory inside the certs folder in OneDrive
    certDir="$certDirBase/$domain"
    mkdir -p "$certDir"

    # Define paths for the obtained certificate and private key
    fullchainSource="/etc/letsencrypt/live/$domain/fullchain.pem"
    privkeySource="/etc/letsencrypt/live/$domain/privkey.pem"

    # Check if both the certificate and private key already exist
    if [[ -f "$fullchainSource" && -f "$privkeySource" ]]; then
        echo "Certificate for $domain already exists."
    else
        # Request the certificate using Certbot with custom directories
        sudo $certbotPath certonly --webroot --email "$email" --agree-tos --no-eff-email --webroot-path "$webrootPath" -d "$domain" --config-dir "$configDir" --work-dir "$workDir" --logs-dir "$logsDir"

        # Check if certificate was successfully created
        if [[ -f "$fullchainSource" && -f "$privkeySource" ]]; then
            echo "Certificate for $domain obtained."
        else
            echo "Error: Certificate for $domain could not be obtained."
            continue
        fi
    fi

    # Copy the certificates to the cert directory in OneDrive
    cp "$fullchainSource" "$certDir/certificate.crt"
    cp "$privkeySource" "$certDir/private.key"

    echo "Certificates copied for $domain."
done

echo "All certificates processed."
