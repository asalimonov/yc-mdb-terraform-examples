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
    }
    "testing-subnet-c" : {
      zone           = "ru-central1-c"
      v4_cidr_blocks = ["192.168.12.0/24"]
    }
  }
}

module "managed_mongdb_dev_testing" {

  source       = "../modules/mdb-mongodb"
  cluster_name = "dev_testing_mongodb"
  network_id   = module.vpc.vpc_network_id
  description  = "Dev testing MongoDB database"
  labels = {
    env        = "testing"
    deployment = "terraform"
  }
  environment = "PRESTABLE"

  resource_preset_id = "b2.medium"
  disk_size          = 50 #GiB

  hosts = [
    {
      zone             = "ru-central1-a",
      subnet_id        = module.vpc.subnet_ids_by_names["testing-subnet-a"]
      assign_public_ip = false
    }
  ]

}

output "managed_mongdb_dev_testing_cluster_id" {
  value = module.managed_mongdb_dev_testing.cluster_id
}

output "managed_mongdb_dev_testing_cluster_fqdns" {
  value = module.managed_mongdb_dev_testing.cluster_hosts_fqdns
}

output "managed_mongdb_dev_testing_cluster_users" {
  value = module.managed_mongdb_dev_testing.cluster_users
}

output "managed_mongdb_dev_testing_cluster_users_passwords" {
  value     = module.managed_mongdb_dev_testing.cluster_users_passwords
  sensitive = true
}

output "managed_mongdb_dev_testing_cluster_fips" {
  value = module.managed_mongdb_dev_testing.cluster_hosts_fips
}

output "managed_mongdb_dev_testing_cluster_databases" {
  value = module.managed_mongdb_dev_testing.cluster_databases
}

module "managed_mongdb_qa_testing" {

  source       = "../modules/mdb-mongodb"
  cluster_name = "qa_testing_mongodb"
  network_id   = module.vpc.vpc_network_id
  description  = "QA testing MongoDB database"
  labels = {
    env        = "testing"
    deployment = "terraform"
  }
  environment = "PRESTABLE"

  resource_preset_id = "b2.medium"
  disk_size          = 50 #GiB

  hosts = [
    {
      zone             = "ru-central1-a",
      subnet_id        = module.vpc.subnet_ids_by_names["testing-subnet-a"]
      assign_public_ip = false
    }
  ]

}

output "managed_mongdb_qa_testing_cluster_id" {
  value = module.managed_mongdb_qa_testing.cluster_id
}

output "managed_mongdb_qa_testing_cluster_fqdns" {
  value = module.managed_mongdb_qa_testing.cluster_hosts_fqdns
}

output "managed_mongdb_qa_testing_cluster_users" {
  value = module.managed_mongdb_qa_testing.cluster_users
}

output "managed_mongdb_qa_testing_cluster_users_passwords" {
  value     = module.managed_mongdb_qa_testing.cluster_users_passwords
  sensitive = true
}

output "managed_mongdb_qa_testing_cluster_fips" {
  value = module.managed_mongdb_qa_testing.cluster_hosts_fips
}

output "managed_mongdb_qa_testing_cluster_databases" {
  value = module.managed_mongdb_qa_testing.cluster_databases
}
