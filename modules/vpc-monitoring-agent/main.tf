locals {
  monitoring_tags = join(",", var.monitoring_tags)
}

resource "null_resource" "install_monitoring_agent_linux" {

  count = var.os_family == "linux" ? 1 : 0

  connection {
    
    type = var.instance_connection.type
    user = var.instance_connection.user
    private_key = var.instance_connection.private_key
    bastion_host = var.instance_connection.bastion_host
    bastion_private_key = var.instance_connection.bastion_private_key
    host = var.instance_connection.host

  }

  provisioner "file" {
    content = file("${path.module}/scripts/deploy-linux.sh")
    destination = "/root/monitoring.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 755 /root/monitoring.sh",
      "/root/monitoring.sh -a ${var.monitoring_key} -c ingest.private.${var.region}.monitoring.cloud.ibm.com --secure true -ac \"sysdig_capture_enabled: false\" -t \"${local.monitoring_tags}\"",
    ]
  }

}