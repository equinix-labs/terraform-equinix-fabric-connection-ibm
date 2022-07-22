terraform {  
  required_version = ">= 0.13"

  required_providers {
    equinix = {
      source  = "equinix/equinix"
      version = ">= 1.7.0"
    }
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.12.0"
    }
  }
}
