output "bastion_id" {
  value = module.k3s-cluster.bastion_id
}
output "bastion_private_ip" {
  value = module.k3s-cluster.bastion_private_ip
}
output "bastion_public_ip" {
  value = module.k3s-cluster.bastion_public_ip
}

output "http_proxy_id" {
  value = module.k3s-cluster.http_proxy_id
}
output "http_proxy_private_ip" {
  value = module.k3s-cluster.http_proxy_private_ip
}
output "http_proxy_public_ip" {
  value = module.k3s-cluster.http_proxy_public_ip
}

output "k3s_master_id" {
  value = module.k3s-cluster.k3s_master_id
}
output "k3s_master_private_ip" {
  value = module.k3s-cluster.k3s_master_private_ip
}

output "k3s_server_id" {
  value = module.k3s-cluster.k3s_server_id
}
output "k3s_server_private_ip" {
  value = module.k3s-cluster.k3s_server_private_ip
}


output "k3s_agent_id" {
  value = module.k3s-cluster.k3s_agent_id
}
output "k3s_agent_private_ip" {
  value = module.k3s-cluster.k3s_agent_private_ip
}

output "log_id" {
  value = module.k3s-cluster.log_id
}
output "log_private_ip" {
  value = module.k3s-cluster.log_private_ip
}
output "log_public_ip" {
  value = module.k3s-cluster.log_public_ip
}
output "lb_id" {
  value = module.k3s-cluster.lb_id
}
output "lb_private_ip" {
  value = module.k3s-cluster.lb_private_ip
}
output "lb_public_ip" {
  value = module.k3s-cluster.lb_public_ip
}

output "lb_admin_id" {
  value = module.k3s-cluster.lb_admin_id
}
output "lb_admin_private_ip" {
  value = module.k3s-cluster.lb_admin_private_ip
}
output "lb_admin_public_ip" {
  value = module.k3s-cluster.lb_admin_public_ip
}
