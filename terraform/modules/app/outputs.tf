### outputs
output "stack_output" {
  value = openstack_orchestration_stack_v1.app[*].outputs
  depends_on = [
    openstack_orchestration_stack_v1.app
  ]
}

output "id" {
  value = openstack_orchestration_stack_v1.app[*].outputs[0]["output_value"]
  depends_on = [
    openstack_orchestration_stack_v1.app
  ]
}

output "private_ip" {
  value = openstack_orchestration_stack_v1.app[*].outputs[1]["output_value"]
  depends_on = [
    openstack_orchestration_stack_v1.app
  ]
}


