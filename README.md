# Yandex.Cloud MDB Terraform modules and examples

Set of examples how to deploy production, staging and testing environments with
using Terraform.

# These Managed services are supported:

* [Managed Service for PostgreSQL]()
* [Managed Service for MySQL]()
* [Managed Service for ClickHouse]()
* [Managed Service for MongoDB]()
* [Managed Service for Redis]()

Each root Terraform module doesn't have dependencies but the following modules
are recommended for using:

* [yandex_vpc_network](https://www.terraform.io/docs/providers/yandex/d/datasource_vpc_network.html)
* [yandex_vpc_subnet](https://www.terraform.io/docs/providers/yandex/d/datasource_vpc_subnet.html)

## Terraform versions

Terraform 0.12. Pin module version to `~> 0.29`.


