package main

import (
  "fmt"
  "github.com/IBM/go-sdk-core/core"
  "github.com/IBM/networking-go-sdk/directlinkv1"
)

func CreateGatewayActionApprove(client directlinkv1.DirectLinkV1, gwID string, isGlobal bool, isMetered bool, connMode string, resourceGroupID string) (*directlinkv1.Gateway, error) {
	action := directlinkv1.CreateGatewayActionOptions_Action_CreateGatewayApprove

	createGatewayActionOptions := client.NewCreateGatewayActionOptions(gwID, action)
	createGatewayActionOptions = createGatewayActionOptions.SetGlobal(isGlobal).SetMetered(isMetered).SetConnectionMode(connMode)
	
	if resourceGroupID != "" {
		resourceGroupIdentity, _ := client.NewResourceGroupIdentity(resourceGroupID)
		createGatewayActionOptions.SetResourceGroup(resourceGroupIdentity)
	}

	result, _, err := client.CreateGatewayAction(createGatewayActionOptions)
	if err != nil {
		return nil, fmt.Errorf("CreateGatewayAction CreateGatewayApprove Options: %+v\n - error: %w", createGatewayActionOptions, err)
	}
	return result, nil
}

func DeleteGatewayActionApprove(client directlinkv1.DirectLinkV1, gwID string) error {
	action := directlinkv1.CreateGatewayActionOptions_Action_DeleteGatewayApprove

	createGatewayActionOptions := client.NewCreateGatewayActionOptions(gwID, action)

	_, _, err := client.CreateGatewayAction(createGatewayActionOptions)
	if err != nil {
		return fmt.Errorf("CreateGatewayAction DeleteGatewayApprove Options: %+v\n - error: %w", createGatewayActionOptions, err)
	}
	return nil
}

func GetGateway(client directlinkv1.DirectLinkV1, gwID string) (*directlinkv1.Gateway, int, error) {
	getGatewayOptions := client.NewGetGatewayOptions(gwID)
	result, resp, err := client.GetGateway(getGatewayOptions)

	if err != nil {
		return nil, 0, fmt.Errorf("GetGateway Options: %+v\n - error: %w", getGatewayOptions, err)
	}
	return result, resp.StatusCode, nil
}

func ListGateways(client directlinkv1.DirectLinkV1) (*directlinkv1.GatewayCollection, error) {
	listGatewaysOptions := client.NewListGatewaysOptions()
  	result, _, err := client.ListGateways(listGatewaysOptions)

	if err != nil {
		return nil, fmt.Errorf("ListGateways Options: %+v\n - error: %w", listGatewaysOptions, err)
	}
	return result, nil
}

func NewClientWithApiKey(apiKey string) (*directlinkv1.DirectLinkV1, error) {
	authenticator := &core.IamAuthenticator{
	  ApiKey: apiKey,
	}
  
	options := &directlinkv1.DirectLinkV1Options{
	  Version: &BuildTime,
	  Authenticator: authenticator,
	}
  
	directLink, err := directlinkv1.NewDirectLinkV1UsingExternalConfig(options)
	if err != nil {
	  return nil, fmt.Errorf("NewDirectLinkV1UsingExternalConfig request: %+v\n - error: %w", options, err)
	}
	return directLink, nil
}
