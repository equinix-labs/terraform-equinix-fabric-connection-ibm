output "fabric_connection_id" {
  value = module.equinix-fabric-connection-ibm.fabric_connection_uuid
}

output "fabric_connection_name" {
  value = module.equinix-fabric-connection-ibm.fabric_connection_name
}

output "fabric_connection_status" {
  value = module.equinix-fabric-connection-ibm.fabric_connection_status
}

output "network_edge_bgp_state" {
  description = "Network Edge device BGP peer state."
  value       = module.equinix-fabric-connection-ibm.network_edge_bgp_state
}

output "network_edge_bgp_provisioning_status" {
  description = "Network Edge device BGP peering configuration provisioning status."
  value       = module.equinix-fabric-connection-ibm.network_edge_bgp_provisioning_status
}

output "ibm_dl_virtual_connection_id" {
  value = module.equinix-fabric-connection-ibm.ibm_dl_virtual_connection_id
}

output "ibm_dl_gateway_id" {
  value = module.equinix-fabric-connection-ibm.ibm_dl_gateway_id
}
