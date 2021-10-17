variable "traefik_user_hostname" {
  type = list(string)
  default = []
}
variable "traefik_admin_hostname" {
  type = list(string)
  default = []
}

# store lb config
module "lb-conf" {
  source                        = "./modules/lb-conf"
  traefik_rule_host             = concat(local.lb_public_ip,var.traefik_user_hostname)
  traefik_loadbalancers_servers = local.k3s_agent_private_ip
  lb_variables                  = var.lb_variables
}

# store lb-admin config
module "lb-admin-conf" {
  source                        = "./modules/lb-conf"
  container_name                = "lb-admin-conf"
  template_name                 = "admin_dynamic_conf.json.tpl"
  traefik_rule_host             = concat(local.lb_admin_public_ip,var.traefik_admin_hostname)
  traefik_loadbalancers_servers = local.k3s_master_private_ip
  lb_variables                  = var.lb_admin_variables
}
