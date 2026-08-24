#!/bin/bash

createBackend() {
    echo "Creating S3 bucket for Terraform backend..."

    aws s3api create-bucket \
        --bucket bkt-togglemaster-tfstate \
        --region us-east-1

    echo "Enabling versioning for the S3 bucket..."
    aws s3api put-bucket-versioning \
        --bucket bkt-togglemaster-tfstate \
        --versioning-configuration Status=Enabled
    
    echo "Backend S3 bucket created and versioning enabled."
}