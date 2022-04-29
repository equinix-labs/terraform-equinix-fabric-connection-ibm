variable "port_name" {
  type        = string
  description = <<EOF
  Name of the [Equinix Fabric port](https://docs.equinix.com/en-us/Content/Interconnection/Fabric/ports/Fabric-port-details.htm)
  from which the connection would originate.
  EOF
}

variable "ibm_account_id" {
  type = string
  description = <<EOF
  Your `IBM Cloud account ID`. Log in to the IBM Cloud console and select Manage > Account > Account settings to
  locate your IBM account ID."
  EOF
}
