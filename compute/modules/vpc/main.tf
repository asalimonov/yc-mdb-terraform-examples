variable "network_name" {
  type    = "string"
  default = "default"
}

variable "network_id" {
  type    = "string"
  default = ""
}

variable "subnets" {
  type = map(object({
    zone           = string
    v4_cidr_blocks = list(string)
    route_table_id = string
  }))
}

resource "yandex_vpc_network" "vpc_network" {
  count = var.network_id != "" ? 0 : 1
  name  = var.network_name
}

resource "yandex_vpc_subnet" "subnet" {
  count          = length(keys(var.subnets))
  name           = keys(var.subnets)[count.index]
  zone           = lookup(var.subnets, keys(var.subnets)[count.index]).zone
  v4_cidr_blocks = lookup(var.subnets, keys(var.subnets)[count.index]).v4_cidr_blocks
  route_table_id = lookup(var.subnets, keys(var.subnets)[count.index]).route_table_id
  network_id     = var.network_id != "" ? var.network_id : "${yandex_vpc_network.vpc_network.0.id}"
}
