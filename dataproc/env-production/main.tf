provider "yandex" {
  version   = "~> 0.29"
  token     = var.yc_oauth_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_main_zone
}

# Need to enable NAT manually (on the page of the network)
module "vpc" {
  source       = "../modules/vpc"
  network_name = "prod-network"

  subnets = {
    "default-subnet-a" : {
      zone           = "ru-central1-a"
      v4_cidr_blocks = ["192.168.20.0/24"]
    }
    "default-subnet-b" : {
      zone           = "ru-central1-b"
      v4_cidr_blocks = ["192.168.21.0/24"]
    }
    "default-subnet-c" : {
      zone           = "ru-central1-c"
      v4_cidr_blocks = ["192.168.22.0/24"]
    }
  }
}

resource "random_string" "jobs_bucket_rnd" {
  length = 8
  special = false
  upper = false
}

resource "random_string" "data_bucket_rnd" {
  length = 8
  special = false
  upper = false
}

resource "yandex_storage_bucket" "dataproc_jobs_bucket" {
  bucket = "dataproc-prod-jobs${random_string.jobs_bucket_rnd.result}"
  acl = "private"
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
}

resource "yandex_storage_bucket" "dataproc_data_bucket" {
  bucket = "dataproc-prod-data${random_string.data_bucket_rnd.result}"
  acl = "private"
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
}

resource "yandex_iam_service_account" "sa" {
  name = "prod-sa"
  description = "Service account"
  folder_id = var.yc_folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.yc_folder_id
  role = "editor"
  member = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
    service_account_id = yandex_iam_service_account.sa.id
    description = "static access key for object storage"
}

resource "yandex_iam_service_account" "dpa" {
  name = "prod-dataproc-agent"
  description = "DataProc service account (agent)"
  folder_id = var.yc_folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "dpa-agent" {
  folder_id = var.yc_folder_id
  role = "mdb.dataproc.agent"
  member = "serviceAccount:${yandex_iam_service_account.dpa.id}"
}

resource "yandex_dataproc_cluster" "dp_prod" {
  name = "dataproc-prod"
  description = "DataProc Production cluster"
  bucket = yandex_storage_bucket.dataproc_jobs_bucket.bucket
  labels = var.default_labels
  service_account_id  = yandex_iam_service_account.dpa.id
  zone_id = "ru-central1-a"

  cluster_config {
    version_id = "1.1"
    hadoop {
        services = ["YARN", "HDFS", "MAPREDUCE", "SPARK", "TEZ", "ZEPPELIN"]
        ssh_public_keys = [file("~/.ssh/id_rsa.pub")]
    }
    subcluster_spec {
      name = "master"
      role = "MASTERNODE"
      hosts_count = 1
      subnet_id = module.vpc.subnet_ids_by_names["default-subnet-a"]
      resources {
        resource_preset_id = "b2.medium"
        disk_size = 80
        disk_type_id = "network-hdd"
      }
    }
    subcluster_spec {
      name = "datanodes"
      role = "DATANODE"
      hosts_count = 2
      subnet_id = module.vpc.subnet_ids_by_names["default-subnet-a"]
      resources {
        resource_preset_id = "b2.medium"
        disk_size = 512
        disk_type_id = "network-ssd"
      }
    }
    subcluster_spec {
      name = "computenodes"
      role = "COMPUTENODE"
      hosts_count = 3
      subnet_id = module.vpc.subnet_ids_by_names["default-subnet-a"]
      resources {
        resource_preset_id = "s2.small"
        disk_size = 100
        disk_type_id = "network-ssd"
      }
    }
  }

}

resource "yandex_compute_instance" "bastion" {
  name        = "bastion"
  description = "Bastion host"

  labels = var.default_labels

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
    subnet_id = module.vpc.subnet_ids_by_names["default-subnet-a"]
    nat       = true
  }

  metadata = {
    ssh-keys = "${var.vm_user}:${file("~/.ssh/id_rsa.pub")}"
  }
}

module "managed_clickhouse_prod" {

  source       = "../modules/mdb-clickhouse"
  cluster_name = "prod-stats"
  network_id   = module.vpc.vpc_network_id
  description  = "ClickHouse production database"
  labels = var.default_labels
  environment = "PRODUCTION"

  resource_preset_id = "s2.micro"
  disk_size          = 500 #GiB
  disk_type_id       = "network-ssd"

  zk_resource_preset_id = "s2.micro"
  zk_disk_size          = 10 #GiB
  zk_disk_type_id       = "network-ssd"

  access_web_sql = true
  access_data_lens = true

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
