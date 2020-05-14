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

variable "disk_stand_sizes" {
  type = list(number)
  default = [1024, 2048, 4096]
}

variable "disk_stand_disk_types" {
  type = list(string)
  default = ["network-ssd", "network-hdd"]
}

variable "disk_test_zone" {
  type = string
  default = "ru-central1-c"
}

variable "disk_test_subnet_id" {
  type = string
  default = ""
}

locals {
  disk_configs = [ for pair in setproduct(var.disk_stand_disk_types, var.disk_stand_sizes) : {
    type = pair[0]
    size = pair[1]
  }]
  disk_configs_map = zipmap([for v in local.disk_configs : "${v.type}-${v.size}" ], local.disk_configs)
}


resource "yandex_compute_disk" "stand_data_disk_ssd_512" {
  name = "stand-data-disk-ssd-512"
  size = 512
  type = "network-ssd"
  zone     = var.disk_test_zone
}

resource "yandex_compute_disk" "stand_data_disk_hdd_512" {
  name = "stand-data-disk-hdd-512"
  size = 512
  type = "network-hdd"
  zone     = var.disk_test_zone
}

resource "yandex_compute_disk" "stand_data_disk_ssd_4096" {
  name = "stand-data-disk-ssd-4096"
  size = 4096
  type = "network-ssd"
 zone     = var.disk_test_zone
}

resource "yandex_compute_disk" "stand_data_disk_hdd_4096" {
  name = "stand-data-disk-hdd-4096"
  size = 4096
  type = "network-hdd"
  zone     = var.disk_test_zone
}


resource "yandex_compute_instance" "disk_stand_vm_ssd_512" {
  name     = "disk-stand-ssd-512"
  zone     = var.disk_test_zone
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image_id = "fd8j9nuap0vh3k1f5m8s"
      size     = 12 #GiB
      type     = "network-ssd"
    }
  }

  secondary_disk {
    device_name = "vdd"
    disk_id = "${yandex_compute_disk.stand_data_disk_ssd_512.id}"
  }

  description = "Just a test disk vm"

  resources {
    cores  = 4
    memory = 8
  }

  labels = var.labels

  network_interface {
    subnet_id = var.disk_test_subnet_id
    nat       = true
  }

  metadata = {
    ssh-keys = "${var.vm_user}:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_compute_instance" "disk_stand_vm_hdd_512" {
  name     = "disk-stand-hdd-512"
  zone     = var.disk_test_zone
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image_id = "fd8j9nuap0vh3k1f5m8s"
      size     = 12 #GiB
      type     = "network-ssd"
    }
  }

  secondary_disk {
    device_name = "vdd"
    disk_id = "${yandex_compute_disk.stand_data_disk_hdd_512.id}"
  }

  description = "Just a test disk vm"

  resources {
    cores  = 4
    memory = 8
  }

  labels = var.labels

  network_interface {
    subnet_id = var.disk_test_subnet_id
    nat       = true
  }

  metadata = {
    ssh-keys = "${var.vm_user}:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_compute_instance" "disk_stand_vm_hdd_4096" {
  name     = "disk-stand-hdd-4096"
  zone     = var.disk_test_zone
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image_id = "fd8j9nuap0vh3k1f5m8s"
      size     = 12 #GiB
      type     = "network-ssd"
    }
  }

  secondary_disk {
    disk_id = "${yandex_compute_disk.stand_data_disk_hdd_4096.id}"
    device_name = "vdd"
  }

  description = "Just a test disk vm"

  resources {
    cores  = 4
    memory = 8
  }

  labels = var.labels

  network_interface {
    subnet_id = var.disk_test_subnet_id
    nat       = true
  }

  metadata = {
    ssh-keys = "${var.vm_user}:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_compute_instance" "disk_stand_vm_ssd_4096" {
  name     = "disk-stand-ssd-4096"
  zone     = var.disk_test_zone
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image_id = "fd8j9nuap0vh3k1f5m8s"
      size     = 12 #GiB
      type     = "network-ssd"
    }
  }

  secondary_disk {
    disk_id = "${yandex_compute_disk.stand_data_disk_ssd_4096.id}"
    device_name = "vdd"
  }

  description = "Just a test disk vm"

  resources {
    cores  = 4
    memory = 8
  }

  labels = var.labels

  network_interface {
    subnet_id = var.disk_test_subnet_id
    nat       = true
  }

  metadata = {
    ssh-keys = "${var.vm_user}:${file("~/.ssh/id_rsa.pub")}"
  }
}