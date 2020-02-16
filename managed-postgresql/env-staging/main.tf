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
    },
    "staging-subnet-c" : {
      zone           = "ru-central1-c"
      v4_cidr_blocks = ["192.168.12.0/24"]
    }
  }
}

module "managed_pgsql_staging" {

  source       = "../modules/mdb-postgresql"
  cluster_name = "staging"
  network_id   = module.vpc.vpc_network_id
  description  = "Main staging PostgreSQL database"
  labels = {
    env        = "staging",
    deployment = "terraform"
  }
  environment            = "PRODUCTION"
  cfg_resource_preset_id = "s2.micro"
  cfg_disk_size          = 50

  hosts = [
    {
      zone             = "ru-central1-a",
      subnet_id        = module.vpc.subnet_ids_by_names["staging-subnet-a"]
      assign_public_ip = false
    },
    {
      zone             = "ru-central1-b",
      subnet_id        = module.vpc.subnet_ids_by_names["staging-subnet-b"]
      assign_public_ip = false
    }
  ]

}

output "managed_pgsql_staging_cluster_id" {
  value = module.managed_pgsql_staging.cluster_id
}

output "managed_pgsql_staging_cluster_fqdns" {
  value = module.managed_pgsql_staging.cluster_hosts_fqdns
}

output "managed_pgsql_staging_cluster_users" {
  value = module.managed_pgsql_staging.cluster_users
}

output "managed_pgsql_staging_cluster_users_passwords" {
  value = module.managed_pgsql_staging.cluster_users_passwords
}

output "managed_pgsql_staging_cluster_fips" {
  value = module.managed_pgsql_staging.cluster_hosts_fips
}

output "managed_pgsql_staging_cluster_databases" {
  value = module.managed_pgsql_staging.cluster_databases
}
