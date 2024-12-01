variable "proxmox_connection" {
  type = object({
    endpoint = string
    username = string
    password = string
  })
}
