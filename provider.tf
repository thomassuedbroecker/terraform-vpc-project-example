terraform {
 required_providers {
   ibm = {
      source = "IBM-Cloud/ibm"
      version = "1.26.2"
    }
  }
}

############################
# Variables
############################

variable "ibmcloud_api_key" {}
variable "iaas_classic_username" {}
variable "iaas_classic_api_key" {}
variable "region" {}
variable "my_ssh_key_name" {}

############################
# Configure the IBM Provider
############################

provider "ibm" {
  ibmcloud_api_key    = var.ibmcloud_api_key
  iaas_classic_username = var.iaas_classic_username
  iaas_classic_api_key  = var.iaas_classic_api_key
  region = var.region
}

############################
# Create a VPC with VSI
############################

# Locals and variables
locals {
   BASENAME = "example"
   ZONE     = "us-south-1"
}

# Existing SSH key can be provided
data "ibm_is_ssh_key" "ssh_key_id" {
   name = var.my_ssh_key_name
}

############################
# Virtual Private Cloud
############################

# Virtual Private Cloud
resource "ibm_is_vpc" "vpc-instance" {
  name = "${local.BASENAME}-vpc"
}

# Security group
resource "ibm_is_security_group" "sg1" {
   name = "${local.BASENAME}-sg1"
   vpc  = ibm_is_vpc.vpc-instance.id
}

# allow all incoming network traffic on port 22
resource "ibm_is_security_group_rule" "example-ingress_ssh_all" {
   group     = ibm_is_security_group.sg1.id
   direction = "inbound"
   remote    = "0.0.0.0/0"

   tcp {
     port_min = 22
     port_max = 22
   }
}

# Subnet 
resource "ibm_is_subnet" "subnet1" {
   name                     = "${local.BASENAME}-subnet1"
   vpc                      = ibm_is_vpc.vpc-instance.id
   zone                     = local.ZONE
   total_ipv4_address_count = 256
}

############################
# Virtual Servicer Instance
############################

# Image for Virtual Server Insance
data "ibm_is_image" "centos" {
   name = "ibm-centos-7-6-minimal-amd64-1"
}

# Virtual Server Insance
resource "ibm_is_instance" "vsi1" {
   name    = "${local.BASENAME}-vsi1"
   vpc     = ibm_is_vpc.vpc-instance.id
   keys    = [data.ibm_is_ssh_key.ssh_key_id.id]
   zone    = local.ZONE
   image   = data.ibm_is_image.centos.id
   profile = "cx2-2x4"
   
   # References to the subnet and security groups
   primary_network_interface {
     subnet          = ibm_is_subnet.subnet1.id
     security_groups = [ibm_is_security_group.sg1.id]
   }
}

# Request a foaling ip 
resource "ibm_is_floating_ip" "fip1" {
   name   = "${local.BASENAME}-fip1"
   target = ibm_is_instance.vsi1.primary_network_interface[0].id
}

# Try to logon to the Virtual Service Instance
output "sshcommand" {
   value = "ssh root@ibm_is_floating_ip.fip1.address"
}