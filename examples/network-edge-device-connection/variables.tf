variable "device_id" {
  type = string
  description = <<EOF
  The ID of the (Network Edge virtual device](https://github.com/equinix/terraform-provider-equinix/tree/master/examples/edge-networking)
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
