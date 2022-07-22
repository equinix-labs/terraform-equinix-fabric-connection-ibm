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
  region           = "eu-de" // If unspecified, default region "us-south" (Dallas) will be used.
}

module "equinix-fabric-connection-ibm" {
  source = "equinix-labs/fabric-connection-ibm/equinix"

  # required variables
  fabric_notification_users = ["example@equinix.com"]
  ibm_account_id            = var.ibm_account_id

  # optional variables
  network_edge_device_id     = var.ne_device_id
  network_edge_configure_bgp = true

  fabric_destination_metro_code = "FR"
  fabric_speed                  = 200

  ibm_direct_link_bgp_customer_peer_ip = "10.254.30.77/30"
  ibm_direct_link_bgp_cloud_peer_ip    = "10.254.30.78"
  ibm_direct_link_bgp_customer_asn     = 65432
 
  ibm_api_key                      = var.ibm_api_key
  ibm_create_dl_virtual_connection = true
  ibm_vpc_id                       = ibm_is_vpc.this.id
}

resource "ibm_is_vpc" "this" {
  name = "example-vpc"
}