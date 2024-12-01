terraform {
  required_version = ">= 1.8.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.68.0"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_connection.endpoint
  username = var.proxmox_connection.username
  password = var.proxmox_connection.password
  insecure = true

  ssh {
    agent = true
  }
}
