variable "labels" {
  type = map(string)
}

variable "nat_subnet_a_id" {
  type = "string"
}

variable "network_id" {
  type = "string"
}

variable "vm_user" {
  type    = "string"
  default = "ubuntu"
}

variable "rt_nat_a_id" {
  type = "string"
}

resource "yandex_compute_instance" "nat_instance_a" {
  name        = "nat-instance-a"
  description = "NAT Instance"

  labels = var.labels

  resources {
    cores         = 2
    core_fraction = 20
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8o3spn0omg6o3ohkhi"
      size     = 12 #GiB
      type     = "network-hdd"
    }

  }

  network_interface {
    subnet_id = var.nat_subnet_a_id
    nat       = true
  }

  metadata = {
    ssh-keys = "${var.vm_user}:${file("~/.ssh/id_rsa.pub")}"

  }
}

resource "yandex_vpc_route_table" "route_table_a" {
  name       = "${var.rt_nat_a_id}"
  network_id = "${var.network_id}"

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat_instance_a.network_interface.0.ip_address
  }
}
