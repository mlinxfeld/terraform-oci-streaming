resource "null_resource" "FoggyKitchenWebserver1_ConfigMgmt" {
  depends_on = [oci_core_instance.FoggyKitchenWebserver1, oci_database_autonomous_database.FoggyKitchenATPdatabase, local_file.FoggyKitchen_ATP_database_wallet_file]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.FoggyKitchenWebserver1_VNIC1.public_ip_address
      private_key = file(var.private_key_oci)
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    inline = ["echo '== 1. Install Oracle instant client'",
      "sudo -u root yum -y install oracle-release-el7",
      "sudo -u root yum-config-manager --enable ol7_oracle_instantclient",
      "sudo -u root yum -y install oracle-instantclient18.3-basic",

      "echo '== 2. Install Python3, and then with pip3 cx_Oracle and flask'",
      "sudo -u root yum install -y python36",
      "sudo -u root pip3 install cx_Oracle",
      "sudo -u root pip3 install flask",
      "sudo -u root /tmp/templates",

      "echo '== 3. Disabling firewall and starting HTTPD service'",
    "sudo -u root service firewalld stop"]
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.FoggyKitchenWebserver1_VNIC1.public_ip_address
      private_key = file(var.private_key_oci)
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    source      = "sqlnet.ora"
    destination = "/tmp/sqlnet.ora"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.FoggyKitchenWebserver1_VNIC1.public_ip_address
      private_key = file(var.private_key_oci)
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    source      = var.FoggyKitchen_ATP_tde_wallet_zip_file
    destination = "/tmp/${var.FoggyKitchen_ATP_tde_wallet_zip_file}"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.FoggyKitchenWebserver1_VNIC1.public_ip_address
      private_key = file(var.private_key_oci)
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    source      = "flask_atp.py"
    destination = "/tmp/flask_atp.py"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.FoggyKitchenWebserver1_VNIC1.public_ip_address
      private_key = file(var.private_key_oci)
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    source      = "index.html"
    destination = "/tmp/templates/index.html"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.FoggyKitchenWebserver1_VNIC1.public_ip_address
      private_key = file(var.private_key_oci)
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    source      = "flask_atp.sh"
    destination = "/tmp/flask_atp.sh"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.FoggyKitchenWebserver1_VNIC1.public_ip_address
      private_key = file(var.private_key_oci)
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    inline = ["echo '== 4. Unzip TDE wallet zip file'",
      "sudo -u root unzip -o /tmp/${var.FoggyKitchen_ATP_tde_wallet_zip_file} -d /usr/lib/oracle/18.3/client64/lib/network/admin/",

      "echo '== 5. Move sqlnet.ora to /usr/lib/oracle/18.3/client64/lib/network/admin/'",
    "sudo -u root cp /tmp/sqlnet.ora /usr/lib/oracle/18.3/client64/lib/network/admin/"]
  }

}

resource "null_resource" "FoggyKitchenWebserver1_Flask_WebServer_and_access_ATP" {
  depends_on = [null_resource.FoggyKitchenWebserver1_ConfigMgmt]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.FoggyKitchenWebserver1_VNIC1.public_ip_address
      private_key = file(var.private_key_oci)
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    inline = ["echo '== 6. Run Flask with ATP access'",
      "sudo -u root python3 --version",
      "sudo -u root chmod +x /tmp/flask_atp.sh",
      "sudo -u root sed -i 's/atp_password/${var.atp_password}/g' /tmp/flask_atp.py",
      "sudo -u root nohup /tmp/flask_atp.sh > /tmp/flask_atp.log &",
      "sleep 5",
    "sudo -u root ps -ef | grep flask"]
  }

}
