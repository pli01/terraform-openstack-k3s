# log
variable "log_count" {
  type    = number
  default = 0
}
variable "log_flavor" {
  type    = string
  default = "t1.small"
}
variable "log_data_enable" {
  type = bool
  default = false
}
variable "log_data_size" {
  type = number
  default = 0
}

variable "log_install_script" {
  default = "https://raw.githubusercontent.com/pli01/log-stack/master/ci/docker-deploy.sh"
}
variable "log_variables" {
  type = map
  default = {}
}

resource "openstack_blockstorage_volume_v2" "log-data_volume" {
  count = var.log_data_enable ? var.log_count : 0
  name        = format("%s-%s-%s-%s", var.prefix_name, "log", count.index + 1, "data-volume")
  size        = var.log_data_size
  volume_type = var.vol_type
}

module "log" {
  source                   = "./modules/log"
  maxcount                 = var.log_count
  prefix_name              = var.prefix_name
  heat_wait_condition_timeout =  var.heat_wait_condition_timeout
  fip                      = module.base.log_id
  network                  = module.base.network_id
  subnet                   = module.base.subnet_id
  source_volid             = module.base.root_volume_id
  security_group           = module.base.log_secgroup_id
  log_data_enable          = var.log_data_enable
  worker_data_volume_id    = openstack_blockstorage_volume_v2.log-data_volume[*].id
  vol_type                 = var.vol_type
  flavor                   = var.log_flavor
  image                    = var.image
  key_name                 = var.key_name
  no_proxy                 = var.no_proxy
  ssh_authorized_keys      = var.ssh_authorized_keys
  internal_http_proxy      = join(" ", formatlist("%s%s:%s", "http://", flatten(module.http_proxy[*].private_ip), "8888"))
  dns_nameservers          = var.dns_nameservers
  dns_domainname           = var.dns_domainname
  syslog_relay             = var.syslog_relay
  nexus_server             = var.nexus_server
  mirror_docker            = var.mirror_docker
  mirror_docker_key        = var.mirror_docker_key
  docker_version           = var.docker_version
  docker_compose_version   = var.docker_compose_version
  dockerhub_login          = var.dockerhub_login
  dockerhub_token          = var.dockerhub_token
  github_token             = var.github_token
  docker_registry_username = var.docker_registry_username
  docker_registry_token    = var.docker_registry_token
  log_install_script       = var.log_install_script
  log_variables            = var.log_variables
  depends_on = [
    module.base,
    module.bastion,
    module.http_proxy
  ]
}

# output
locals {
  log_private_ip        = flatten(module.log[*].private_ip)
  log_id                = flatten(module.log[*].id)
  log_public_ip         = flatten(module.base[*].log_address)
}

output "log_id" {
  value = local.log_id
}
output "log_private_ip" {
  value = local.log_private_ip
}
output "log_public_ip" {
  value = local.log_public_ip
}


