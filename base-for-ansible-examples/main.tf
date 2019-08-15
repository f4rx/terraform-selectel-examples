# Configure the OpenStack Provider
provider "openstack" {
  domain_name = "${var.domain_name}"
  tenant_name = "${var.project_name}"
  user_name   = "${var.user_name}"
  password    = "${var.user_password}"
  auth_url    = "https://api.selvpc.ru/identity/v3"
  region      = "${var.region}"
  use_octavia = true
}


# Flavor
resource "openstack_compute_flavor_v2" "flavor_1" {
  name      = "flavor-1cpu-1g-0hdd"
  ram       = "1024"
  vcpus     = "1"
  disk      = "0"
  is_public = false

  lifecycle {
    create_before_destroy = false
  }
}

resource "openstack_compute_flavor_v2" "flavor_2" {
  name      = "flavor-2cpu-1g-0hdd"
  ram       = "1024"
  vcpus     = "2"
  disk      = "0"
  is_public = false

  lifecycle {
    create_before_destroy = false
  }
}

resource "openstack_compute_flavor_v2" "flavor_3" {
  name      = "flavor-4cpu-4g-0hdd"
  ram       = "4096"
  vcpus     = "4"
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
data "openstack_images_image_v2" "centos_7_minimal" {
  most_recent = true
  properties = {
    x_sel_image_source_file = "centos-7-minimal-amd64-selectel-master-product-0.1.img"
  }
  visibility = "public"
}
