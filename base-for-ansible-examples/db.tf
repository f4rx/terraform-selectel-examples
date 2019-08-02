
resource "openstack_networking_port_v2" "port_db" {
  name       = "${var.server_name}-db-eth0"
  network_id = "${openstack_networking_network_v2.network_1.id}"

  fixed_ip {
    subnet_id = "${openstack_networking_subnet_v2.subnet_1.id}"
  }
}

resource "openstack_blockstorage_volume_v3" "volume_db" {
  name              = "volume-db"
  size              = "10"
  image_id          = "${data.openstack_images_image_v2.centos_7_minimal.id}"
  volume_type       = "${var.volume_type}"
  availability_zone = "${var.az_zone}"

  lifecycle {
    ignore_changes = ["image_id"]
  }
}

resource "openstack_compute_instance_v2" "db" {
  name              = "postgresql"
  flavor_id         = "${openstack_compute_flavor_v2.flavor_1.id}"
  key_pair          = "${openstack_compute_keypair_v2.terraform_key.id}"
  availability_zone = "${var.az_zone}"

  network {
    port = "${openstack_networking_port_v2.port_db.id}"
  }

  block_device {
    uuid             = "${openstack_blockstorage_volume_v3.volume_db.id}"
    source_type      = "volume"
    destination_type = "volume"
    boot_index       = 0
  }

  vendor_options {
    ignore_resize_confirmation = true
  }

}
