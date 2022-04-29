## Equinix Fabric L2 Connection To IBM Direct Link 2.0 Terraform module

[![Experimental](https://img.shields.io/badge/Stability-Experimental-red.svg)](https://github.com/equinix-labs/standards#about-uniform-standards)
[![terraform](https://github.com/equinix-labs/terraform-equinix-template/actions/workflows/integration.yaml/badge.svg)](https://github.com/equinix-labs/terraform-equinix-template/actions/workflows/integration.yaml)

`terraform-equinix-fabric-connection-ibm` is a Terraform module that utilizes [Terraform provider for Equinix](https://registry.terraform.io/providers/equinix/equinix/latest) and [Terraform provider for IBM](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs) to set up an Equinix Fabric L2 connection to IBM Direct Link 2.0.

As part of Platform Equinix, your infrastructure can connect with other parties, such as public cloud providers, network service providers, or your own colocation cages in Equinix by defining an [Equinix Fabric - software-defined interconnection](https://docs.equinix.com/en-us/Content/Interconnection/Fabric/Fabric-landing-main.htm).

This module creates the l2 connection in Equinix Fabric, approves the request in your account on the IBM Cloud platform, and optionally creates a IBM Direct Link virtual connection. BGP in Equinix side can also be configured if Network Edge device is used.

```html
     Origin                                              Destination
    (A-side)                                              (Z-side)

┌────────────────┐
│ Equinix Fabric │         Equinix Fabric          ┌────────────────────┐       ┌───────────────────────┐
│ Port / Network ├─────    l2 connection   ───────►│        IBM         │──────►│      DL Gateway ─►    │
│ Edge Device /  │      (50 Mbps - 10 Gbps)        │   Direc Link 2.0   │       │ DL Virtual Connection │
│ Service Token  │                                 └────────────────────┘       │   (IBM Cloud Region)  │
└────────────────┘                                                              └───────────────────────┘
         │                                                                           │
         └ - - - - - - - - - - Network Edge Device - - - - - - - - - - - - - - - - - ┘
                                   BGP peering
```

### Usage

This project is experimental and supported by the user community. Equinix does not provide support for this project.

Install Terraform using the official guides at <https://learn.hashicorp.com/tutorials/terraform/install-cli>.

This project may be forked, cloned, or downloaded and modified as needed as the base in your integrations and deployments.

This project may also be used as a [Terraform module](https://learn.hashicorp.com/collections/terraform/modules).

To use this module in a new project, create a file such as:

```hcl
# main.tf
provider "equinix" {
}

provider "ibm" { 
  region = "eu-de" 
}

module "equinix-fabric-connection-ibm" {
  source = "equinix-labs/fabric-connection-ibm/equinix"

  # required variables
  fabric_notification_users = ["example@equinix.com"]
  ibm_account_id            = var.ibm_account_id

  # optional variables
  fabric_port_name              = var.port_name
  fabric_vlan_stag              = 1010
  fabric_destination_metro_code = "FR"
}
```

Run `terraform init -upgrade` and `terraform apply`.

### Variables

See <https://registry.terraform.io/modules/equinix-labs/fabric-connection-ibm/equinix/latest?tab=inputs> for a description of all variables.

### Outputs

See <https://registry.terraform.io/modules/equinix-labs/fabric-connection-ibm/equinix/latest?tab=outputs> for a description of all outputs.

### Resources

| Name | Type |
|------|------|
| [random_string.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [equinix-fabric-connection](https://registry.terraform.io/modules/equinix-labs/fabric-connection/equinix/latest) | module |
| [equinix_network_bgp.this](https://registry.terraform.io/providers/equinix/equinix/latest/docs/resources/equinix_network_bgp) | resource |
| [ibm_is_region.this](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/is_region) | data source |
| [ibm_resource_group.this](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/resource_group) | data source |
| [ibm_resource_group.this](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_group) | resource |
| [ibm_dl_gateways.this](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/dl_gateways) | data source |
| [ibm_dl_virtual_connection.this](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/dl_virtual_connection) | data source |
| [null_resource.confirm_direct_link_gateway_creation](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.confirm_direct_link_gateway_deletion](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [external.os](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/data_source) | data source |

### Examples

- [Fabric Port connection](https://registry.terraform.io/modules/equinix-labs/fabric-connection-ibm/equinix/latest/examples/fabric-port-connection/)
- [Network Edge device connection](https://registry.terraform.io/modules/equinix-labs/fabric-connection-ibm/equinix/latest/examples/network-edge-device-connection/)
