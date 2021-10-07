# declare any input variables
# defines variables in variables.tf
# override variable in File "terraform.tfvars" or in cli -var key=value or TF_VAR_var=value
variable "prefix_name" {
  default = "test"
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

#### GLANCE
variable "image" {
  type    = string
  default = "debian-latest"
}
variable "most_recent_image" {
  # default = "true"
  default = "false"
}

#### VM parameters ####
variable "key_name" {
  type    = string
  default = "debian"
}

variable "heat_wait_condition_timeout" {
  type    = number
  default = 1200
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

# bastion
variable "bastion_count" {
  type    = number
  default = 1
}
variable "bastion_flavor" {
  type    = string
  default = "t1.small"
}
variable "bastion_data_enable" {
  type = bool
  default = false
}
variable "bastion_data_size" {
  type = number
  default = 0
}

# http-proxy out
variable "http_proxy_count" {
  type    = number
  default = 1
}
variable "http_proxy_flavor" {
  type    = string
  default = "t1.small"
}

#### http_proxy #####
variable "tinyproxy_upstream" {
  default     = []
  description = "[\"upstream proxy:8080 .domain.org\",\"no upstream .direct.domain\"]"
}
variable "tinyproxy_proxy_authorization" {
  default = ""
}
variable "dns_domainname" {
  type    = list(string)
  default = []
}
variable "syslog_relay" {
   default = ""
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
variable "metric_install_script" {
  default = "https://raw.githubusercontent.com/pli01/beat-stack/master/ci/docker-deploy.sh"
}


