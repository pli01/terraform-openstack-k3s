variable "log_count" {
  type    = number
  default = 0
}

resource "openstack_networking_floatingip_v2" "log" {
  count = var.log_count
  pool  = var.external_network
}

# log
resource "openstack_networking_secgroup_v2" "log_secgroup_1" {
  name        = format("%s-%s", var.prefix_name, "log_secgroup_1")
  description = "log security group"
  #delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "ssh_worker_log_secgroup_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.network_worker["cidr"]
  security_group_id = openstack_networking_secgroup_v2.log_secgroup_1.id
}

# Add http to log
resource "openstack_networking_secgroup_rule_v2" "http_worker_log_secgroup_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.log_secgroup_1.id
}

# Add syslog to log
resource "openstack_networking_secgroup_rule_v2" "syslog_tcp_worker_log_secgroup_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 514
  port_range_max    = 514
  #remote_ip_prefix  = var.network_worker["cidr"]
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.log_secgroup_1.id
}

# Add syslog to log
resource "openstack_networking_secgroup_rule_v2" "syslog_udp_worker_log_secgroup_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 514
  port_range_max    = 514
  #remote_ip_prefix  = var.network_worker["cidr"]
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.log_secgroup_1.id
}


# log
output "log_id" {
  value = openstack_networking_floatingip_v2.log[*].id
}
output "log_address" {
  value = openstack_networking_floatingip_v2.log[*].address
}
output "log_secgroup_id" {
  value = openstack_networking_secgroup_v2.log_secgroup_1.id
}
