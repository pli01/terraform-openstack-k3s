variable "traefik_user_hostname" {
  type = list(string)
  default = []
}


# store lb config
module "lb-conf" {
  source                        = "./modules/lb-conf"
  traefik_rule_host             = concat(local.lb_public_ip,var.traefik_user_hostname)
  traefik_loadbalancers_servers = local.k3s_master_private_ip
  lb_variables                  = var.lb_variables
}
