provider "yandex" {
  version   = "~> 0.29"
  token     = var.yc_oauth_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_main_zone
}

module "prod_vpc" {
  source       = "../../modules/vpc"
  network_name = "prod-network"

  subnets = {
    "default-subnet-a" : {
      zone           = "ru-central1-a"
      v4_cidr_blocks = ["192.168.10.0/24"]
    }
    "default-subnet-b" : {
      zone           = "ru-central1-b"
      v4_cidr_blocks = ["192.168.11.0/24"]
    }
    "default-subnet-c" : {
      zone           = "ru-central1-c"
      v4_cidr_blocks = ["192.168.12.0/24"]
    
  }
}
}

module "prod_tvms" {
  source      = "../../modules/tvms"
  subnet_a_id = module.prod_vpc.subnet_ids_by_names["default-subnet-a"]
  subnet_b_id = module.prod_vpc.subnet_ids_by_names["default-subnet-b"]
  subnet_c_id = module.prod_vpc.subnet_ids_by_names["default-subnet-c"]

  labels  = {
    vmtype = "tvm"
    env = "prod"
    deployment = "terraform"
    }

    vm_user = "ubuntu"
}

    output "vpc_subnets" {
    value = module.prod_vpc.vpc_subnets
    }

    output "vpc_network_id" {
    value = module.prod_vpc.vpc_network_id
    }