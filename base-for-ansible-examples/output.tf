output "bastion_host_floatingip_address" {
  value = "${openstack_networking_floatingip_v2.floatingip_bastion_host.address}"
}
output "LB_floatingip_address" {
  value = "${openstack_networking_floatingip_v2.floatingip_lb.address}"
}

output "internal_bastion_host_ip" {
  value = "${openstack_compute_instance_v2.bastion_host.access_ip_v4}"
}
output "internal_lb_host_ip" {
  value = "${openstack_compute_instance_v2.lb_host.access_ip_v4}"
}
output "internal_db_host_ip" {
  value = "${openstack_compute_instance_v2.db.access_ip_v4}"
}

output "web_servers_internal_ip" {
  value = "${formatlist("%v %v", openstack_compute_instance_v2.web_servers.*.name, openstack_compute_instance_v2.web_servers.*.network.0.fixed_ip_v4)}"
}


locals {
  jump_host_ip        = "${openstack_networking_floatingip_v2.floatingip_bastion_host.address}"
  web_hosts_inventory = <<EOT
%{for host in openstack_compute_instance_v2.web_servers.*~}
${host.name} ansible_host=${host.access_ip_v4} ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q root@${local.jump_host_ip}"' env=prod
%{endfor}
EOT
}

data "template_file" "ansible_inventory" {
  template = "${file("templates/ansible_inventory.tpl")}"
  vars = {
    jump_host_ip = "${local.jump_host_ip}"
    db_host_ip = "${openstack_compute_instance_v2.db.access_ip_v4}"
    lb_host_ip = "${openstack_compute_instance_v2.lb_host.access_ip_v4}"
    lb_public_ip = "${openstack_networking_floatingip_v2.floatingip_lb.address}"
    # web_hosts_ips = "${openstack_compute_instance_v2.web_servers.*.access_ip_v4}"
    web_hosts_inventory = "${local.web_hosts_inventory}"
  }
}

output "ansible_inventory" {
  value = "${data.template_file.ansible_inventory.rendered}"
}
