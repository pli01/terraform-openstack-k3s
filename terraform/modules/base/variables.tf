# defines variables in variables.tf
#### network
variable "external_network" {
  type    = string
  default = "external-network"
}

variable "dns_nameservers" {
  type    = list(string)
  default = ["8.8.8.8", "8.8.8.4"]
}

variable "network_worker" {
  type = map(string)
  default = {
    subnet_name = "subnet-worker"
    cidr        = "192.168.1.0/24"
  }
}

# security
variable "ssh_access_cidr" {
  type    = string
  default = "0.0.0.0/0"
}
variable "prefix_name" {
}

#### MAIN DISK SIZE FOR INSTANCE
variable "vol_size" {
  type    = number
  default = 10
}

variable "vol_type" {
  type    = string
  default = "default"
}

variable "image" {
  type    = string
  default = "debian-latest"
}
variable "most_recent_image" {
  default = "false"
}
