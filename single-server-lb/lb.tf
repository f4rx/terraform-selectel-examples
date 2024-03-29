resource "openstack_lb_loadbalancer_v2" "loadbalancer_1" {
  name = "loadbalancer_1"
  vip_subnet_id = "${openstack_networking_subnet_v2.subnet_1.id}"
  region = "ru-3"
#   loadbalancer_provider = "octavia"
}


resource "openstack_networking_floatingip_associate_v2" "association_2" {
  port_id     = "${openstack_lb_loadbalancer_v2.loadbalancer_1.vip_port_id}"
  floating_ip = "${openstack_networking_floatingip_v2.floatingip_2.address}"
}

resource "openstack_networking_floatingip_v2" "floatingip_2" {
  pool = "external-network"
}

resource "openstack_lb_listener_v2" "listener_1" {
  name = "listener_1"
  protocol = "TCP"
  protocol_port = 80
  default_pool_id = "${openstack_lb_pool_v2.pool_1.id}"
  loadbalancer_id = "${openstack_lb_loadbalancer_v2.loadbalancer_1.id}"
}

resource "openstack_lb_pool_v2" "pool_1" {
  name            = "pool_1"
  protocol        = "TCP"
  lb_method       = "ROUND_ROBIN"
  persistence {
      type = "SOURCE_IP"
  }
  loadbalancer_id = "${openstack_lb_loadbalancer_v2.loadbalancer_1.id}"
}

resource "openstack_lb_member_v2" "member_1" {
  address       = "${openstack_networking_port_v2.port_1.all_fixed_ips.0}"
#   address       = "192.168.0.7"
  protocol_port = 80
  pool_id = "${openstack_lb_pool_v2.pool_1.id}"
}

resource "openstack_lb_monitor_v2" "monitor_1" {
  pool_id     = "${openstack_lb_pool_v2.pool_1.id}"
  type        = "TCP"
  delay       = 2
  timeout     = 4
  max_retries = 5
}

