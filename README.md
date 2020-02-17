# Yandex.Cloud MDB Terraform modules and examples

Set of examples how to deploy production, staging and testing environments with
using Terraform.

## Supported managed services

* [Managed Service for PostgreSQL](https://cloud.yandex.ru/services/managed-postgresql)
* [Managed Service for MySQL](https://cloud.yandex.ru/services/managed-mysql)
* [Managed Service for ClickHouse](https://cloud.yandex.ru/services/managed-clickhouse)
* [Managed Service for MongoDB](https://cloud.yandex.ru/services/managed-mongodb)
* [Managed Service for Redis](https://cloud.yandex.ru/services/managed-redis)

Each root Terraform module doesn't have dependencies but the following modules
are recommended for using:

* [yandex_vpc_network](https://www.terraform.io/docs/providers/yandex/d/datasource_vpc_network.html)
* [yandex_vpc_subnet](https://www.terraform.io/docs/providers/yandex/d/datasource_vpc_subnet.html)

## Terraform versions

Terraform 0.12. Pin module version to `~> 0.29`.