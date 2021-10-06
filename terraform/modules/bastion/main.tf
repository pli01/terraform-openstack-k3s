#### Heat CONFIGURATION ####
# create heat stack
resource "openstack_orchestration_stack_v1" "bastion" {
  count = var.maxcount
  name  = format("%s-%s-%s", var.prefix_name, "bastion", count.index + 1)
  # override heat parameters
  parameters = {
    wait_condition_timeout = var.heat_wait_condition_timeout
    floating_ip_id  = var.fip
    security_group  = var.security_group
    worker_network  = var.network
    worker_subnet   = var.subnet
    source_volid    = var.source_volid
    worker_data_volume_id   = var.bastion_data_enable ? var.worker_data_volume_id[count.index] : null
    worker_vol_type = var.vol_type
    worker_flavor   = var.flavor
    key_name        = var.key_name
    user_data       = data.cloudinit_config.bastion_config.rendered
  }
  # override heat parameters with param files
  environment_opts = {
    #Bin = "\n"
    Bin = templatefile("${path.module}/../../heat/bastion-env.yaml.tpl", {
      bastion_data_enable = var.bastion_data_enable
       })
    # Bin = file("heat/bastion-param.yaml")
  }
  # define heat file
  template_opts = {
    Bin = file("${path.module}/../../heat/bastion.yaml")
    # Bin = file("${path.root}/heat/bastion.yaml")
    #Bin = file("${path.cwd}/heat/bastion.yaml")
  }
  disable_rollback = true
  #  disable_rollback = false
  timeout = 30
  lifecycle {
  ignore_changes = [
     parameters,
     template_opts,
    ]
  }
}

