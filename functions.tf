resource "oci_functions_application" "FoggyKitchenStream2ATPFnApp" {
    compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
    display_name = "FoggyKitchenStream2ATPFnApp"
    subnet_ids = [oci_core_subnet.FoggyKitchenWebSubnet.id]
}

resource "oci_functions_function" "FoggyKitchenUpdateSetupATPFn" {
    depends_on = [null_resource.FoggyKitchenSetupATPFnPush2OCIR]
    application_id = oci_functions_application.FoggyKitchenStream2ATPFnApp.id
    display_name = "SetupATPFn"
    image = "${var.ocir_docker_repository}/${var.ocir_namespace}/${var.ocir_repo_name}/setupatpfn:0.0.1"
    memory_in_mbs = "256" 
}

resource "oci_functions_invoke_function" "FoggyKitchenUpdateSetupATPFnInvoke" {
    depends_on = [oci_database_autonomous_database.FoggyKitchenATPdatabase, oci_functions_function.FoggyKitchenUpdateSetupATPFn]
    function_id = oci_functions_function.FoggyKitchenUpdateSetupATPFn.id
}

resource "oci_functions_function" "FoggyKitchenStream2ATPFn" {
    depends_on = [null_resource.FoggyKitchenStream2ATPFnPush2OCIR, oci_functions_function.FoggyKitchenUpdateSetupATPFn]
    application_id = oci_functions_application.FoggyKitchenStream2ATPFnApp.id
    display_name = "Stream2ATPFn"
    image = "${var.ocir_docker_repository}/${var.ocir_namespace}/${var.ocir_repo_name}/stream2atpfn:0.0.1"
    memory_in_mbs = "256" 
}

resource "oci_functions_application" "FoggyKitchenUpload2StreamFnApp" {
    compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
    display_name = "FoggyKitchenUpload2StreamFnApp"
    subnet_ids = [oci_core_subnet.FoggyKitchenWebSubnet.id]
}

resource "oci_functions_function" "FoggyKitchenUpload2StreamFn" {
    depends_on = [null_resource.FoggyKitchenUpload2StreamFnPush2OCIR]
    application_id = oci_functions_application.FoggyKitchenUpload2StreamFnApp.id
    display_name = "Upload2StreamFn"
    image = "${var.ocir_docker_repository}/${var.ocir_namespace}/${var.ocir_repo_name}/upload2streamfn:0.0.1"
    memory_in_mbs = "256" 
}

