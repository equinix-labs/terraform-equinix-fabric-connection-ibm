variable "equinix_provider_client_id" {
  type        = string
  description = <<EOF
  API Consumer Key available under 'My Apps' in developer portal. This argument can also be specified with the
  EQUINIX_API_CLIENTID shell environment variable.
  EOF
  default     = null
}

variable "equinix_provider_client_secret" {
  type        = string
  description = <<EOF
  API Consumer secret available under 'My Apps' in developer portal. This argument can also be specified with the
  EQUINIX_API_CLIENTSECRET shell environment variable.
  EOF
  default     = null
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

variable "fabric_port_name" {
  type        = string
  description = <<EOF
  (Required) Name of the [Equinix Fabric port](https://docs.equinix.com/en-us/Content/Interconnection/Fabric/ports/Fabric-port-details.htm)
  from which the connection would originate.
  EOF
}

variable "ibm_account_id" {
  type        = string
  description = <<EOF
  (Required) Your `IBM Cloud account ID`. Log in to the IBM Cloud console and select Manage > Account > Account
  settings to locate your IBM account ID."
  EOF
}
