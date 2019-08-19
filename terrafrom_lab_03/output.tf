output "server_floatingip_address" {
  value = "${openstack_networking_floatingip_v2.floatingip_1.address}"
}
output "LB_floatingip_address" {
  value = "${openstack_networking_floatingip_v2.floatingip_2.address}"
}

locals {

  jump_host_ip        = "${openstack_networking_floatingip_v2.floatingip_1.address}"
  web_hosts_inventory = <<EOT
%{for host in openstack_compute_instance_v2.web_servers.*~}
${host.name} ansible_host=${host.access_ip_v4} ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q root@${local.jump_host_ip}"'
%{endfor}
EOT
}

data "template_file" "ansible_inventory" {
  template = "${file("templates/ansigle_inventory.tpl")}"
  vars = {
    jump_host_ip = "${local.jump_host_ip}"
    db_host_ip = "${openstack_compute_instance_v2.db.access_ip_v4}"
    # web_hosts_ips = "${openstack_compute_instance_v2.web_servers.*.access_ip_v4}"
    web_hosts_inventory = "${local.web_hosts_inventory}"
  }
}



output "ansible_inventory" {
  value = "${data.template_file.ansible_inventory.rendered}"
}
