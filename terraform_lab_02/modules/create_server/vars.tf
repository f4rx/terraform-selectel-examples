variable "server_name" {}
variable "server_count" {
    default = 1
}

variable "network_id" {}
variable "subnet_id" {}


variable "region" {
}
variable "az_zone" {
}

variable "volume_type" {}
variable "image_id" {}
variable "flavor_id" {}
variable "key_pair_id" {}

variable "bastion_host" {}

