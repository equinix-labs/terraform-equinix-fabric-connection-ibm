terraform {
  required_version = ">= 0.13"

  required_providers {
    equinix = {
      source  = "equinix/equinix"
      version = "~> 1.14"
    }
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.12.0"
    }
  }
  provider_meta "equinix" {
    module_name = "equinix-fabric-connection-ibm"
  }
}
