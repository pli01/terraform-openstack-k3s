# output
locals {
  bastion_private_ip    = flatten(module.bastion[*].private_ip)
  bastion_id            = flatten(module.bastion[*].id)
  http_proxy_private_ip = flatten(module.http_proxy[*].private_ip)
  http_proxy_id         = flatten(module.http_proxy[*].id)
}

output "bastion_id" {
  value = local.bastion_id
}
output "bastion_private_ip" {
  value = local.bastion_private_ip
}
output "bastion_public_ip" {
  value = module.base.bastion_address
}

output "http_proxy_id" {
  value = local.http_proxy_id
}
output "http_proxy_private_ip" {
  value = local.http_proxy_private_ip
}
output "http_proxy_public_ip" {
  value = module.base.http_proxy_address
}


