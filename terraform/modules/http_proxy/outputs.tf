### outputs
output "stack_output" {
  value = openstack_orchestration_stack_v1.http_proxy[*].outputs
  depends_on = [
    openstack_orchestration_stack_v1.http_proxy
  ]
}

output "id" {
  value = openstack_orchestration_stack_v1.http_proxy[*].outputs[0]["output_value"]
  depends_on = [
    openstack_orchestration_stack_v1.http_proxy
  ]
}

output "private_ip" {
  value = openstack_orchestration_stack_v1.http_proxy[*].outputs[1]["output_value"]
  depends_on = [
    openstack_orchestration_stack_v1.http_proxy
  ]
}


