# CMD tool to manage IBM Cloud Direct Link gateways

Implementation of `CreateGatewayAction` API required to confirm connections but not yet available in IBM cloud terraform provider.

## Using the tool

To approve the creation of the gateway:

`ibm-manage-dl-gateway approve-creation --api-key=<apiKey> -gateway-id=<gatewayId> -resource-group-id=<resourceGroupId> -global-routing=(true|false) -metered=(true|false) -connection-mode=(direct|transit)`

To approve the deletion of the gateway:

`ibm-manage-dl-gateway approve-deletion --api-key=<apiKey> -gateway-id=<gatewayId>`
