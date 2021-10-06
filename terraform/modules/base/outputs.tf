output "network_id" {
  value = openstack_networking_network_v2.generic.id
}
output "subnet_id" {
  value = openstack_networking_subnet_v2.worker.id
}
output "root_volume_id" {
  value = openstack_blockstorage_volume_v2.root_volume.id
}
output "servergroup_id" {
  value = openstack_compute_servergroup_v2.sg.id
}

# bastion
output "bastion_id" {
  value = openstack_networking_floatingip_v2.bastion.id
}
output "bastion_address" {
  value = openstack_networking_floatingip_v2.bastion.address
}
output "bastion_secgroup_id" {
  value = openstack_networking_secgroup_v2.bastion_secgroup_1.id
}

# http_proxy
output "http_proxy_id" {
  value = openstack_networking_floatingip_v2.http_proxy.id
}
output "http_proxy_address" {
  value = openstack_networking_floatingip_v2.http_proxy.address
}
output "http_proxy_secgroup_id" {
  value = openstack_networking_secgroup_v2.http_proxy_secgroup_1.id
}


