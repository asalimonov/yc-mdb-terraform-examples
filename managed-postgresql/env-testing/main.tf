provider "yandex" {
  version   = "~> 0.29"
  token     = var.yc_oauth_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_main_zone
}

module "vpc" {
  source       = "../modules/vpc"
  network_name = "testing-network"

  subnets = {
    "testing-subnet-a" : {
      zone           = "ru-central1-a"
      v4_cidr_blocks = ["192.168.10.0/24"]
    }
    "testing-subnet-b" : {
      zone           = "ru-central1-b"
      v4_cidr_blocks = ["192.168.11.0/24"]
    },
    "testing-subnet-c" : {
      zone           = "ru-central1-c"
      v4_cidr_blocks = ["192.168.12.0/24"]
    }
  }
}

module "managed_pgsql_dev_testing" {

  source       = "../modules/mdb-postgresql"
  cluster_name = "dev_testing"
  network_id   = module.vpc.vpc_network_id
  description  = "Dev testing PostgreSQL database"
  labels = {
    env        = "testing",
    deployment = "terraform"
  }
  environment            = "PRESTABLE"
  cfg_resource_preset_id = "b2.medium"
  cfg_disk_size          = 50

  hosts = [
    {
      zone             = "ru-central1-a",
      subnet_id        = module.vpc.subnet_ids_by_names["testing-subnet-a"]
      assign_public_ip = false
    }
  ]

}

module "managed_pgsql_qa_testing" {

  source       = "../modules/mdb-postgresql"
  cluster_name = "qa_testing"
  network_id   = module.vpc.vpc_network_id
  description  = "QA testing PostgreSQL database"
  labels = {
    env        = "testing",
    deployment = "terraform"
  }
  environment            = "PRESTABLE"
  cfg_resource_preset_id = "b2.medium"
  cfg_disk_size          = 50

  hosts = [
    {
      zone             = "ru-central1-a",
      subnet_id        = module.vpc.subnet_ids_by_names["testing-subnet-a"]
      assign_public_ip = false
    }
  ]

}

output "managed_pgsql_dev_testing_cluster_id" {
  value = module.managed_pgsql_dev_testing.cluster_id
}

output "managed_pgsql_dev_testing_cluster_fqdns" {
  value = module.managed_pgsql_dev_testing.cluster_hosts_fqdns
}

output "managed_pgsql_dev_testing_cluster_users" {
  value = module.managed_pgsql_dev_testing.cluster_users
}

output "managed_pgsql_dev_testing_cluster_users_passwords" {
  value = module.managed_pgsql_dev_testing.cluster_users_passwords
}

output "managed_pgsql_dev_testing_cluster_fips" {
  value = module.managed_pgsql_dev_testing.cluster_hosts_fips
}

output "managed_pgsql_dev_testing_cluster_databases" {
  value = module.managed_pgsql_dev_testing.cluster_databases
}

output "managed_pgsql_qa_testing_cluster_id" {
  value = module.managed_pgsql_qa_testing.cluster_id
}

output "managed_pgsql_qa_testing_cluster_fqdns" {
  value = module.managed_pgsql_qa_testing.cluster_hosts_fqdns
}

output "managed_pgsql_qa_testing_cluster_users" {
  value = module.managed_pgsql_qa_testing.cluster_users
}

output "managed_pgsql_qa_testing_cluster_users_passwords" {
  value = module.managed_pgsql_qa_testing.cluster_users_passwords
}

output "managed_pgsql_qa_testing_cluster_fips" {
  value = module.managed_pgsql_qa_testing.cluster_hosts_fips
}

output "managed_pgsql_qa_testing_cluster_databases" {
  value = module.managed_pgsql_qa_testing.cluster_databases
}
