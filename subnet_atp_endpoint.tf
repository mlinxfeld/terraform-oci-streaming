resource "oci_core_subnet" "FoggyKitchenATPEndpointSubnet" {
  cidr_block = "10.0.2.0/24"
  display_name = "FoggyKitchenATPEndpointSubnet"
  dns_label = "fkN2"
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id = oci_core_virtual_network.FoggyKitchenVCN.id
  route_table_id = oci_core_route_table.FoggyKitchenRouteTableViaNAT.id
  dhcp_options_id = oci_core_dhcp_options.FoggyKitchenDhcpOptions1.id
  prohibit_public_ip_on_vnic = true
}


