resource "null_resource" "install_logging_agent_linux" {

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
      content = templatefile("${path.module}/scripts/deploy-linux.tpl", {
        REGION= var.region
        LOGDNA_KEY = var.logging_key
        DIRS = var.logging_dirs
        TAGS = var.logging_tags
      })
      destination = "/root/logging.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 755 /root/logging.sh",
      "/root/logging.sh"
    ]
  }

}
