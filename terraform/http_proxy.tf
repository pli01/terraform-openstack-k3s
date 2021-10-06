module "http_proxy" {
  source                        = "./modules/http_proxy"
  maxcount                      = var.http_proxy_count
  prefix_name                   = var.prefix_name
  heat_wait_condition_timeout =  var.heat_wait_condition_timeout
  fip                           = module.base.http_proxy_id
  network                       = module.base.network_id
  subnet                        = module.base.subnet_id
  source_volid                  = module.base.root_volume_id
  security_group                = module.base.http_proxy_secgroup_id
  vol_type                      = var.vol_type
  flavor                        = var.http_proxy_flavor
  image                         = var.image
  key_name                      = var.key_name
  no_proxy                      = var.no_proxy
  ssh_authorized_keys           = var.ssh_authorized_keys
  syslog_relay             = join("",local.log_public_ip)
  tinyproxy_upstream            = var.tinyproxy_upstream
  tinyproxy_proxy_authorization = var.tinyproxy_proxy_authorization
  depends_on = [
    module.base,
    module.bastion
  ]
}
