variable "lb_metric_variables" {
  type = map
  default = {}
}


# load balancer
variable "lb_count" {
  type    = number
  default = 0
}
variable "lb_flavor" {
  type    = string
  default = "t1.small"
}
variable "lb_install_script" {
  default = "https://raw.githubusercontent.com/pli01/simple-traefik-http-provider/main/ci/docker-deploy.sh"
}
variable "lb_variables" {
  type = map
  default = {}
}


module "lb" {
  source                   = "./modules/lb"
  maxcount                 = var.lb_count
  prefix_name              = var.prefix_name
  heat_wait_condition_timeout =  var.heat_wait_condition_timeout
  fip                      = module.base.lb_id
  network                  = module.base.network_id
  subnet                   = module.base.subnet_id
  source_volid             = module.base.root_volume_id
  security_group           = module.base.lb_secgroup_id
  vol_type                 = var.vol_type
  flavor                   = var.lb_flavor
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
  metric_variables         = var.lb_metric_variables
  lb_install_script        = var.lb_install_script
  lb_variables             = var.lb_variables
  depends_on = [
    module.base,
    module.bastion,
    module.http_proxy
  ]
}

# output
locals {
  lb_private_ip        = flatten(module.lb[*].private_ip)
  lb_id                = flatten(module.lb[*].id)
  lb_public_ip         = flatten(module.base[*].lb_address)
}

output "lb_id" {
  value = local.lb_id
}
output "lb_private_ip" {
  value = local.lb_private_ip
}
output "lb_public_ip" {
  value = local.lb_public_ip
}
