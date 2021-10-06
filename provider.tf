terraform {
  required_version = ">= 0.14"
  required_providers {
    openstack = {
      version = "1.35.0"
      source = "terraform-provider-openstack/openstack"
    }
    docker = {
      version = "2.11.0"
      source = "kreuzwerker/docker"
    }
    random = {}
    cloud-init = {
     version = "2.2.0"
     source = "hashicorp/cloudinit"
    }
  }
}
