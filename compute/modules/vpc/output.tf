output "vpc_network_id" {
  value = var.network_id != "" ? var.network_id : "${yandex_vpc_network.vpc_network.0.id}"
}

output "vpc_subnets" {
  value = yandex_vpc_subnet.subnet
}

output "subnet_ids_by_names" {
  value = {
    for instance in yandex_vpc_subnet.subnet :
    instance.name => instance.id
  }
}

output "subnets_ids" {
  value = "${yandex_vpc_subnet.subnet.*.id}"
}