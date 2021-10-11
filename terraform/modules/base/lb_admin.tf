variable "lb_admin_count" {
  type    = number
  default = 0
}

resource "openstack_networking_floatingip_v2" "lb_admin" {
  count = var.lb_admin_count
  pool  = var.external_network
}

# lb
resource "openstack_networking_secgroup_v2" "lb_admin_secgroup_1" {
  name        = format("%s-%s", var.prefix_name, "lb_admin_secgroup_1")
  description = "lb security group"
  #delete_default_rules = true
}

# add ssh to lb
resource "openstack_networking_secgroup_rule_v2" "ssh_worker_lb_admin_secgroup_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.network_worker["cidr"]
  security_group_id = openstack_networking_secgroup_v2.lb_admin_secgroup_1.id
}

# Add http to lb
resource "openstack_networking_secgroup_rule_v2" "http_worker_lb_admin_secgroup_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.lb_admin_secgroup_1.id
}


# Add https to lb
resource "openstack_networking_secgroup_rule_v2" "https_worker_lb_admin_secgroup_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.lb_admin_secgroup_1.id
}


# lb
output "lb_admin_id" {
  value = openstack_networking_floatingip_v2.lb_admin[*].id
}
output "lb_admin_address" {
  value = openstack_networking_floatingip_v2.lb_admin[*].address
}
output "lb_admin_secgroup_id" {
  value = openstack_networking_secgroup_v2.lb_admin_secgroup_1.id
}
