variable "user_name" {
  default = "terraform_user"
}
variable "user_password" {}

variable "donain_name" {}

variable "region" {
  default = "ru-3"
}
variable "az_zone" {
  default = "ru-3a"
}

variable "volume_type" {
  default = "fast.ru-3a"
}


variable "public_key" {}

variable "server_name" {
  default = "server"
}

variable "server_count" {
  default = 2
}
