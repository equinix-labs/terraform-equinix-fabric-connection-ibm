variable "fabric_notification_users" {
  type        = list(string)
  description = "A list of email addresses used for sending connection update notifications."

  validation {
    condition     = length(var.fabric_notification_users) > 0
    error_message = "Notification list cannot be empty."
  }
}

variable "fabric_connection_name" {
  type        = string
  description = "Name of the connection resource that will be created. It will be auto-generated if not specified."
  default     = ""
}

variable "fabric_destination_metro_code" {
  type        = string
  description = <<EOF
  Destination Metro code where the connection will be created. If you do not know the code, 'fabric_destination_metro_name'
  can be use instead.
  EOF
  default     = ""

  validation {
    condition = (
      var.fabric_destination_metro_code == "" ? true : can(regex("^[A-Z]{2}$", var.fabric_destination_metro_code))
    )
    error_message = "Valid metro code consits of two capital leters, i.e. 'FR', 'SV', 'DC'."
  }
}

variable "fabric_destination_metro_name" {
  type        = string
  description = <<EOF
  Only required in the absence of 'fabric_destination_metro_code'. Metro name where the connection will be created,
  i.e. 'Frankfurt', 'Silicon Valley', 'Ashburn'. One of 'fabric_destination_metro_code', 'fabric_destination_metro_name'
  must be provided.
  EOF
  default     = ""
}

variable "network_edge_device_id" {
  type        = string
  description = "Unique identifier of the Network Edge virtual device from which the connection would originate."
  default     = ""
}

variable "network_edge_device_interface_id" {
  type        = number
  description = <<EOF
  Applicable with 'network_edge_device_id', identifier of network interface on a given device, used for a connection.
  If not specified then first available interface will be selected.
  EOF
  default     = 0
}

variable "network_edge_configure_bgp" {
  type        = bool
  description = <<EOF
  Applicable with 'network_edge_device_id'. Creation and management of Equinix Network Edge BGP
  peering configurations.
  EOF
  default     = false
}

variable "fabric_port_name" {
  type        = string
  description = <<EOF
  Name of the buyer's port from which the connection would originate. One of 'fabric_port_name',
  'network_edge_device_id' or 'fabric_service_token_id' is required.
  EOF
  default     = ""
}

variable "fabric_vlan_stag" {
  type        = number
  description = <<EOF
  S-Tag/Outer-Tag of the primary connection - a numeric character ranging from 2 - 4094. Required if 'port_name' is
  specified.
  EOF
  default     = 0
}

variable "fabric_service_token_id" {
  type        = string
  description = <<EOF
  Unique Equinix Fabric key shared with you by a provider that grants you authorization to use their interconnection
  asset from which the connection would originate.
  EOF
  default     = ""
}

variable "fabric_speed" {
  type        = number
  description = <<EOF
  Speed/Bandwidth in Mbps to be allocated to the connection. If not specified, it will be used the minimum bandwidth
  available for the AWS service profile.
  EOF
  default     = 0

  validation {
    condition = contains([0, 50, 100, 200, 500, 1000, 2000, 5000], var.fabric_speed)
    error_message = "Valid values are (0, 50, 100, 200, 500, 1000, 2000, 5000)."
  }
}

variable "fabric_purchase_order_number" {
  type        = string
  description = "Connection's purchase order number to reflect on the invoice."
  default     = ""
}

variable "ibm_account_id" {
  type = string
  description = <<EOF
  Your `IBM Cloud account ID`. Log in to the IBM Cloud console and select Manage > Account to
  locate your IBM account ID."
  EOF
}

variable "ibm_direct_link_bgp_customer_asn" {
  type        = number
  description = <<EOF
  The autonomous system (AS) number for Border Gateway Protocol (BGP) configuration on the Equinix
  end of the BGP session. Excluded ASNs: 0, 13884, 36351, 64512, 64513, 65100, 65201-65234,
  65402-65433, 65500 and 4-Byte ASNs: 420106500-4201065999.
  EOF
  default     = 65000
}

