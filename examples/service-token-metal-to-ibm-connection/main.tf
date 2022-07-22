# Configure the Equinix Provider
# Please refer to provider documentation for details on supported authentication methods and parameters.
# https://registry.terraform.io/providers/equinix/equinix/latest/docs
provider "equinix" {
  client_id     = var.equinix_provider_client_id
  client_secret = var.equinix_provider_client_secret
}

# Configure the IBM Provider
# https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs#argument-reference
provider "ibm" { 
  ibmcloud_api_key = var.ibm_api_key // To create an API key, in the IBM Cloud console, go to Manage > Access (IAM) > API keys.
  region           = var.ibm_region // If unspecified, default region "us-south" (Dallas) will be used.
}

## Retrieve an existing equinix metal project
## If you prefer you can use resource equinix_metal_project instead to create a fresh project
data "equinix_metal_project" "this" {
  project_id = var.metal_project_id
}

## Create an IBM VPC
## Comment out this block if ibm_create_dl_virtual_connection is false
## If you prefer you can use data ibm_is_vpc instead to use an existing VPC
resource "ibm_is_vpc" "this" {
  name = format("vpc-metal-ibm-%s", lower(var.fabric_destination_metro_code))
}

locals {
  connection_name = format("conn-metal-ibm-%s", lower(var.fabric_destination_metro_code))
}

# Create a new VLAN in Frankfurt
resource "equinix_metal_vlan" "this" {
  description = format("VLAN in %s", var.fabric_destination_metro_code)
  metro       = var.fabric_destination_metro_code
  project_id  = data.equinix_metal_project.this.project_id
}

## Request a connection service token in Equinix Metal
resource "equinix_metal_connection" "this" {
    name               = local.connection_name
    project_id         = data.equinix_metal_project.this.project_id
    metro              = var.fabric_destination_metro_code
    redundancy         = "primary"
    type               = "shared"
    service_token_type = "a_side"
    description        = format("connection to IBM in %s", var.fabric_destination_metro_code)
    speed              = format("%dMbps", var.fabric_speed)
    vlans              = [equinix_metal_vlan.this.vxlan]
}

## Configure the Equinix Fabric connection from Equinix Metal to AWS using the metal connection service token
module "equinix-fabric-connection-ibm-primary" {
  source = "equinix-labs/fabric-connection-ibm/equinix"
  
  fabric_notification_users         = var.fabric_notification_users
  fabric_connection_name            = local.connection_name
  fabric_destination_metro_code     = var.fabric_destination_metro_code
  fabric_speed                      = var.fabric_speed
  fabric_service_token_id           = equinix_metal_connection.this.service_tokens.0.id
  
  ibm_account_id = var.ibm_account_id
  ibm_api_key    = var.ibm_api_key

  ibm_create_dl_virtual_connection = true
  ibm_vpc_id                       = ibm_is_vpc.this.id // required if ibm_create_dl_virtual_connection is true
  
  ## BGP Configuration
  # ibm_direct_link_bgp_customer_peer_ip = "10.254.30.77/30" // If unspecified, it will be auto-generated
  # ibm_direct_link_bgp_cloud_peer_ip    = "10.254.30.78" // If unspecified, it will be auto-generated
  # ibm_direct_link_bgp_customer_asn     = 65000 // If unspecified, default value "65000" will be used
}
