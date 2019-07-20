output "server_floatingip_address" {
  value = "${openstack_networking_floatingip_v2.floatingip_1.address}"
}

# output "nodes_ip" {
#   value = "${local.prometheus_config}"
# }

# output "nodes_data" {
#   value = "${module.nodes.nodes_data}"
# }
