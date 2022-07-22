locals {
  ibm_dl_gateway = [
    for gw in data.ibm_dl_gateways.this.gateways: gw
    if gw.name == local.connection_name
  ][0]

  ibm_dl_gateway_id = local.ibm_dl_gateway.id

  ibm_resource_group_name = coalesce(var.ibm_resource_group_name, format("rg-%s", random_string.this.result))
  ibm_resource_group_id = var.ibm_create_resource_group ? ibm_resource_group.this[0].id : data.ibm_resource_group.this[0].id

  is_windows = substr(pathexpand("~"), 0, 1) == "/" ? false : true // if directories use "/" for root then OS linux based, otherwise set windows
  os         = data.external.os.result.os

  connection_name = coalesce(var.fabric_connection_name, upper(format("IBM-%s-%s", coalesce(var.fabric_destination_metro_code, substr(var.fabric_destination_metro_name, 0, 2)), random_string.this.result)))
}

data "external" "os" {
  working_dir = "${path.module}/scripts/"
  program = local.is_windows ? ["{\"os\": \"win\"}"] : ["/bin/bash", "check_linux_os.sh"]
}

data "ibm_resource_group" "this" {
  count = var.ibm_create_resource_group ? 0 : 1

  name = local.ibm_resource_group_name
}

resource "ibm_resource_group" "this" {
  count = var.ibm_create_resource_group ? 1 : 0

  name     = local.ibm_resource_group_name
  tags     = var.ibm_tags
}

resource "random_string" "this" {
  length  = 3
  special = false
}

module "equinix-fabric-connection" {
  source = "equinix-labs/fabric-connection/equinix"
  version = "0.3.1"

  depends_on = [
    null_resource.confirm_direct_link_gateway_deletion
  ]

  # required variables
  notification_users = var.fabric_notification_users

  # optional variables
  name = local.connection_name

  seller_profile_name       = "IBM Cloud Direct Link 2"
  seller_metro_code         = var.fabric_destination_metro_code
  seller_metro_name         = var.fabric_destination_metro_name

  seller_authorization_key  = var.ibm_account_id

  network_edge_id           = var.network_edge_device_id
  network_edge_interface_id = var.network_edge_device_interface_id
  port_name                 = var.fabric_port_name
  vlan_stag                 = var.fabric_vlan_stag
  service_token_id          = var.fabric_service_token_id
  speed                     = var.fabric_speed
  speed_unit                = "MB"
  purchase_order_number     = var.fabric_purchase_order_number

  additional_info = concat([
    {
      name  = "ASN"
      value = var.ibm_direct_link_bgp_customer_asn
    }
  ], var.ibm_direct_link_bgp_customer_peer_ip != "" ? [
    {
      name = "CER IPv4 CIDR"
      value = var.ibm_direct_link_bgp_customer_peer_ip
    },
    {
      name = "IBM IPv4 CIDR"
      value = format("%s/%s", var.ibm_direct_link_bgp_cloud_peer_ip, split("/", var.ibm_direct_link_bgp_customer_peer_ip)[1])
    }
  ] : [])
}

data "ibm_dl_gateways" "this" {
  depends_on = [
    module.equinix-fabric-connection
  ]
}

//Resource implementation to accept the connection on IBM side
resource "null_resource" "confirm_direct_link_gateway_creation" {
  depends_on = [
    data.ibm_dl_gateways.this
  ]

  triggers = {
    gw_id = local.ibm_dl_gateway_id
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/bin/${local.os}"
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : ["/bin/bash" ,"-c"]

    command = "./ibm-manage-dl-gateway approve-creation -api-key=$API_KEY -gateway-id=$GATEWAY_ID -resource-group-id=$RESOURCE_GROUP -global-routing=$GLOBAL_ROUTING -metered=$METERED -connection-mode=$CONN_MODE"
    environment = {
      API_KEY        = var.ibm_api_key
      GATEWAY_ID     = local.ibm_dl_gateway_id
      RESOURCE_GROUP = local.ibm_resource_group_id
      GLOBAL_ROUTING = var.ibm_dl_routing_type == "global" ? true : false
      METERED        = var.ibm_dl_billing_type == "metered" ? true : false
      CONN_MODE      = var.ibm_dl_connection_mode
    }
  }
}

//Resource implementation to delete the connection on IBM side
resource "null_resource" "confirm_direct_link_gateway_deletion" {
  depends_on = [
    ibm_resource_group.this
  ]

  triggers = {
    gw_name    = local.connection_name
    api_key    = var.ibm_api_key
    is_windows = local.is_windows
    os         = local.os
  }

  provisioner "local-exec" {
    when        = destroy
    working_dir = "${path.module}/bin/${self.triggers.os}"
    interpreter = "${self.triggers.is_windows}" ? ["PowerShell", "-Command"] : ["/bin/bash" ,"-c"]

    command = "./ibm-manage-dl-gateway approve-deletion -api-key=${self.triggers.api_key} -gateway-name=${self.triggers.gw_name}"
  }
}

resource "equinix_network_bgp" "this" {
  count = alltrue([var.network_edge_device_id != "", var.network_edge_configure_bgp]) ? 1 : 0

  depends_on = [
    null_resource.confirm_direct_link_gateway_creation
  ]

  connection_id      = module.equinix-fabric-connection.primary_connection.uuid
  local_ip_address   = local.ibm_dl_gateway.bgp_cer_cidr
  local_asn          = local.ibm_dl_gateway.bgp_asn
  remote_ip_address  = split("/", local.ibm_dl_gateway.bgp_ibm_cidr)[0]
  remote_asn         = local.ibm_dl_gateway.bgp_ibm_asn
  //TODO authentication_key
}

resource "ibm_dl_virtual_connection" "this"{
  count = var.ibm_dl_connection_mode == "direct" && var.ibm_create_dl_virtual_connection ? 1 : 0

  depends_on = [
    null_resource.confirm_direct_link_gateway_creation
  ]

  gateway = local.ibm_dl_gateway_id
  name = format("dl-vc-%s", random_string.this.result)
  type = "vpc"
  network_id = var.ibm_vpc_id
}
