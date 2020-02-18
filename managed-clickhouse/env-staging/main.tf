provider "yandex" {
  version   = "~> 0.29"
  token     = var.yc_oauth_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_main_zone
}

module "vpc" {
  source       = "../modules/vpc"
  network_name = "staging-network"

  subnets = {
    "staging-subnet-a" : {
      zone           = "ru-central1-a"
      v4_cidr_blocks = ["192.168.10.0/24"]
    }
    "staging-subnet-b" : {
      zone           = "ru-central1-b"
      v4_cidr_blocks = ["192.168.11.0/24"]
    }
    "staging-subnet-c" : {
      zone           = "ru-central1-c"
      v4_cidr_blocks = ["192.168.12.0/24"]
    }
  }
}

module "managed_clickhouse_staging" {

  source       = "../modules/mdb-clickhouse"
  cluster_name = "staging"
  network_id   = module.vpc.vpc_network_id
  description  = "Main staging ClickHouse database"
  labels = {
    env        = "staging"
    deployment = "terraform"
  }
  environment = "PRODUCTION"

  resource_preset_id = "s2.micro"
  disk_size          = 50 #GiB
  disk_type_id       = "network-ssd"

  zk_resource_preset_id = "s2.micro"
  zk_disk_size          = 10 #GiB
  zk_disk_type_id       = "network-ssd"

  hosts = [
    {
      zone             = "ru-central1-a",
      subnet_id        = module.vpc.subnet_ids_by_names["staging-subnet-a"]
      assign_public_ip = false
      shard_name       = "shard1"
    },
    {
      zone             = "ru-central1-b",
      subnet_id        = module.vpc.subnet_ids_by_names["staging-subnet-b"]
      assign_public_ip = false
      shard_name       = "shard1"
    }
  ]

  zk_hosts = [
    {
      zone      = "ru-central1-a",
      subnet_id = module.vpc.subnet_ids_by_names["staging-subnet-a"]
    },
    {
      zone      = "ru-central1-b",
      subnet_id = module.vpc.subnet_ids_by_names["staging-subnet-b"]
    },
    {
      zone      = "ru-central1-c",
      subnet_id = module.vpc.subnet_ids_by_names["staging-subnet-c"]
    }
  ]

}

output "managed_clickhouse_staging_cluster_id" {
  value = module.managed_clickhouse_staging.cluster_id
}

output "managed_clickhouse_staging_cluster_fqdns" {
  value = module.managed_clickhouse_staging.cluster_hosts_fqdns
}

output "managed_clickhouse_staging_cluster_users" {
  value = module.managed_clickhouse_staging.cluster_users
}

output "managed_clickhouse_staging_cluster_users_passwords" {
  value     = module.managed_clickhouse_staging.cluster_users_passwords
  sensitive = true
}

output "managed_clickhouse_staging_cluster_fips" {
  value = module.managed_clickhouse_staging.cluster_hosts_fips
}

output "managed_clickhouse_staging_cluster_databases" {
  value = module.managed_clickhouse_staging.cluster_databases
}
