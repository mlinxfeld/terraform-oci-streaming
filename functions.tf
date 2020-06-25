resource "oci_functions_application" "FoggyKitchenBackendFnApp" {
    compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
    display_name = "FoggyKitchenBackendFnApp"
    subnet_ids = [oci_core_subnet.FoggyKitchenATPEndpointSubnet.id]
}

resource "oci_functions_function" "FoggyKitchenUpdateSetupATPFn" {
    depends_on = [null_resource.FoggyKitchenSetupATPFnPush2OCIR]
    application_id = oci_functions_application.FoggyKitchenBackendFnApp.id
    display_name = "SetupATPFn"
    image = "${var.ocir_docker_repository}/${var.ocir_namespace}/${var.ocir_repo_name}/setupatpfn:0.0.1"
    memory_in_mbs = "256" 
}

resource "oci_functions_invoke_function" "FoggyKitchenUpdateSetupATPFnInvoke" {
    depends_on = [oci_database_autonomous_database.FoggyKitchenATPdatabase, oci_functions_function.FoggyKitchenUpdateSetupATPFn]
    function_id = oci_functions_function.FoggyKitchenUpdateSetupATPFn.id
}

resource "oci_functions_function" "FoggyKitchenBackendFn" {
    depends_on = [null_resource.FoggyKitchenBackendFnPush2OCIR, oci_functions_function.FoggyKitchenUpdateSetupATPFn]
    application_id = oci_functions_application.FoggyKitchenBackendFnApp.id
    display_name = "BackendFn"
    image = "${var.ocir_docker_repository}/${var.ocir_namespace}/${var.ocir_repo_name}/backendfn:0.0.1"
    memory_in_mbs = "256" 
}


resource "oci_functions_application" "FoggyKitchenFrontendFnApp" {
    compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
    display_name = "FoggyKitchenFrontendFnApp"
    subnet_ids = [oci_core_subnet.FoggyKitchenWebSubnet.id]
}

resource "oci_functions_function" "FoggyKitchenFrontendFn" {
    depends_on = [null_resource.FoggyKitchenFrontendFnPush2OCIR]
    application_id = oci_functions_application.FoggyKitchenFrontendFnApp.id
    display_name = "FrontendFn"
    image = "${var.ocir_docker_repository}/${var.ocir_namespace}/${var.ocir_repo_name}/frontendfn:0.0.1"
    memory_in_mbs = "256" 
}

