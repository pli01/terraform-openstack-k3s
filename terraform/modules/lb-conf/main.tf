# store lb config
# TODO: module
resource "openstack_objectstorage_container_v1" "container_1" {
  region = "region1"
  name   = var.container_name
  container_read = ".r:*,.rlistings"

  content_type = "application/json"
}

resource "openstack_objectstorage_object_v1" "dynamic_conf" {
  region         = "region1"
  container_name = openstack_objectstorage_container_v1.container_1.name
  name           = var.object_name

  content_type = "application/json"
  content = templatefile("${path.module}/${var.template_name}", {
      traefik_rule_host = join(",",formatlist("`%s`",var.traefik_rule_host))
      traefik_loadbalancers_servers = var.traefik_loadbalancers_servers
     })
}
