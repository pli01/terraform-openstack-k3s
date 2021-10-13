#
resource "openstack_blockstorage_volume_v2" "bastion-data_volume" {
  count = var.bastion_data_enable ? var.bastion_count : 0
  name        = format("%s-%s-%s-%s", var.prefix_name, "bastion", count.index + 1, "data-volume")
  size        = var.bastion_data_size
  volume_type = var.vol_type
}

