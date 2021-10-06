# store lb config
# TODO: module
resource "openstack_objectstorage_container_v1" "container_1" {
  region = "region1"
  name   = "lb-conf"
  container_read = ".r:*,.rlistings"

  content_type = "application/json"
}

resource "openstack_objectstorage_object_v1" "dynamic_conf" {
  region         = "region1"
  container_name = openstack_objectstorage_container_v1.container_1.name
  name           = "dynamic_conf.json"

  content_type = "application/json"
  content = templatefile("${path.module}/dynamic_conf.json.tpl", {
      traefik_rule_host = var.traefik_rule_host
      traefik_loadbalancers_servers = var.traefik_loadbalancers_servers
     })
}
