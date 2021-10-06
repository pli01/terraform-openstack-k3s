# Get the uuid of image
data "openstack_images_image_v2" "debian_current" {
  name        = var.image
  most_recent = var.most_recent_image ? true : false
}

resource "openstack_blockstorage_volume_v2" "root_volume" {
  name        = format("%s-%s", var.prefix_name, "root-volume")
  size        = var.vol_size
  volume_type = var.vol_type
  image_id    = data.openstack_images_image_v2.debian_current.id
}

