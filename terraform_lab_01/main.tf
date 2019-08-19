###################################
# Configure the OpenStack Provider
###################################
provider "openstack" {
  domain_name = "${var.domain_name}"
  tenant_name = "${var.project_name}"
  user_name   = "${var.user_name}"
  password    = "${var.user_password}"
  auth_url    = "https://api.selvpc.ru/identity/v3"
  region      = "${var.region}"
}
###################################
# Flavor
###################################
resource "openstack_compute_flavor_v2" "flavor_1" {
  name      = "flavor-1cpu-1g-0hdd"
  ram       = "${var.ram}"
  vcpus     = "${var.vcpus}"
  disk      = "0"
  is_public = false

  lifecycle {
    create_before_destroy = false
  }
}

###################################
# Get image ID
###################################
data "openstack_images_image_v2" "image_nginx" {
  region      = "${var.region}"
  most_recent = true
  visibility  = "private"
  properties = {
    tags = "packer_nginx"
  }
}

###################################
# Create SSH-key
###################################
resource "openstack_compute_keypair_v2" "terraform_key" {
  name       = "terraform_key"
  region     = "${var.region}"
  public_key = "${var.public_key}"
}

###################################
# Get Network and Subnet
###################################
data "openstack_networking_subnet_v2" "subnet_1" {
  name = "192.168.0.0/24"
}
data "openstack_networking_network_v2" "network_1" {
  name = "nat"
}

###################################
# Create port
###################################
resource "openstack_networking_port_v2" "port_1" {
  name       = "${var.server_name}-eth0"
  network_id = "${data.openstack_networking_network_v2.network_1.id}"

  fixed_ip {
    subnet_id = "${data.openstack_networking_subnet_v2.subnet_1.id}"
  }
}

###################################
# Create floating IP
###################################
resource "openstack_networking_floatingip_v2" "floatingip_1" {
  pool = "external-network"
}

###################################
# Create Volume/Disk
###################################
resource "openstack_blockstorage_volume_v3" "volume_1" {
  name              = "volume-for-${var.server_name}"
  size              = "${var.hdd_size}"
  image_id          = "${data.openstack_images_image_v2.image_nginx.id}"
  volume_type       = "${var.volume_type}"
  availability_zone = "${var.az_zone}"
  enable_online_resize = true

  lifecycle {
    ignore_changes = ["image_id"]
  }
}

###################################
# Create Server
###################################
resource "openstack_compute_instance_v2" "instance_1" {
  name              = "${var.server_name}"
  flavor_id         = "${openstack_compute_flavor_v2.flavor_1.id}"
  key_pair          = "${openstack_compute_keypair_v2.terraform_key.id}"
  availability_zone = "${var.az_zone}"

  network {
    port = "${openstack_networking_port_v2.port_1.id}"
  }

  block_device {
    uuid             = "${openstack_blockstorage_volume_v3.volume_1.id}"
    source_type      = "volume"
    destination_type = "volume"
    boot_index       = 0
  }

  vendor_options {
    ignore_resize_confirmation = true
  }
}

###################################
# Link floating IP to internal IP
###################################
resource "openstack_networking_floatingip_associate_v2" "association_1" {
  port_id     = "${openstack_networking_port_v2.port_1.id}"
  floating_ip = "${openstack_networking_floatingip_v2.floatingip_1.address}"
}
