variable "traefik_rule_host" {}
variable "traefik_loadbalancers_servers" {}
variable "lb_variables" {
    type = map
    default = {}
}
