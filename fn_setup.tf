
resource "null_resource" "FoggyKitchenLogin2OCIR" {
  depends_on = [local_file.FoggyKitchen_ATP_database_wallet_file, 
                oci_functions_application.FoggyKitchenStream2ATPFnApp, 
                oci_database_autonomous_database.FoggyKitchenATPdatabase,
                oci_identity_policy.FoggyKitchenFunctionsServiceReposAccessPolicy,
                oci_identity_policy.FoggyKitchenFunctionsServiceNetworkAccessPolicy,
                oci_identity_dynamic_group.FoggyKitchenFunctionsServiceDynamicGroup,
                oci_identity_policy.FoggyKitchenFunctionsServiceDynamicGroupPolicy,
                oci_identity_policy.FoggyKitchenManageAPIGWFamilyPolicy,
                oci_identity_policy.FoggyKitchenManageVCNFamilyPolicy,
                oci_identity_policy.FoggyKitchenUseFnFamilyPolicy,
                oci_identity_policy.FoggyKitchenAnyUserUseFnPolicy]

  provisioner "local-exec" {
    command = "echo '${var.ocir_user_password}' |  docker login ${var.ocir_docker_repository} --username ${var.ocir_namespace}/${var.ocir_user_name} --password-stdin"
  }
}

resource "null_resource" "FoggyKitchenSetupATPFnPush2OCIR" {
  depends_on = [null_resource.FoggyKitchenLogin2OCIR, local_file.FoggyKitchen_ATP_database_wallet_file, oci_functions_application.FoggyKitchenStream2ATPFnApp, oci_database_autonomous_database.FoggyKitchenATPdatabase]

  provisioner "local-exec" {
    command = "cp ${var.FoggyKitchen_ATP_tde_wallet_zip_file} functions/SetupATPFn/" 
  }

  provisioner "local-exec" {
    command = "image=$(docker images | grep setupatpfn | awk -F ' ' '{print $3}') ; docker rmi -f $image &> /dev/null ; echo $image"
    working_dir = "functions/SetupATPFn"
  }

  provisioner "local-exec" {
    command = "fn build --verbose --build-arg ARG_ADMIN_ATP_PASSWORD=${var.atp_admin_password} --build-arg ARG_ATP_USER=${var.atp_user} --build-arg ARG_ATP_PASSWORD=${var.atp_password} --build-arg ARG_ATP_ALIAS=${var.FoggyKitchen_ATP_database_db_name}_medium"
    working_dir = "functions/SetupATPFn"
  }

  provisioner "local-exec" {
    command = "image=$(docker images | grep setupatpfn | awk -F ' ' '{print $3}') ; docker tag $image ${var.ocir_docker_repository}/${var.ocir_namespace}/${var.ocir_repo_name}/setupatpfn:0.0.1"
    working_dir = "functions/SetupATPFn"
  }

  provisioner "local-exec" {
    command = "docker push ${var.ocir_docker_repository}/${var.ocir_namespace}/${var.ocir_repo_name}/setupatpfn:0.0.1"
    working_dir = "functions/SetupATPFn"
  }

}


resource "null_resource" "FoggyKitchenStream2ATPFnPush2OCIR" {
  depends_on = [null_resource.FoggyKitchenLogin2OCIR, local_file.FoggyKitchen_ATP_database_wallet_file, oci_streaming_stream.FoggyKitchenStream, oci_streaming_stream_pool.FoggyKitchenStreamPool, oci_functions_application.FoggyKitchenStream2ATPFnApp, oci_database_autonomous_database.FoggyKitchenATPdatabase, null_resource.FoggyKitchenSetupATPFnPush2OCIR]


  provisioner "local-exec" {
    command = "cp ${var.FoggyKitchen_ATP_tde_wallet_zip_file} functions/Stream2ATPFn/" 
  }

  provisioner "local-exec" {
    command = "image=$(docker images | grep stream2atpfn | awk -F ' ' '{print $3}') ; docker rmi -f $image &> /dev/null ; echo $image"
    working_dir = "functions/Stream2ATPFn"
  }
  
  provisioner "local-exec" {
    command = "fn build --verbose --build-arg ARG_ATP_USER=${var.atp_user} --build-arg ARG_ATP_PASSWORD=${var.atp_password} --build-arg ARG_ATP_ALIAS=${var.FoggyKitchen_ATP_database_db_name}_medium --build-arg ARG_STREAM_OCID=${oci_streaming_stream.FoggyKitchenStream.id} --build-arg ARG_STREAM_ENDPOINT=${data.oci_streaming_stream_pool.FoggyKitchenStreamPool.endpoint_fqdn}"
    working_dir = "functions/Stream2ATPFn"
  }

  provisioner "local-exec" {
    command = "image=$(docker images | grep stream2atpfn | awk -F ' ' '{print $3}') ; docker tag $image ${var.ocir_docker_repository}/${var.ocir_namespace}/${var.ocir_repo_name}/stream2atpfn:0.0.1"
    working_dir = "functions/Stream2ATPFn"
  }

  provisioner "local-exec" {
    command = "docker push ${var.ocir_docker_repository}/${var.ocir_namespace}/${var.ocir_repo_name}/stream2atpfn:0.0.1"
    working_dir = "functions/Stream2ATPFn"
  }

}


resource "null_resource" "FoggyKitchenUpload2StreamFnPush2OCIR" {
  depends_on = [null_resource.FoggyKitchenLogin2OCIR, oci_streaming_stream.FoggyKitchenStream, oci_streaming_stream_pool.FoggyKitchenStreamPool, oci_functions_application.FoggyKitchenUpload2StreamFnApp]

  provisioner "local-exec" {
    command = "image=$(docker images | grep upload2streamfn | awk -F ' ' '{print $3}') ; docker rmi -f $image &> /dev/null ; echo $image"
    working_dir = "functions/Upload2StreamFn"
  }
  
  provisioner "local-exec" {
    command = "echo 'ARG_STREAM_OCID=${oci_streaming_stream.FoggyKitchenStream.id}' "
    
  }

  provisioner "local-exec" {
    command = "echo 'ARG_STREAM_ENDPOINT=${data.oci_streaming_stream_pool.FoggyKitchenStreamPool.endpoint_fqdn}'"
    
  }

  provisioner "local-exec" {
    command = "fn build --verbose --build-arg ARG_STREAM_OCID='${oci_streaming_stream.FoggyKitchenStream.id}' --build-arg ARG_STREAM_ENDPOINT='${data.oci_streaming_stream_pool.FoggyKitchenStreamPool.endpoint_fqdn}'"
    working_dir = "functions/Upload2StreamFn"
  }

  provisioner "local-exec" {
    command = "image=$(docker images | grep upload2streamfn | awk -F ' ' '{print $3}') ; docker tag $image ${var.ocir_docker_repository}/${var.ocir_namespace}/${var.ocir_repo_name}/upload2streamfn:0.0.1"
    working_dir = "functions/Upload2StreamFn"
  }

  provisioner "local-exec" {
    command = "docker push ${var.ocir_docker_repository}/${var.ocir_namespace}/${var.ocir_repo_name}/upload2streamfn:0.0.1"
    working_dir = "functions/Upload2StreamFn"
  }

}