#!/bin/bash

# **************** Global variables
export IC_API_KEY=YOUR_CLOUD_API_KEY
export TF_LOG=debug
export REGION="us-south"
export SSH_KEY_PUBLIC='YOUR_PUBLIC_SSH_KEY'
export SSH_KEY_NAME_VPC='vpcvsisamplekey'
export GROUP="default"

# **************** logon with IBM Cloud CLI **************** 

echo "*********************************"
echo ""
echo " Logon with IBM Cloud CLI "
ibmcloud login --apikey $IC_API_KEY
ibmcloud target -r $REGION
ibmcloud target -g $GROUP
ibmcloud plugin install vpc-infrastructure
ibmcloud plugin update
ibmcloud plugin list
ibmcloud is target --gen 2

ibmcloud is key-create $SSH_KEY_NAME_VPC $SSH_KEY_PUBLIC  --resource-group-name $GROUP
ibmcloud is keys

# **************** init **************** 

echo "*********************************"
echo ""
echo "Initialize Terraform on IBM Cloud"
terraform init

# **************** plan **************** 

echo "*********************************"
echo ""
echo "Generate a Terraform on IBM Cloud execution plan for the VPC infrastructure resources"
terraform plan

# **************** apply *************** 

echo "*********************************"
echo ""
echo "Apply a the Terraform on IBM Cloud execution plan for the VPC infrastructure resources"
# terraform apply

echo "*********************************"
echo ""
echo "Verify the setup with the IBM Cloud CLI"

ibmcloud is vpcs
ibmcloud is subnets
ibmcloud is security-groups
ibmcloud is floating-ips
ibmcloud is keys
# ibmcloud is images


echo "*********************************"
echo ""
echo "Verify the created VPC instructure on IBM Cloud: https://cloud.ibm.com/vpc-ext/vpcLayout"
read ANYKEY

# **************** destroy ************* 
echo "*********************************"
echo ""
echo "Remove VPC infrastructure resources"
terraform destroy
