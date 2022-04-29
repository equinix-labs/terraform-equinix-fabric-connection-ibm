// Please check https://registry.terraform.io/providers/equinix/equinix/latest/docs#argument-reference
// for other supported authentication methods and parameters.
provider "equinix" {
  # client_id = "" // (Optional)  To create a Client ID(Consumer Key) - Client Secret(Consumer Secret) pair, in developer.equinix.com portal, go to App Dashborad > New App.
  # client_secret = "" // (Optional)
}

// Please check https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs#argument-reference
// for other supported authentication methods and parameters.
provider "ibm" { 
  # ibmcloud_api_key = "" // (Optional) To create an API key, in the IBM Cloud console, go to Manage > Access (IAM) > API keys.
  # region = "eu-de" // (Optional) default is "us-south" (Dallas).
}

module "equinix-fabric-connection-ibm" {
  source = "equinix-labs/fabric-connection-ibm/equinix"
 
  # required variables
  fabric_notification_users = ["example@equinix.com"]
  ibm_account_id            = var.ibm_account_id

  # optional variables
  fabric_port_name              = var.port_name
  fabric_vlan_stag              = 1010
  fabric_destination_metro_code = "FR"

  ibm_direct_link_bgp_customer_peer_ip = "10.254.30.77/30"
  ibm_direct_link_bgp_cloud_peer_ip    = "10.254.30.78"

  fabric_connection_name = "IBM-TEST-OCM"
}
