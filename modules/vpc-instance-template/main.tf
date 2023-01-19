
##############################################################################
# Read/validate vsi profile
##############################################################################

data "ibm_is_instance_profile" "instance_profile" {
  name = var.profile
}

##############################################################################
# Calculate the most recently available OS Image Name for the 
# OS Provided
##############################################################################

data "ibm_is_images"  "os_images" {
    visibility = "public"
}

locals {
    os_images_filtered = [
        for image in data.ibm_is_images.os_images.images:
            image if ((image.architecture == var.image_architecture) && (image.os == var.image_os) && (image.status == "available"))
    ]
}

data "ibm_is_image" "image" {
  name = local.os_images_filtered[0].name
}


##############################################################################
# Create Instance Template
##############################################################################

resource "ibm_is_instance_template" "instance_template" {
  name           = var.name
  vpc            = var.vpc_id
  zone           = var.location
  image          = data.ibm_is_image.image.id
  profile        = var.profile
  keys           = var.ssh_keys
  resource_group = var.resource_group_id

  dynamic primary_network_interface {
    for_each = var.primary_network_interface
    content {
      subnet               = primary_network_interface.value.subnet
      name                 = (primary_network_interface.value.interface_name != "" ? primary_network_interface.value.interface_name : null)
      security_groups      = (primary_network_interface.value.security_groups != null ? primary_network_interface.value.security_groups : [])
      primary_ipv4_address = (primary_network_interface.value.primary_ipv4_address != "" ? primary_network_interface.value.primary_ipv4_address : null)
    }
  }

  user_data = (var.user_data != null ? var.user_data : null)

  dynamic network_interfaces {
    for_each = (var.network_interfaces != null ? var.network_interfaces : [])
    content {
      subnet               = network_interfaces.value.subnet
      name                 = (network_interfaces.value.interface_name != "" ? network_interfaces.value.interface_name : null)
      security_groups      = (network_interfaces.value.security_groups != null ? network_interfaces.value.security_groups : [])
      primary_ipv4_address = (network_interfaces.value.primary_ipv4_address != "" ? network_interfaces.value.primary_ipv4_address : null)
    }
  }
  dynamic boot_volume {
    for_each = (var.boot_volume != null ? var.boot_volume : [])
    content {
      name       = (boot_volume.value.name != "" ? boot_volume.value.name : null)
      encryption = (boot_volume.value.encryption != "" ? boot_volume.value.encryption : null)
    }
  }
}
