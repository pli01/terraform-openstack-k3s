#### NETWORK CONFIGURATION ####

data "openstack_networking_network_v2" "network" {
  name = var.external_network
}
# Router creation
resource "openstack_networking_router_v2" "generic" {
  name                = format("%s-%s", var.prefix_name, "router")
  external_network_id = data.openstack_networking_network_v2.network.id
}

# Network creation
resource "openstack_networking_network_v2" "generic" {
  name = format("%s-%s", var.prefix_name, "network")
}

#### WORKER SUBNET ####

# Subnet worker configuration
resource "openstack_networking_subnet_v2" "worker" {
  name            = format("%s-%s", var.prefix_name, var.network_worker["subnet_name"])
  network_id      = openstack_networking_network_v2.generic.id
  cidr            = var.network_worker["cidr"]
  ip_version      = 4
  dns_nameservers = var.dns_nameservers
}

# Router interface configuration
resource "openstack_networking_router_interface_v2" "worker" {
  router_id = openstack_networking_router_v2.generic.id
  subnet_id = openstack_networking_subnet_v2.worker.id
}

