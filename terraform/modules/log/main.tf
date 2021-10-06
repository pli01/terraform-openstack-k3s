#### Heat CONFIGURATION ####
# create heat stack
resource "openstack_orchestration_stack_v1" "log" {
  count = var.maxcount
  name  = format("%s-%s-%s", var.prefix_name, "log", count.index + 1)
  # override heat parameters
  parameters = {
    wait_condition_timeout = var.heat_wait_condition_timeout
    floating_ip_id  = element(var.fip, count.index)
    security_group  = var.security_group
    worker_network  = var.network
    worker_subnet   = var.subnet
    source_volid    = var.source_volid
    worker_data_volume_id   = var.log_data_enable ? var.worker_data_volume_id[count.index] : null
    worker_vol_type = var.vol_type
    worker_flavor   = var.flavor
    key_name        = var.key_name
    user_data       = data.cloudinit_config.log_config.rendered
  }
  # override heat parameters with param files
  environment_opts = {
    #Bin = "\n"
    Bin = templatefile("${path.module}/../../heat/log-env.yaml.tpl", {
      log_data_enable = var.log_data_enable
       })
    # Bin = file("heat/log-param.yaml")
  }
  # define heat file
  template_opts = {
    Bin = file("${path.module}/../../heat/log.yaml")
    # Bin = file("${path.root}/heat/log.yaml")
    #Bin = file("${path.cwd}/heat/log.yaml")
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

