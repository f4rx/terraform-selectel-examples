# Configure the OpenStack Provider
provider "openstack" {
  domain_name = "47951"
  tenant_name = "terraform"
  user_name   = "${var.user_name}"
  password    = "${var.user_password}"
  auth_url    = "https://api.selvpc.ru/identity/v3"
  region      = "${var.region}"
}

resource "random_string" "random_name_1" {
  length  = 8
  special = false
}
resource "random_string" "random_name_2" {
  length  = 8
  special = false
}

# Flavor
resource "openstack_compute_flavor_v2" "node_flavor" {
  name      = "flavor-1cpu-2g-0hdd-${random_string.random_name_1.result}"
  ram       = "2048"
  vcpus     = "2"
  disk      = "0"
  is_public = false

  lifecycle {
    create_before_destroy = false
  }
}

resource "openstack_compute_flavor_v2" "jump_box_flavor" {
  name      = "flavor-1cpu-1g-0hdd-${random_string.random_name_2.result}"
  ram       = "1024"
  vcpus     = "1"
  disk      = "0"
  is_public = false

  lifecycle {
    create_before_destroy = false
  }
}

# SSH-key
resource "openstack_compute_keypair_v2" "terraform_key" {
  name       = "terraform_key"
  region     = "${var.region}"
  public_key = "${var.public_key}"
}

# Get image ID
data "openstack_images_image_v2" "image_ubuntu_18_04" {
  most_recent = true
  properties = {
    x_sel_image_source_file = "ubuntu-bionic-amd64-selectel-master-product-0.1.img"
  }
  visibility = "public"
}

# Create Network
data "openstack_networking_network_v2" "external_net" {
  name = "external-network"
}

resource "openstack_networking_router_v2" "router_1" {
  name                = "router_1"
  external_network_id = "${data.openstack_networking_network_v2.external_net.id}"
}

resource "openstack_networking_network_v2" "network_1" {
  name = "network_1"
}

resource "openstack_networking_subnet_v2" "subnet_1" {
  network_id = "${openstack_networking_network_v2.network_1.id}"
  name       = "192.168.0.0/24"
  cidr       = "192.168.0.0/24"
}

resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = "${openstack_networking_router_v2.router_1.id}"
  subnet_id = "${openstack_networking_subnet_v2.subnet_1.id}"
}


# Create floating IP
resource "openstack_networking_floatingip_v2" "floatingip_1" {
  pool = "external-network"
}



# Create Jump Box
resource "openstack_networking_port_v2" "port_1" {
  name       = "jump-box-eth0"
  network_id = "${openstack_networking_network_v2.network_1.id}"

  fixed_ip {
    subnet_id = "${openstack_networking_subnet_v2.subnet_1.id}"
  }
}


# Create Disb
resource "openstack_blockstorage_volume_v3" "volume_1" {
  name              = "volume-for-jump-box"
  size              = "10"
  image_id          = "${data.openstack_images_image_v2.image_ubuntu_18_04.id}"
  volume_type       = "${var.volume_type}"
  availability_zone = "${var.az_zone}"

  lifecycle {
    ignore_changes = ["image_id"]
  }
}

resource "openstack_compute_instance_v2" "jump_box" {
  name              = "jump-box"
  flavor_id         = "${openstack_compute_flavor_v2.jump_box_flavor.id}"
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

resource "openstack_networking_floatingip_associate_v2" "association_1" {
  port_id     = "${openstack_networking_port_v2.port_1.id}"
  floating_ip = "${openstack_networking_floatingip_v2.floatingip_1.address}"
}


# Create 3 nodes
module "nodes" {
  source = "./modules/create_server"
  server_count = 3
  server_name = "node"

  network_id = "${openstack_networking_network_v2.network_1.id}"
  subnet_id = "${openstack_networking_subnet_v2.subnet_1.id}"

  image_id = "${data.openstack_images_image_v2.image_ubuntu_18_04.id}"
  region = "${var.region}"
  az_zone = "${var.az_zone}"
  volume_type = "${var.volume_type}"

  key_pair_id = "${openstack_compute_keypair_v2.terraform_key.id}"
  flavor_id = "${openstack_compute_flavor_v2.node_flavor.id}"
}
