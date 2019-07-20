resource "openstack_networking_port_v2" "port" {
  count = "${var.server_count}"
  name       = "${var.server_name}-${count.index + 1}-eth0"
  network_id = "${var.network_id}"

  fixed_ip {
    subnet_id = "${var.subnet_id}"
  }
}

resource "openstack_blockstorage_volume_v3" "volume" {
  count = "${var.server_count}"
  name              = "volume-for-node-${count.index + 1}"
  size              = "10"
  image_id          = "${var.image_id}"
  volume_type       = "${var.volume_type}"
  availability_zone = "${var.az_zone}"

  lifecycle {
    ignore_changes = ["image_id"]
  }
}

resource "openstack_compute_instance_v2" "node" {
  count = "${var.server_count}"
  name              = "node-${count.index + 1}"
  flavor_id         = "${var.flavor_id}"
  key_pair          = "${var.key_pair_id}"
  availability_zone = "${var.az_zone}"

  network {
    port = "${openstack_networking_port_v2.port[count.index].id}"
  }

  block_device {
    uuid             = "${openstack_blockstorage_volume_v3.volume[count.index].id}"
    source_type      = "volume"
    destination_type = "volume"
    boot_index       = 0
  }

  vendor_options {
    ignore_resize_confirmation = true
  }
}

