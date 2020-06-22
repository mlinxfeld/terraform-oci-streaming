resource "oci_apigateway_gateway" "FoggyKitchenAPIGateway" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  endpoint_type  = "PUBLIC"
  subnet_id      = oci_core_subnet.FoggyKitchenWebSubnet.id
  display_name   = "FoggyKitchenAPIGateway"
}


resource "oci_apigateway_deployment" "FoggyKitchenAPIGatewayDeployment" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  gateway_id     = oci_apigateway_gateway.FoggyKitchenAPIGateway.id
  path_prefix    = "/v1"
  display_name   = "FoggyKitchenAPIGatewayDeployment"

  specification {
    routes {
      backend {
          type        = "ORACLE_FUNCTIONS_BACKEND"
          function_id = oci_functions_function.FoggyKitchenUpdateFrontendFn.id
      }
      methods = ["POST"]
      path    = "/frontend"
    }
  }
}

data "oci_apigateway_deployment" "FoggyKitchenAPIGatewayDeployment" {
    deployment_id = oci_apigateway_deployment.FoggyKitchenAPIGatewayDeployment.id
}

output "FoggyKitchenAPIGatewayDeployment_EndPoint" {
  value = [data.oci_apigateway_deployment.FoggyKitchenAPIGatewayDeployment.endpoint]
}