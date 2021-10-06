# app userdata
data "cloudinit_config" "app_config" {
  gzip          = false
  base64_encode = false

  # order matter
  # cloud-init.cfg
  part {
    filename     = "cloud-init.cfg"
    content_type = "text/cloud-config"
    content      = file("${path.module}/../../heat/config-scripts/cloud-init.tpl")
  }
  # config.cfg sourced in each script, and contains all needed variables
  part {
    content_type = "text/plain"
    content = templatefile("${path.module}/../../heat/config-scripts/config.cfg.tpl", {
      ssh_authorized_keys           = jsonencode(var.ssh_authorized_keys)
      no_proxy                      = var.no_proxy
      tinyproxy_upstream            = var.tinyproxy_upstream
      tinyproxy_proxy_authorization = var.tinyproxy_proxy_authorization
      internal_http_proxy           = var.internal_http_proxy
      dns_nameservers               = jsonencode(var.dns_nameservers)
      dns_domainname                = jsonencode(var.dns_domainname)
      syslog_relay                  = var.syslog_relay
      nexus_server                  = var.nexus_server
      mirror_docker                 = var.mirror_docker
      mirror_docker_key             = var.mirror_docker_key
      docker_version                = var.docker_version
      docker_compose_version        = var.docker_compose_version
      metric_enable                 = var.metric_enable
      metric_install_script         = var.metric_install_script
      metric_variables              = var.metric_variables
    })
  }
  part {
    content_type = "text/plain"
    content      = file("${path.module}/../../heat/config-scripts/worker_data_volume_attachment.sh")
  }
  part {
    content_type = "text/plain"
    content      = file("${path.module}/../../heat/config-scripts/worker_configure_syslog.sh")
  }
  part {
    content_type = "text/plain"
    content      = file("${path.module}/../../heat/config-scripts/worker_install_ssh_keys.sh")
  }
  part {
    content_type = "text/plain"
    content      = file("${path.module}/../../heat/config-scripts/worker_install_docker.sh")
  }
  # app.cfg sourced in app script, and contains all needed variables
  part {
    content_type = "text/plain"
    content = templatefile("${path.module}/../../heat/config-scripts/app.cfg.tpl", {
      dockerhub_login          = var.dockerhub_login
      dockerhub_token          = var.dockerhub_token
      github_token             = var.github_token
      docker_registry_username = var.docker_registry_username
      docker_registry_token    = var.docker_registry_token
      app_install_script       = var.app_install_script
      app_variables            = var.app_variables
    })
  }
  part {
    content_type = "text/plain"
    content      = file("${path.module}/../../heat/config-scripts/worker_configure_metric.sh")
  }
  # post conf
  part {
    content_type = "text/plain"
    content      = file("${path.module}/../../heat/config-scripts/worker_app_postconf.sh")
  }
}
