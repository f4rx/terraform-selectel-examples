variable "user_name" {
}
variable "user_password" {}

variable "domain_name" {}

variable "region" {
}
variable "az_zone" {
}

variable "volume_type" {}


variable "public_key" {}

variable "server_name" {
  default = "server"
}

variable "project_name" {}

variable "ram" {
  default = "2048"
}

variable "vcpus" {
  default = "2"
}
variable "hdd_size" {
  default = "10"
}
