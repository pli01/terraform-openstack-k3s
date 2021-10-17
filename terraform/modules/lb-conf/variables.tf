variable "container_name" {
 type = string
 default = "lb-conf"
}
variable "object_name" {
 type = string
 default = "dynamic_conf.json"
}
variable "template_name" {
 type = string
 default = "dynamic_conf.json.tpl"
}

variable "traefik_rule_host" {}
variable "traefik_loadbalancers_servers" {}
variable "lb_variables" {
    type = map
    default = {}
}
