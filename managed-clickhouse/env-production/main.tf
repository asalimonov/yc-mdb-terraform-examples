provider "yandex" {
  version   = "~> 0.29"
  token     = var.yc_oauth_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_main_zone
}

module "vpc" {
  source       = "../modules/vpc"
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

locals {
  default_shard_name = "shard1"
}

module "managed_clickhouse_prod" {

  source       = "../modules/mdb-clickhouse"
  cluster_name = "prod"
  network_id   = module.vpc.vpc_network_id
  description  = "Main production ClickHouse database"
  labels = {
    env        = "prod"
    deployment = "terraform"
  }
  environment = "PRODUCTION"

  resource_preset_id = "s2.small"
  disk_size          = 500 #GiB
  disk_type_id       = "network-ssd"

  zk_resource_preset_id = "s2.micro"
  zk_disk_size          = 10 #GiB
  zk_disk_type_id       = "network-ssd"

  hosts = [
    {
      zone             = "ru-central1-a",
      subnet_id        = module.vpc.subnet_ids_by_names["default-subnet-a"]
      assign_public_ip = false
      shard_name       = "shard1"
    },
    {
      zone             = "ru-central1-b",
      subnet_id        = module.vpc.subnet_ids_by_names["default-subnet-b"]
      assign_public_ip = false
      shard_name       = "shard1"
    }
  ]

  zk_hosts = [
    {
      zone      = "ru-central1-a",
      subnet_id = module.vpc.subnet_ids_by_names["default-subnet-a"]
    },
    {
      zone      = "ru-central1-b",
      subnet_id = module.vpc.subnet_ids_by_names["default-subnet-b"]
    },
    {
      zone      = "ru-central1-c",
      subnet_id = module.vpc.subnet_ids_by_names["default-subnet-c"]
    }
  ]

}

output "managed_clickhouse_prod_cluster_id" {
  value = module.managed_clickhouse_prod.cluster_id
}

output "managed_clickhouse_prod_cluster_fqdns" {
  value = module.managed_clickhouse_prod.cluster_hosts_fqdns
}

output "managed_clickhouse_prod_cluster_users" {
  value = module.managed_clickhouse_prod.cluster_users
}

output "managed_clickhouse_prod_cluster_users_passwords" {
  value     = module.managed_clickhouse_prod.cluster_users_passwords
  sensitive = true
}

output "managed_clickhouse_prod_cluster_fips" {
  value = module.managed_clickhouse_prod.cluster_hosts_fips
}

output "managed_clickhouse_prod_cluster_databases" {
  value = module.managed_clickhouse_prod.cluster_databases
}
