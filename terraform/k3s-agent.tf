# application stack
variable "k3s_agent_count" {
  type    = number
  default = 1
}
variable "k3s_agent_flavor" {
  type    = string
  default = "t1.small"
}
variable "k3s_agent_data_enable" {
  type = bool
  default = false
}
variable "k3s_agent_data_size" {
  type = number
  default = 0
}

variable "k3s_agent_name" {
  default = "k3s-agent"
}


variable "k3s_agent_install_script" {
  default = "https://raw.githubusercontent.com/pli01/terraform-openstack-k3s/main/samples/app/whoami/whoami-docker-deploy.sh"
}
variable "k3s_agent_variables" {
    type = map
    default = {}
}
variable "k3s_agent_metric_variables" {
  type = map
  default = {}
}

resource "openstack_blockstorage_volume_v2" "k3s-agent-data_volume" {
  count = var.k3s_agent_data_enable ? var.k3s_agent_count : 0
  name        = format("%s-%s-%s-%s", var.prefix_name, var.k3s_agent_name, count.index + 1, "data-volume")
  size        = var.k3s_agent_data_size
  volume_type = var.vol_type
}

module "k3s-agent" {
  source                   = "./modules/app"
  maxcount                 = var.k3s_agent_count
  prefix_name              = var.prefix_name
  app_name                 = var.k3s_agent_name
  heat_wait_condition_timeout =  var.heat_wait_condition_timeout
  network                  = module.base.network_id
  subnet                   = module.base.subnet_id
  source_volid             = module.base.root_volume_id
  security_group           = module.base.k3s_agent_secgroup_id
  app_data_enable          = var.k3s_agent_data_enable
  worker_data_volume_id    = openstack_blockstorage_volume_v2.k3s-agent-data_volume[*].id
  vol_type                 = var.vol_type
  flavor                   = var.k3s_agent_flavor
  image                    = var.image
  key_name                 = var.key_name
  no_proxy                 = var.no_proxy
  ssh_authorized_keys      = var.ssh_authorized_keys
  internal_http_proxy      = join(" ", formatlist("%s%s:%s", "http://", flatten(module.http_proxy[*].private_ip), "8888"))
  dns_nameservers          = var.dns_nameservers
  dns_domainname           = var.dns_domainname
  syslog_relay             = join("",local.log_public_ip)
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
  metric_enable            = var.metric_enable
  metric_install_script    = var.metric_install_script
  metric_variables         = var.k3s_agent_metric_variables
  app_install_script       = var.k3s_agent_install_script
  app_variables            = merge({ K3S_URL = format("https://%s:6443",join("",local.k3s_master_private_ip))}, var.k3s_agent_variables)
  depends_on = [
    module.base,
    module.bastion,
    module.http_proxy
  ]
}

# output
locals {
  k3s_agent_private_ip        = flatten(module.k3s-agent[*].private_ip)
  k3s_agent_id                = flatten(module.k3s-agent[*].id)
}

output "k3s_agent_id" {
  value = local.k3s_agent_id
}
output "k3s_agent_private_ip" {
  value = local.k3s_agent_private_ip
}

