provider "yandex" {
  version   = "~> 0.29"
  token     = var.yc_oauth_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_main_zone
}

module prod_vpc_nat {
  source     = "../../modules/vpc"
  network_id = "enpjh6vgobam88mlp3f4"

  subnets = {
    "nat-subnet-a" : {
      zone           = "ru-central1-a"
      v4_cidr_blocks = ["10.10.11.0/24"]
      route_table_id = ""
    }
  }
}

module nat_a {
  source          = "../../modules/nat"
  rt_nat_a_id     = "rt-nat-a"
  vm_user         = "ubuntu"
  nat_subnet_a_id = module.prod_vpc_nat.subnet_ids_by_names["nat-subnet-a"]
  network_id      = "enpjh6vgobam88mlp3f4"
  labels = {
    vmtype     = "nat"
    env        = "prod"
    deployment = "terraform"
  }
}

module "prod_vpc" {
  source     = "../../modules/vpc"
  network_id = "enpjh6vgobam88mlp3f4"

  subnets = {
    "k8s-subnet-a" : {
      zone           = "ru-central1-a"
      v4_cidr_blocks = ["10.10.1.0/24"]
      route_table_id = module.nat_a.route_table_a_id
    }
    "k8s-subnet-b" : {
      zone           = "ru-central1-b"
      v4_cidr_blocks = ["10.10.2.0/24"]
      route_table_id = module.nat_a.route_table_a_id
    }
    "k8s-subnet-c" : {
      zone           = "ru-central1-c"
      v4_cidr_blocks = ["10.10.3.0/24"]
      route_table_id = module.nat_a.route_table_a_id
    }
  }
}

module prod_k8s {
  source  = "../../modules/az_balanced_vms"
  vm_user = "ubuntu"
  vm_name = "k8s-host"
  labels = {
    vmtype     = "k8s"
    env        = "prod"
    deployment = "terraform"
  }
  cores         = 2
  memory        = 16
  hosts_per_net = 2

  nets = {
    "k8s-subnet-a" : {
      zone             = "ru-central1-a"
      subnet_id        = module.prod_vpc.subnet_ids_by_names["k8s-subnet-a"]
      assign_public_ip = false
    }
    "k8s-subnet-b" : {
      zone             = "ru-central1-b",
      subnet_id        = module.prod_vpc.subnet_ids_by_names["k8s-subnet-b"],
      assign_public_ip = false
    }
    "k8s-subnet-c" : {
      zone             = "ru-central1-c",
      subnet_id        = module.prod_vpc.subnet_ids_by_names["k8s-subnet-c"],
      assign_public_ip = false
    }
  }
}

output "disk_ids_by_names" {
  value = module.prod_k8s.disk_ids_by_names
}

output "k8s_fqdns" {
  value = module.prod_k8s.vm_fqdns
}

output "k8s_vms" {
  value = module.prod_k8s.vms
}

output "vpc_subnets" {
  value = module.prod_vpc.vpc_subnets
}

output "vpc_nat_subnets" {
  value = module.prod_vpc_nat.vpc_subnets
}