variable "ibm_direct_link_bgp_customer_peer_ip" {
  type        = string
  description = <<EOF
  The BGP IPv4 address (in CIDR notation) for the router on the Equinix end of the BGP session,
  e.g. `169.254.0.1/16`. The value must reside in one of: 10.254.0.0/16, 172.16.0.0/12,
  192.168.0.0/16, 169.254.0.0/16 or an owned Public IP. Mandatory if
  'ibm_direct_link_bgp_cloud_peer_ip' is entered. Customer peer IP and Cloud peer IP must reside
  in same network.
  EOF
  default     = ""
}

variable "ibm_direct_link_bgp_cloud_peer_ip" {
  type        = string
  description = <<EOF
  The BGP IPv4 address for IBM's end of the BGP session. Customer peer IP and Cloud peer IP must
  reside in same network, e.g.: customer peer ip 10.254.30.77/30 and cloud peer ip 10.254.30.78
  EOF
  default     = ""
}

variable "ibm_api_key" {
  type = string
  description = <<EOF
  The IBM Cloud platform API key. You must either add this variable or leave default "" and source it from the
  IC_API_KEY (higher precedence) or IBMCLOUD_API_KEY environment variable.

  NOTE: Even if you using other authentication method for the ibm terraform provider, the key (using the variable or
  an environment variable) is required to approve the IBM Direct Link gateway connection using IBM cloud go SDK. To
  create an API key, in the IBM Cloud console, go to Manage > Access (IAM) > API keys.
  EOF
  default = ""
}

variable "ibm_dl_connection_mode" {
  type        = string
  description = <<EOF
  Direct Link Connection mode. Mode 'transit' indicates this gateway will be attached to Transit
  Gateway Service and 'direct' means this gateway will be attached to vpc or classic connection.
  Valid values are: 'direct', 'transit'.
  EOF
  default     = "direct"

  validation {
    condition = (contains(["direct", "transit"], var.ibm_dl_connection_mode))
    error_message = "Valid values are (direct, transit)."
  }
}

variable "ibm_dl_routing_type" {
  type        = string
  description = <<EOF
  Direct Link routing type. When 'global' gateway can connect to networks outside of their
  associated region. Default is 'local'. Valid values are: 'local', 'global'.
  EOF
  default     = "local"

  validation {
    condition = (contains(["local", "global"], var.ibm_dl_routing_type))
    error_message = "Valid values are (local, global)."
  }
}

variable "ibm_dl_billing_type" {
  type        = string
  description = <<EOF
  Direct Link billing type. When 'metered' gateway usage is billed per gigabyte. When 'unmetered' there is no per gigabyte
  usage charge, instead a flat rate is charged for the gateway. Default is 'metered'.
  EOF
  default     = "metered"

  validation {
    condition = (contains(["metered", "unmetered"], var.ibm_dl_billing_type))
    error_message = "Valid values are (metered, unmetered)."
  }
}

variable "ibm_create_resource_group" {
  type        = bool
  description = "Create an IBM Resource Group in which to create the resources."
  default     = true
}

variable "ibm_resource_group_name" {
  type        = string
  description = <<EOF
  The name of the resource group in which to create the resources. If unspecified, it will be
  auto-generated. Required if 'ibm_create_resource_group' is set to 'false'.
  EOF
  default     = ""
}

variable "ibm_tags" {
  type        = list(string)
  description = "Tags for IBM Cloud resources."

  default = [ "Terraformed" ]
}

variable "ibm_create_dl_virtual_connection" {
  type = bool
  description = <<EOF
  Whether to connect the Direct Link gateway with an existing VPC. If true, 'ibm_vpc_id' must be
  provided and 'ibm_dl_connection_mode' must be set to 'direct'.
  EOF
  default = false
}

variable "ibm_vpc_id" {
  type        = string
  description = <<EOF
  The ID of the VPC to connect with the IBM Direct Link gateway. Applicable if
  'ibm_create_dl_virtual_connection' is true.
  EOF
  default     = ""
}
