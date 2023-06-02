output "fabric_connection_uuid" {
  description = "Unique identifier of the connection."
  value       = module.equinix-fabric-connection.primary_connection.uuid
}

output "fabric_connection_name" {
  description = "Name of the connection."
  value       = module.equinix-fabric-connection.primary_connection.name
}

output "fabric_connection_speed" {
  description = "Connection speed."
  value       = module.equinix-fabric-connection.primary_connection.speed
}

output "fabric_connection_speed_unit" {
  description = "Connection speed unit."
  value       = module.equinix-fabric-connection.primary_connection.speed_unit
}

output "fabric_connection_seller_metro" {
  description = "Connection seller metro code."
  value       = module.equinix-fabric-connection.primary_connection.seller_metro_code
}

output "fabric_connection_seller_region" {
  description = "Connection seller region."
  value       = module.equinix-fabric-connection.primary_connection.seller_region
}

output "network_edge_bgp_state" {
  description = "Network Edge device BGP peer state."
  value       = try(equinix_network_bgp.this[0].state, null)
}

output "network_edge_bgp_provisioning_status" {
  description = "Network Edge device BGP peering configuration provisioning status."
  value       = try(equinix_network_bgp.this[0].provisioning_status, null)
}

output "ibm_direct_link_bgp_customer_peer_ip" {
  description = "BGP Peer ID for the router on the Equinix end of the BGP session."
  value       = local.ibm_dl_gateway.bgp_cer_cidr
}

output "ibm_direct_link_bgp_customer_asn" {
  description = "The autonomous system (AS) number for Border Gateway Protocol (BGP) configuration on the Equinix end of the BGP session."
  value       = local.ibm_dl_gateway.bgp_asn
}

output "ibm_direct_link_bgp_cloud_peer_ip" {
  description = "BGP Peer ID for the router on the IBM end of the BGP session."
  value       = local.ibm_dl_gateway.bgp_ibm_cidr
}

output "ibm_direct_link_bgp_cloud_asn" {
  description = "The autonomous system (AS) number for Border Gateway Protocol (BGP) configuration on the IBM end of the BGP session."
  value       = local.ibm_dl_gateway.bgp_ibm_asn
}

output "ibm_dl_virtual_connection_id" {
  description = "The ID of the Virtual connection between the gateway and your VPC."
  value       = try(ibm_dl_virtual_connection.this[0].id, null)
}

output "ibm_dl_gateway_id" {
  description = "The ID of the Direct Link Gateway."
  value       = local.ibm_dl_gateway_id
}
