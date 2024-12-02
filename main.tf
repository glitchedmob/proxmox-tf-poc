locals {
  proxmox_node_name = "proxmox"
}

resource "proxmox_virtual_environment_download_file" "release_20230531_debian_12_bookworm_qcow2_img" {
  content_type       = "iso"
  datastore_id       = "local"
  node_name          = local.proxmox_node_name
  file_name          = "debian-12-generic-amd64-20230531-1397.img"
  url                = "http://cloud.debian.org/images/cloud/bookworm/20230531-1397/debian-12-generic-amd64-20230531-1397.qcow2"
  checksum           = "84123ea7225934fe157535d7587498fdd2838299d3b57c76d8eac4e59faafb028b9b68ceadeddcccdc8c1586bf978a7d93e5c65142fb9de67d375b37945657d0"
  checksum_algorithm = "sha512"
}

resource "proxmox_virtual_environment_network_linux_bridge" "internal_bridge" {
  name       = "vmbr1"
  node_name  = local.proxmox_node_name
  address    = "10.0.0.0/16"
  comment    = "Bridge for private network"
  vlan_aware = false
}

resource "proxmox_virtual_environment_network_linux_bridge" "external_bridge" {
  name       = "vmbr0"
  node_name  = local.proxmox_node_name
  vlan_aware = false
  address    = "172.30.65.21/20"
  gateway    = "172.30.64.1"
  ports      = ["eth0"]
}

resource "proxmox_virtual_environment_vm" "debian_vm" {
  node_name = local.proxmox_node_name
  vm_id     = 101
  cpu {
    cores = 2
    type  = "x86-64-v2-AES"
  }
  memory {
    dedicated = 4096
  }
  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 32
    file_id      = proxmox_virtual_environment_download_file.release_20230531_debian_12_bookworm_qcow2_img.id
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
      keys     = [trimspace(tls_private_key.debian_vm_key.public_key_openssh)]
      password = random_password.debian_vm_password.result
      username = "debian"
    }
  }
  network_device {
    bridge = proxmox_virtual_environment_network_linux_bridge.external_bridge.name
  }
}

resource "random_password" "debian_vm_password" {
  length           = 8
  override_special = "_%@"
  special          = true
}

resource "tls_private_key" "debian_vm_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
