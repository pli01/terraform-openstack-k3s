### outputs
output "stack_output" {
  value = openstack_orchestration_stack_v1.log[*].outputs
  depends_on = [
    openstack_orchestration_stack_v1.log
  ]
}

output "id" {
  value = openstack_orchestration_stack_v1.log[*].outputs[0]["output_value"]
  depends_on = [
    openstack_orchestration_stack_v1.log
  ]
}

output "private_ip" {
  value = openstack_orchestration_stack_v1.log[*].outputs[1]["output_value"]
  depends_on = [
    openstack_orchestration_stack_v1.log
  ]
}


