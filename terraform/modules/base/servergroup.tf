resource "openstack_compute_servergroup_v2" "sg" {
  name     = format("%s-%s", var.prefix_name, "sg")
  policies = ["anti-affinity"]
}
