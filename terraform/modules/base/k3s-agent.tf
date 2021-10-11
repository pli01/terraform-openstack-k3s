variable "k3s_agent_count" {
  type    = number
  default = 1
}

resource "openstack_networking_floatingip_v2" "k3s_agent" {
  count = var.k3s_agent_count
  pool  = var.external_network
}

# k3s_agent
resource "openstack_networking_secgroup_v2" "k3s_agent_secgroup_1" {
  name        = format("%s-%s", var.prefix_name, "k3s_agent_secgroup_1")
  description = "k3s_agent security group"
  #delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "ssh_worker_k3s_agent_secgroup_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.network_worker["cidr"]
  security_group_id = openstack_networking_secgroup_v2.k3s_agent_secgroup_1.id
}


# Add 8472 to k3s_agent
resource "openstack_networking_secgroup_rule_v2" "k3s_vxlan_worker_k3s_agent_secgroup_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 8472
  port_range_max    = 8472
  remote_ip_prefix  = var.network_worker["cidr"]
  security_group_id = openstack_networking_secgroup_v2.k3s_agent_secgroup_1.id
}


# Add 10250 to k3s_agent
resource "openstack_networking_secgroup_rule_v2" "k3s_kubelet_worker_k3s_agent_secgroup_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 10250
  port_range_max    = 10250
  remote_ip_prefix  = var.network_worker["cidr"]
  security_group_id = openstack_networking_secgroup_v2.k3s_agent_secgroup_1.id
}

# k3s_agent
output "k3s_agent_id" {
  value = openstack_networking_floatingip_v2.k3s_agent[*].id
}
output "k3s_agent_address" {
  value = openstack_networking_floatingip_v2.k3s_agent[*].address
}
output "k3s_agent_secgroup_id" {
  value = openstack_networking_secgroup_v2.k3s_agent_secgroup_1.id
}

