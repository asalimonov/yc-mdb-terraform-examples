variable "network_id" {
  type = string
}

variable "cluster_name" {
  type        = string
  description = "Unique for the cloud name of a cluster"
}

variable "description" {
  type    = string
  default = null
}

variable "environment" {
  type        = string
  default     = "PRODUCTION"
  description = "PRODUCTION or PRESTABLE. Prestable gets updates before production environment"
}


variable "resource_preset_id" {
  type        = string
  default     = "s2.small"
  description = "Id of a resource preset which means count of vCPUs and amount of RAM per host"
}

variable "disk_size" {
  type        = number
  default     = 100
  description = "Disk size in GiB"
}

variable "disk_type_id" {
  type        = string
  default     = "network-ssd"
  description = "Disk type: 'network-ssd', 'network-hdd', 'local-ssd'"
}

variable "database_version" {
  type        = string
  default     = "19.14"
  description = "Version of ClickHouse"
}

variable "labels" {
  type = "map"
  default = {
    deployment = "terraform"
  }
}

variable "backup_window_start_hours" {
  type        = number
  default     = 0
  description = "The hour at which backup will be started"
}

variable "backup_window_start_minutes" {
  type        = number
  default     = 0
  description = "The minutes at which backup will be started"
}

variable "users" {
  type = list(object(
    {
      name     = string
      password = string
    }
  ))
  default = [
    {
      name     = "user1"
      password = ""
    }
  ]
}

variable "user_permissions" {
  type = map(list(object(
    {
      database_name = string
    }
  )))
  default = {
    "user1" : [
      {
        database_name = "db1"
      }
    ]
  }
}

variable "databases" {
  type = list(object({
    name = string
  }))
  default = [{
    name = "db1"
  }]
}

variable "hosts" {
  type = list(object({
    zone             = string
    subnet_id        = string
    assign_public_ip = bool
    shard_name       = string
  }))
  description = "Parameters of hosts: zone - name of VPC zone, subnet_id - ID of a subnet"
}

variable "zk_hosts" {
  type = list(object({
    zone      = string
    subnet_id = string
  }))
  default     = []
  description = "Parameters of hosts: zone - name of VPC zone, subnet_id - ID of a subnet"
}


variable "zk_resource_preset_id" {
  type    = "string"
  default = "s2.micro"
}

variable "zk_disk_type_id" {
  type    = "string"
  default = "network-hdd"
}

variable "zk_disk_size" {
  type        = number
  default     = 10
  description = "Disk size in GiB"
}


variable "access_web_sql" {
  type    = bool
  default = false
}

variable "access_data_lens" {
  type    = bool
  default = false
}

resource "random_password" "pwd" {
  length           = 18
  special          = true
  override_special = "_!@"
}

resource "yandex_mdb_clickhouse_cluster" "managed_clickhouse" {
  name        = var.cluster_name
  network_id  = var.network_id
  description = var.description
  labels      = var.labels
  environment = var.environment
  version     = var.database_version

  clickhouse {
    resources {
      resource_preset_id = var.resource_preset_id
      disk_size          = var.disk_size
      disk_type_id       = var.disk_type_id
    }
  }

  zookeeper {
    resources {
      resource_preset_id = var.zk_resource_preset_id
      disk_type_id       = var.zk_disk_type_id
      disk_size          = var.zk_disk_size
    }
  }

  dynamic "user" {
    for_each = var.users
    content {
      name     = user.value.name
      password = user.value.password == "" || user.value.password == null ? random_password.pwd.result : user.value.password

      dynamic "permission" {
        for_each = var.user_permissions[user.value.name]
        content {
          database_name = permission.value.database_name
        }
      }
    }
  }

  dynamic "database" {
    for_each = var.databases
    content {
      name = database.value.name
    }
  }

  dynamic "host" {
    for_each = var.hosts
    content {
      zone             = host.value.zone
      subnet_id        = host.value.subnet_id
      type             = "CLICKHOUSE"
      assign_public_ip = host.value.assign_public_ip
      shard_name       = host.value.shard_name == "" || host.value.shard_name == null ? "shard1" : host.value.shard_name
    }
  }

  dynamic "host" {
    for_each = var.zk_hosts
    content {
      zone      = host.value.zone
      subnet_id = host.value.subnet_id
      type      = "ZOOKEEPER"
    }
  }

  backup_window_start {
    hours   = var.backup_window_start_hours
    minutes = var.backup_window_start_minutes
  }

  access {
    data_lens = var.access_data_lens
    web_sql   = var.access_web_sql
  }
}
