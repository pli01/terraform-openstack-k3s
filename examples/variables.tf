variable "prefix_name" {
  default = "test"
}

variable "heat_wait_condition_timeout" {
  type    = number
}

variable "bastion_count" {
  type    = number
  default = 1
}

variable "http_proxy_count" {
  type    = number
  default = 1
}

variable "log_count" {
  type    = number
  default = 1
}


# Params file for variables

#### GLANCE
variable "image" {
  type    = string
  default = "debian-latest"
}
variable "most_recent_image" {
  # default = "true"
  default = "false"
}
#### NEUTRON
variable "external_network" {
  type    = string
  default = "external-network"
}

variable "dns_nameservers" {
  type    = list(string)
  default = ["8.8.8.8", "8.8.8.4"]
}

variable "network_worker" {
  type = map(string)
  default = {
    subnet_name = "subnet-worker"
    cidr        = "192.168.1.0/24"
  }
}

#### MAIN DISK SIZE FOR WORKER
variable "vol_size" {
  type    = number
  default = 10
}

variable "vol_type" {
  type    = string
  default = "default"
}

#### VM parameters ####
variable "key_name" {
  type    = string
  default = "debian"
}

variable "bastion_flavor" {
  type    = string
  default = "t1.small"
}
variable "http_proxy_flavor" {
  type    = string
  default = "t1.small"
}
variable "log_flavor" {
  type    = string
  default = "t1.small"
}


#### Variable used in heat and cloud-init
variable "no_proxy" {
  type    = string
  default = "localhost"
}

variable "ssh_access_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "ssh_authorized_keys" {
  type    = list(string)
  default = []
}

#### http_proxy #####
variable "tinyproxy_upstream" {
  default = ""
}
variable "tinyproxy_proxy_authorization" {
  default = ""
}
variable "dns_domainname" {
  type    = list(string)
  default = []
}
variable "nexus_server" {
  default = ""
}
variable "mirror_docker" {
  default = "https://download.docker.com/linux/debian"
}
variable "mirror_docker_key" {
  default = "https://download.docker.com/linux/debian/gpg"
}
variable "docker_version" {
  default = "docker-ce=5:19.03.11~3-0~debian-stretch"
}
variable "docker_compose_version" {
  default = "1.21.2"
}

variable "dockerhub_login" {
  default = ""
}
variable "dockerhub_token" {
  default = ""
}
variable "github_token" {
  default = ""
}

variable "docker_registry_username" {
  default = ""
}

variable "docker_registry_token" {
  default = ""
}
# enable metric
variable "metric_enable" {
  type = bool
  default = false
}

variable "k3s_master_count" {
  type    = number
  default = 1
}
variable "k3s_master_flavor" {
  type    = string
  default = "t1.small"
}
variable "k3s_master_data_enable" {
  type = bool
}
variable "k3s_master_data_size" {
  type = number
}
variable "k3s_master_metric_variables" {
   type = map
   default = {}
}
variable "k3s_master_install_script" {
  default = ""
}
variable "k3s_master_variables" {
   type = map
   default = {}
}

#
variable "k3s_agent_count" {
  type    = number
  default = 1
}
variable "k3s_agent_flavor" {
  type    = string
  default = "t1.small"
}
variable "k3s_agent_data_enable" {
  type = bool
}
variable "k3s_agent_data_size" {
  type = number
}
variable "k3s_agent_metric_variables" {
   type = map
   default = {}
}
variable "k3s_agent_install_script" {
  default = ""
}
variable "k3s_agent_variables" {
   type = map
   default = {}
}


#
variable "log_install_script" {
}

variable "log_variables" {
  type = map
  default = {}
}

# lb
variable "lb_admin_count" {
  type    = number
  default = 1
}
variable "lb_admin_flavor" {
  type    = string
  default = "t1.small"
}
variable "lb_admin_metric_variables" {
   type = map
   default = {}
}
variable "lb_admin_install_script" {
  default = ""
}
variable "lb_admin_variables" {
  type = map
  default = {}
}


# lb
variable "lb_count" {
  type    = number
  default = 1
}
variable "lb_flavor" {
  type    = string
  default = "t1.small"
}
variable "lb_metric_variables" {
   type = map
   default = {}
}
variable "lb_install_script" {
  default = ""
}
variable "lb_variables" {
  type = map
  default = {}
}

#
variable "bastion_data_enable" {
  type = bool
}
variable "bastion_data_size" {
  type = number
}
variable "log_data_enable" {
  type = bool
}
variable "log_data_size" {
  type = number
}

