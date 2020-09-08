output "FoggyKitchen_Upload2StreamFn_POST_EndPoint_URL" {
  value = [join("", [data.oci_apigateway_deployment.FoggyKitchenAPIGatewayDeployment.endpoint, "/upload2stream"])]
}

output "FoggyKitchen_Flask_Webserver1_URL" {
  value = [join("", ["http://", data.oci_core_vnic.FoggyKitchenWebserver1_VNIC1.public_ip_address, "/"])]
}

