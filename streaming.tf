resource "oci_streaming_stream_pool" "FoggyKitchenStreamPool" {
    compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
    name = "FoggyKitchenStreamPool"
}

resource "oci_streaming_stream" "FoggyKitchenStream" {
    name = "FoggyKitchenStream"
    partitions = 1
    stream_pool_id = oci_streaming_stream_pool.FoggyKitchenStreamPool.id
}

data "oci_streaming_stream_pool" "FoggyKitchenStreamPool" {
    stream_pool_id = "${oci_streaming_stream_pool.FoggyKitchenStreamPool.id}"
}

