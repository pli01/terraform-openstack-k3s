variable "app_count" {
  type    = number
  default = 1
}

resource "openstack_networking_floatingip_v2" "app" {
  count = var.app_count
  pool  = var.external_network
}

# app
resource "openstack_networking_secgroup_v2" "app_secgroup_1" {
  name        = format("%s-%s", var.prefix_name, "app_secgroup_1")
  description = "app security group"
  #delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "ssh_worker_app_secgroup_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.network_worker["cidr"]
  security_group_id = openstack_networking_secgroup_v2.app_secgroup_1.id
}

# Add 6443 to app
resource "openstack_networking_secgroup_rule_v2" "k3s_worker_app_secgroup_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  remote_ip_prefix  = var.network_worker["cidr"]
  security_group_id = openstack_networking_secgroup_v2.app_secgroup_1.id
}

# Add 8472 to app
resource "openstack_networking_secgroup_rule_v2" "k3s_vxlan_worker_app_secgroup_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 8472
  port_range_max    = 8472
  remote_ip_prefix  = var.network_worker["cidr"]
  security_group_id = openstack_networking_secgroup_v2.app_secgroup_1.id
}


# Add 10250 to app
resource "openstack_networking_secgroup_rule_v2" "k3s_kubelet_worker_app_secgroup_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 10250
  port_range_max    = 10250
  remote_ip_prefix  = var.network_worker["cidr"]
  security_group_id = openstack_networking_secgroup_v2.app_secgroup_1.id
}


# Add http to app
resource "openstack_networking_secgroup_rule_v2" "http_worker_app_secgroup_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.app_secgroup_1.id
}

# Add https to app
resource "openstack_networking_secgroup_rule_v2" "https_worker_app_secgroup_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.app_secgroup_1.id
}


# app
output "app_id" {
  value = openstack_networking_floatingip_v2.app[*].id
}
output "app_address" {
  value = openstack_networking_floatingip_v2.app[*].address
}
output "app_secgroup_id" {
  value = openstack_networking_secgroup_v2.app_secgroup_1.id
}

