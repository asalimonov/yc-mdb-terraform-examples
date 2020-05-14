output "route_table_a_id" {
  value = "${yandex_vpc_route_table.route_table_a.id}"
}

output "internal_ip_address_nat_a" {
  value = "${yandex_compute_instance.nat_instance_a.network_interface.0.ip_address}"
}

output "external_ip_address_nat_a" {
  value = "${yandex_compute_instance.nat_instance_a.network_interface.0.nat_ip_address}"
}

output "fqdn_nat_instance_a" {
  value = "${yandex_compute_instance.nat_instance_a.fqdn}"
}

