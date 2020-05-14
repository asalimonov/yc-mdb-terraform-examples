variable "vm_user" {
  type = "string"
}

variable "disk_size" {
  type        = number
  default     = 256
  description = "Disk size in GiB"
}

variable "disk_type" {
  type        = string
  default     = "network-ssd"
  description = "Disk type: 'network-ssd', 'network-hdd', 'local-ssd'"
}

variable "labels" {
  type = "map"
  default = {
    deployment = "terraform"
  }
}

variable "cores" {
  type    = number
  default = 2
}

variable "memory" {
  type    = number
  default = 4
}

variable "hosts_per_net" {
  type    = number
  default = 2
}

variable "vm_name" {
  type    = string
  default = "vm"
}

variable "vm_description" {
  type    = string
  default = "Regular VM"
}

variable "boot_disk" {
  type = object({
    size     = number
    type     = string
    image_id = string
  })
  default = {
    size     = 10
    type     = "network-hdd"
    image_id = "fd8j9nuap0vh3k1f5m8s"
  }

}

variable "nets" {
  type = map(object({
    zone             = string
    subnet_id        = string
    assign_public_ip = bool
  }))
}

locals {
  hr = range(var.hosts_per_net)
  vms = [for pair in setproduct(keys(var.nets), local.hr) : {
    name             = format("%v-%v-%v", var.vm_name, substr(strrev(pair[0]), 0, 1), pair[1])
    sec_disk_name    = format("%v-disk", format("%v-%v-%v", var.vm_name, substr(strrev(pair[0]), 0, 1), pair[1]))
    zone             = lookup(var.nets, pair[0]).zone
    subnet_id        = lookup(var.nets, pair[0]).subnet_id
    assign_public_ip = lookup(var.nets, pair[0]).assign_public_ip

  }]
}

resource "yandex_compute_disk" "vm_disk" {
  count = length(local.vms)
  name  = element(local.vms, count.index).sec_disk_name
  zone  = element(local.vms, count.index).zone
  size  = var.disk_size
  type  = var.disk_type
}

resource "yandex_compute_instance" "vm" {
  count       = length(local.vms)
  name        = element(local.vms, count.index).name
  zone        = element(local.vms, count.index).zone
  description = var.vm_description

  network_interface {
    subnet_id = element(local.vms, count.index).subnet_id
    nat       = element(local.vms, count.index).assign_public_ip
  }

  resources {
    cores  = var.cores
    memory = var.memory
  }

  boot_disk {
    initialize_params {
      image_id = var.boot_disk.image_id
      size     = var.boot_disk.size
      type     = var.boot_disk.type
    }
  }

  secondary_disk {
    device_name = "vdd"
    disk_id     = [for d in yandex_compute_disk.vm_disk : d if d.name == element(local.vms, count.index).sec_disk_name][0].id
  }

  metadata = {
    ssh-keys = "${var.vm_user}:${file("~/.ssh/id_rsa.pub")}"
  }
}

output "out_vms" {
  value = local.vms
}


