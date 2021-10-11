### outputs
output "stack_output" {
  value = openstack_orchestration_stack_v1.lb_admin[*].outputs
  depends_on = [
    openstack_orchestration_stack_v1.lb_admin
  ]
}

output "id" {
  value = openstack_orchestration_stack_v1.lb_admin[*].outputs[0]["output_value"]
  depends_on = [
    openstack_orchestration_stack_v1.lb_admin
  ]
}

output "private_ip" {
  value = openstack_orchestration_stack_v1.lb_admin[*].outputs[1]["output_value"]
  depends_on = [
    openstack_orchestration_stack_v1.lb_admin
  ]
}


