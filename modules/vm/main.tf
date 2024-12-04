resource "proxmox_virtual_environment_vm" "vm" {
  node_name = var.node_name
  vm_id     = var.vm_id
  cpu {
    cores = var.cpu_cores
    type  = "x86-64-v2-AES"
  }
  memory {
    dedicated = var.memory
  }
  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = var.storage_size_gb
    file_id      = var.os_image_id
  }
  operating_system {
    type = "l26"
  }
  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys     = [trimspace(tls_private_key.vm_key.public_key_openssh)]
      password = random_password.vm_password.result
      username = var.vm_default_username
    }
  }
  network_device {
    bridge = var.network_bridge
  }
}

resource "random_password" "vm_password" {
  length           = 8
  override_special = "_%@"
  special          = true
}

resource "tls_private_key" "vm_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
