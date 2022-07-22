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

variable "ibm_account_id" {
  type = string
  description = <<EOF
  (Required) Your `IBM Cloud account ID`. Log in to the IBM Cloud console and select Manage > Account > Account
  settings to locate your IBM account ID.
  EOF
}

variable "ibm_vpc_name" {
  type        = string
  description = "(Required) The name of an existing VPC."
}

variable "ibm_region" {
  type        = string
  description = <<EOF
  Destination Metro code where the connection will be created. One of: us-south, us-east, eu-gb, eu-de, jp-tok,
  au-syd.
  EOF
  default     = "us-south"
}

variable "metal_project_id" {
  type        = string
  description = "(Required) ID of the project where the connection is scoped to, used to look up the project."
}

variable "fabric_notification_users" {
  type        = list(string)
  description = "A list of email addresses used for sending connection update notifications."
  default     = ["example@equinix.com"]
}

variable "fabric_destination_metro_code" {
  type        = string
  description = "Destination Metro code where the connection will be created."
  default     = "SV"
}

variable "fabric_speed" {
  type        = number
  description = <<EOF
  Speed/Bandwidth in Mbps to be allocated to the connection. If unspecified, it will be used the minimum
  bandwidth available for the `Equinix Metal` service profile. Valid values are (50, 100, 200, 500, 1000, 2000, 5000,
  10000).
  EOF
  default     = 50
}