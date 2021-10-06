### outputs
output "container_name" {
  value = openstack_objectstorage_object_v1.dynamic_conf.container_name
}

output "object_name" {
  value = openstack_objectstorage_object_v1.dynamic_conf.name
}


