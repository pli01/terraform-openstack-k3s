# store lb config
module "lb-conf" {
  source                        = "./modules/lb-conf"
  traefik_rule_host             = join("",local.lb_public_ip)
  traefik_loadbalancers_servers = local.app_private_ip
  lb_variables                  = var.lb_variables
}
