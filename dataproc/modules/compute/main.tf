variable "labels" {
  type = map(string)
}

variable "subnet_a_id" {
  type = "string"
}

variable "subnet_b_id" {
  type = "string"
}
variable "subnet_c_id" {
  type = "string"
}

variable "vm_user" {
  type = "string"
}

resource "yandex_compute_instance" "bastion" {
  name        = "bastion host"
  description = "Bastion host for DataProc"

  labels = var.labels
  platform_id = "standard-v2"

  resources {
    cores  = 2
    core_fraction = 20
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd8j9nuap0vh3k1f5m8s"
      size     = 24 #GiB
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = var.subnet_a_id
    nat       = true
  }

  metadata = {
    ssh-keys = "${var.vm_user}:${file("~/.ssh/id_rsa.pub")}"

  }
}