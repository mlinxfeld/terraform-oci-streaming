resource "null_resource" "FoggyKitchenSetupATPFnPush2OCIR" {
  depends_on = [oci_functions_application.FoggyKitchenBackendFnApp, oci_database_autonomous_database.FoggyKitchenATPdatabase]

  provisioner "local-exec" {
    command = "echo '${var.ocir_user_password}' |  docker login ${var.ocir_docker_repository} --username ${var.ocir_namespace}/${var.ocir_user_name} --password-stdin"
  }

  provisioner "local-exec" {
    command = "cp ${var.FoggyKitchen_ATP_tde_wallet_zip_file} functions/SetupATPFn/" 
  }

  #provisioner "local-exec" {
  #  command = "image=$(docker images | grep setupatpfn | awk -F ' ' '{print $3}') ; docker rmi -f $image &> /dev/null"
  #  working_dir = "functions/SetupATPFn"
  #}

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

resource "null_resource" "FoggyKitchenBackendFnPush2OCIR" {
  depends_on = [oci_streaming_stream.FoggyKitchenStream, oci_streaming_stream_pool.FoggyKitchenStreamPool, oci_functions_application.FoggyKitchenBackendFnApp, oci_database_autonomous_database.FoggyKitchenATPdatabase, null_resource.FoggyKitchenSetupATPFnPush2OCIR]

  provisioner "local-exec" {
    command = "echo '${var.ocir_user_password}' |  docker login ${var.ocir_docker_repository} --username ${var.ocir_namespace}/${var.ocir_user_name} --password-stdin"
  }

  provisioner "local-exec" {
    command = "cp ${var.FoggyKitchen_ATP_tde_wallet_zip_file} functions/BackendFn/" 
  }

  #provisioner "local-exec" {
  #  command = "image=$(docker images | grep backendfn | awk -F ' ' '{print $3}') ; docker rmi -f $image &> /dev/null"
  #  working_dir = "functions/BackendFn"
  #}
  
  provisioner "local-exec" {
    command = "fn build --verbose --build-arg ARG_ATP_USER=${var.atp_user} --build-arg ARG_ATP_PASSWORD=${var.atp_password} --build-arg ARG_ATP_ALIAS=${var.FoggyKitchen_ATP_database_db_name}_medium --build-arg ARG_stream_ocid=${oci_streaming_stream.FoggyKitchenStream.id} --build-arg ARG_stream_endpoint=${data.oci_streaming_stream_pool.FoggyKitchenStreamPool.endpoint_fqdn}"
    working_dir = "functions/BackendFn"
  }

  provisioner "local-exec" {
    command = "image=$(docker images | grep backendfn | awk -F ' ' '{print $3}') ; docker tag $image ${var.ocir_docker_repository}/${var.ocir_namespace}/${var.ocir_repo_name}/backendfn:0.0.1"
    working_dir = "functions/BackendFn"
  }

  provisioner "local-exec" {
    command = "docker push ${var.ocir_docker_repository}/${var.ocir_namespace}/${var.ocir_repo_name}/backendfn:0.0.1"
    working_dir = "functions/BackendFn"
  }

}


resource "null_resource" "FoggyKitchenFrontendFnPush2OCIR" {
  depends_on = [oci_streaming_stream.FoggyKitchenStream, oci_streaming_stream_pool.FoggyKitchenStreamPool, oci_functions_application.FoggyKitchenFrontendFnApp]

  provisioner "local-exec" {
    command = "echo '${var.ocir_user_password}' |  docker login ${var.ocir_docker_repository} --username ${var.ocir_namespace}/${var.ocir_user_name} --password-stdin"
  }

  #provisioner "local-exec" {
  #  command = "image=$(docker images | grep backendfn | awk -F ' ' '{print $3}') ; docker rmi -f $image &> /dev/null"
  #  working_dir = "functions/BackendFn"
  #}
  
  provisioner "local-exec" {
    command = "fn build --verbose --build-arg ARG_stream_ocid=${oci_streaming_stream.FoggyKitchenStream.id} --build-arg ARG_stream_endpoint=${data.oci_streaming_stream_pool.FoggyKitchenStreamPool.endpoint_fqdn}"
    working_dir = "functions/FrontendFn"
  }

  provisioner "local-exec" {
    command = "image=$(docker images | grep backendfn | awk -F ' ' '{print $3}') ; docker tag $image ${var.ocir_docker_repository}/${var.ocir_namespace}/${var.ocir_repo_name}/frontendfn:0.0.1"
    working_dir = "functions/FrontendFn"
  }

  provisioner "local-exec" {
    command = "docker push ${var.ocir_docker_repository}/${var.ocir_namespace}/${var.ocir_repo_name}/frontendfn:0.0.1"
    working_dir = "functions/FrontendFn"
  }

}