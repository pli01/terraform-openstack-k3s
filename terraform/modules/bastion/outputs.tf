### outputs
output "stack_output" {
  value = openstack_orchestration_stack_v1.bastion[*].outputs
  depends_on = [
    openstack_orchestration_stack_v1.bastion
  ]
}

output "id" {
  value = openstack_orchestration_stack_v1.bastion[*].outputs[0]["output_value"]
  depends_on = [
    openstack_orchestration_stack_v1.bastion
  ]
}

output "private_ip" {
  value = openstack_orchestration_stack_v1.bastion[*].outputs[1]["output_value"]
  depends_on = [
    openstack_orchestration_stack_v1.bastion
  ]
}


