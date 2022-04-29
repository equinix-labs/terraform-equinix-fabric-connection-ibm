package main

import (
	"flag"
	"fmt"
	"os"
	"errors"
	"time"
	"math/rand"
)

var (
    apiKey string
	approveCreationCmd = flag.NewFlagSet("approve-creation", flag.PanicOnError)
	approveDeletionCmd = flag.NewFlagSet("approve-deletion", flag.PanicOnError)
)

type ErrorSlice []error

func (e ErrorSlice) Error() string {
	s := ""
	for _, err := range e {
		s += ", " + err.Error()
	}
	return "Errors: " + s
}

func setupGlobalFlags() {
    for _, fs := range []*flag.FlagSet{approveCreationCmd, approveDeletionCmd} {
		fs.StringVar(
            &apiKey,
            "api-key",
            "",
            "The IBM Cloud platform API key. You must either set the api-key flag or source it from the IC_API_KEY (higher precedence) or IBMCLOUD_API_KEY environment variable",
        )
    }
}

func checkCredentials() error{
	//TODO check other credentials types
	if apiKey == "" {
		apiKey = os.Getenv("IC_API_KEY")
		if apiKey == "" {
			apiKey = os.Getenv("IBMCLOUD_API_KEY")
		}
	}

	if apiKey == "" {
		return errors.New("missing required credentials")
	}
	return nil
}

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Missing required command. One of [approve-creation, approve-deletion]")
		os.Exit(1)
	}

	if os.Args[1] == "-v" || os.Args[1] == "-version" || os.Args[1] == "--version" || os.Args[1] == "version" {
		fmt.Println(Version)
		os.Exit(0)
	}
	
	setupGlobalFlags()

	if os.Args[1] == "approve-creation" {
		approveCreationCmd.Usage = func() {
			approveCreationCmd.PrintDefaults()
			os.Exit(0)
		}
		gatewayID := approveCreationCmd.String("gateway-id", "", "(Required) Direct Link Connect gateway identifier.")
		isGlobal := approveCreationCmd.Bool("global-routing", false, "(Optional) When true gateway can connect to networks outside of their associated region. Default is false.")
		isMetered := approveCreationCmd.Bool("metered", true, "(Optional) When true gateway usage is billed per gigabyte. When false there is no per gigabyte usage charge, instead a flat rate is charged for the gateway. Default is true.")
		connMode := approveCreationCmd.String("connection-mode", "direct", "(Optional) Connection mode. Mode transit indicates this gateway will be attached to Transit Gateway Service and direct means this gateway will be attached to vpc or classic connection. One of: direct, transit.") 
		resourceGroupID := approveCreationCmd.String("resource-group-id", "", "(Optional) If unspecified, the account's default resource group is used.") 
		//TODO AuthenticationKey (BGP MD5 AUTH KEY)

		err := approveCreationCmd.Parse(os.Args[2:])
		if err != nil {
			fmt.Println("Flags parsing error")
			panic(err)
		}
		
		errs := make([]error, 0)
		err = checkCredentials()
		if err != nil {
			errs = append(errs, err)
		}

		if *gatewayID == "" {
			fmt.Println("Missing required gatewayID flag\nCommand flags:")
			approveCreationCmd.PrintDefaults()
			os.Exit(1)
		}

		if len(errs) != 0 {
			err = ErrorSlice(errs)
			approveCreationCmd.PrintDefaults()
			panic(err)
		}

	    client, err := NewClientWithApiKey(apiKey)
		if err != nil {
			fmt.Print(err.Error())
			os.Exit(1)
		}

		_, err = CreateGatewayActionApprove(*client, *gatewayID, *isGlobal, *isMetered, *connMode, *resourceGroupID)
		if err != nil {
			panic(err)
		}
		err = retry(12, 10*time.Second, func() error {
			gw, sc, err := GetGateway(*client, *gatewayID)
			if err != nil {
				return errors.New("fail")
			}
			if gw == nil || sc == 404 {
				return stop{fmt.Errorf("Gateway %s not found", *gatewayID)}
			}
			if *gw.OperationalStatus == "provisioned" {
				fmt.Println("Gateway creation confirmed")
				return nil
			}
			if *gw.OperationalStatus == "delete_pending" || *gw.OperationalStatus == "create_rejected" {
				return stop{fmt.Errorf("unexpected Gateway status error: %s", *gw.OperationalStatus)}
			}

			return errors.New("gateway is still being configured")
		})

		if err != nil {
			panic(err)
		}

		os.Exit(0)
	}

	if os.Args[1] == "approve-deletion" {
		approveDeletionCmd.Usage = func() {
			approveDeletionCmd.PrintDefaults()
			os.Exit(0)
		}
		gatewayName := approveDeletionCmd.String("gateway-name", "", "(Optional) Direct Link Connect gateway name.")

		err := approveDeletionCmd.Parse(os.Args[2:])
		if err != nil {
			fmt.Println("Flags parsing error")
			panic(err)
		}
		
		errs := make([]error, 0)
		err = checkCredentials()
		if err != nil {
			errs = append(errs, err)
		}

		if *gatewayName == "" {
			fmt.Println("Missing required gatewayName flag\nCommand flags:")
			approveDeletionCmd.PrintDefaults()
			os.Exit(1)
		}

		if len(errs) != 0 {
			err = ErrorSlice(errs)
			approveDeletionCmd.PrintDefaults()
			panic(err)
		}

	    client, err := NewClientWithApiKey(apiKey)
		if err != nil {
			fmt.Print(err.Error())
			os.Exit(1)
		}

		gws, err := ListGateways(*client)
		if err != nil {
			fmt.Print(err.Error())
			os.Exit(1)
		}

		var gatewayID *string
		for _, gw := range gws.Gateways {
			if *gw.Name == *gatewayName {
				gatewayID = gw.ID
				break
			}
		}

		err = DeleteGatewayActionApprove(*client, *gatewayID)
		if err != nil {
			panic(err)
		}

		retry(60, 10*time.Second, func() error {
			gw, sc, err := GetGateway(*client, *gatewayID)
			if err != nil {
				return stop{fmt.Errorf("unexpected error during Gateway deletion")}
			}
			
			if gw == nil || sc == 404 {
				fmt.Println("Gateway deletion confirmed")
				return nil
			}

			return errors.New("gateway is still being configured")
		})
		os.Exit(0)
	}

	fmt.Println("Unknown command")
	os.Exit(1)
}

func init() {
	rand.Seed(time.Now().UnixNano())
}

func retry(attempts int, sleep time.Duration, f func() error) error {
	if err := f(); err != nil {
		if s, ok := err.(stop); ok {
			return s.error
		}

		if attempts--; attempts > 0 {
			jitter := time.Duration(rand.Int63n(int64(sleep)))
			sleep = sleep + jitter/2

			time.Sleep(sleep)
			return retry(attempts, 2*sleep, f)
		}
		return err
	}

	return nil
}

type stop struct {
	error
}

