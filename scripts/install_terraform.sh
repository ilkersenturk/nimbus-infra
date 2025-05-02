#!/bin/bash

if ! command -v terraform &> /dev/null
then
    echo "Terraform not found. Installing..."
    
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
    sudo yum install -y terraform

    echo "✅ Terraform installed successfully."
else
    echo "✅ Terraform is already installed. Version:"
    terraform -version
fi