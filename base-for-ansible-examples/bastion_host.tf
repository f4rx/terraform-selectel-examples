# Он же мониторинг и прокси хост
resource "openstack_networking_port_v2" "bastion_host_port_1" {
  name       = "${var.server_name}-eth0"
  network_id = "${openstack_networking_network_v2.network_1.id}"

  fixed_ip {
    subnet_id = "${openstack_networking_subnet_v2.subnet_1.id}"
  }
}

# Create Disk
resource "openstack_blockstorage_volume_v3" "bastion_host_volume_1" {
  name              = "volume-for-${var.server_name}"
  size              = "10"
  image_id          = "${data.openstack_images_image_v2.centos_7_minimal.id}"
  volume_type       = "${var.volume_type}"
  availability_zone = "${var.az_zone}"

  lifecycle {
    ignore_changes = ["image_id"]
  }
}

resource "openstack_compute_instance_v2" "bastion_host" {
  name              = "bastion"
  flavor_id         = "${openstack_compute_flavor_v2.flavor_1.id}"
  key_pair          = "${openstack_compute_keypair_v2.terraform_key.id}"
  availability_zone = "${var.az_zone}"

  network {
    port = "${openstack_networking_port_v2.bastion_host_port_1.id}"
  }

  block_device {
    uuid             = "${openstack_blockstorage_volume_v3.bastion_host_volume_1.id}"
    source_type      = "volume"
    destination_type = "volume"
    boot_index       = 0
  }

  vendor_options {
    ignore_resize_confirmation = true
  }

}

# Create floating IP
resource "openstack_networking_floatingip_v2" "floatingip_bastion_host" {
  pool = "external-network"
}

resource "openstack_networking_floatingip_associate_v2" "association_bastion_host" {
  port_id     = "${openstack_networking_port_v2.bastion_host_port_1.id}"
  floating_ip = "${openstack_networking_floatingip_v2.floatingip_bastion_host.address}"
}

