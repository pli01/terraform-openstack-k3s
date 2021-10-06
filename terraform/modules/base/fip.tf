# Create floating ip
resource "openstack_networking_floatingip_v2" "bastion" {
  pool = var.external_network
}
resource "openstack_networking_floatingip_v2" "http_proxy" {
  pool = var.external_network
}

