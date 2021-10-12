#### Heat CONFIGURATION ####
# create heat stack
resource "openstack_orchestration_stack_v1" "app" {
  count = var.maxcount
  name  = format("%s-%s-%s", var.prefix_name, var.app_name, count.index + 1)
  # override heat parameters
  parameters = {
    wait_condition_timeout = var.heat_wait_condition_timeout
    floating_ip_id  = length(var.fip) > 0 ? element(var.fip, count.index) : null
    security_group  = var.security_group
    worker_network  = var.network
    worker_subnet   = var.subnet
    source_volid    = var.source_volid
    worker_data_volume_id   = var.app_data_enable ? var.worker_data_volume_id[count.index] : null
    worker_vol_type = var.vol_type
    worker_flavor   = var.flavor
    key_name        = var.key_name
    user_data       = data.cloudinit_config.app_config.rendered
  }
  # override heat parameters with param files
  environment_opts = {
    #Bin = "\n"
    Bin = templatefile("${path.module}/../../heat/app-env.yaml.tpl", {
      app_data_enable = var.app_data_enable
      app_fip_enable  = length(var.fip) > 0 ? true : false
       })
    # Bin = file("heat/app-param.yaml")
  }
  # define heat file
  template_opts = {
    Bin = file("${path.module}/../../heat/app.yaml")
    # Bin = file("${path.root}/heat/app.yaml")
    #Bin = file("${path.cwd}/heat/app.yaml")
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

