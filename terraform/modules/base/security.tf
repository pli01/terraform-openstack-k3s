# bastion
resource "openstack_networking_secgroup_v2" "bastion_secgroup_1" {
  name        = format("%s-%s", var.prefix_name, "bastion_secgroup_1")
  description = "Bastion security group"
  #delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "ssh_bastion_bastion_secgroup_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.ssh_access_cidr
  security_group_id = openstack_networking_secgroup_v2.bastion_secgroup_1.id
}

resource "openstack_networking_secgroup_rule_v2" "ssh_worker_bastion_secgroup_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.network_worker["cidr"]
  security_group_id = openstack_networking_secgroup_v2.bastion_secgroup_1.id
}

# http_proxy
resource "openstack_networking_secgroup_v2" "http_proxy_secgroup_1" {
  name        = format("%s-%s", var.prefix_name, "http_proxy_secgroup_1")
  description = "http_proxy security group"
  #delete_default_rules = true
}


resource "openstack_networking_secgroup_rule_v2" "ssh_worker_http_proxy_secgroup_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.network_worker["cidr"]
  security_group_id = openstack_networking_secgroup_v2.http_proxy_secgroup_1.id
}

resource "openstack_networking_secgroup_rule_v2" "proxy_worker_http_proxy_secgroup_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8888
  port_range_max    = 8888
  remote_ip_prefix  = var.network_worker["cidr"]
  security_group_id = openstack_networking_secgroup_v2.http_proxy_secgroup_1.id
}


