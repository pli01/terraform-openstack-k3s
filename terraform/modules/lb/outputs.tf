### outputs
output "stack_output" {
  value = openstack_orchestration_stack_v1.lb[*].outputs
  depends_on = [
    openstack_orchestration_stack_v1.lb
  ]
}

output "id" {
  value = openstack_orchestration_stack_v1.lb[*].outputs[0]["output_value"]
  depends_on = [
    openstack_orchestration_stack_v1.lb
  ]
}

output "private_ip" {
  value = openstack_orchestration_stack_v1.lb[*].outputs[1]["output_value"]
  depends_on = [
    openstack_orchestration_stack_v1.lb
  ]
}


