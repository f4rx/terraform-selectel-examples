output "nodes_data" {
  value = "${formatlist("%v %v %v", openstack_compute_instance_v2.node.*.name, openstack_compute_instance_v2.node.*.id, openstack_compute_instance_v2.node.*.network.0.fixed_ip_v4)}"
}

output "nodes_list" {
  value = "${openstack_compute_instance_v2.node.*}"
}
output "node_ip_list" {
  value = "${openstack_networking_port_v2.port.*.all_fixed_ips.0}"
}
