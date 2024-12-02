locals {
  proxmox_node_name = "proxmox"
}

resource "proxmox_virtual_environment_file" "release_20230531_debian_12_bookworm_qcow2_img" {
  content_type       = "iso"
  datastore_id       = "local"
  node_name          = local.proxmox_node_name
	source_file {
		path = "isos/debian-12-genericcloud-amd64-20230531-1397.img"
	}
}
