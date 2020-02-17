# Example of deployment of Yandex.Cloud Managed PostgreSQL 

## Concept

Three evniroments: production, stanging and testing. Each environment has own
Virtual Private Cloud (VPC) with isolated networks from each other.

Each environment can be deployed in diffrenet folders to separate users permissions.
For example, developers can have privileges to redeploy, change configuration,
deploy additional clusters and VMs in testing environment, but only leads and 
duty engineers can deploy and update configuration of nets, clusters, virtual
machines in production environment.


Here are keys features of environments:

### Common

* Random generated 18-symbol password with special chars
* Only private IP addresses
* Different VPC and networks for each environment

### Production

* High available Managed PostgreSQL cluster with 3 nodes in 3 diffrenet zones.
* 100GiB disk size for each host
* 4 cores and 16 GiB of RAM for each host (s2.small)

### Staging

* High available Managed PostgreSQL cluster with 2 nodes in 2 diffrenet zones.
* 50GiB disk size for each host
* 2 cores and 8 GiB of RAM for each host (s2.micro)

### Testing

* Two single node clusters for development testing and QA testing
* 50GiB disk space for each host (cluster)
* 2 burstable cores with 50% guarantee and 4GiB of RAM for each cluster (b2.medium)

## Usage

1. Open terminal and go to environment folder 
1. Create a copy of `terraform.tfvars.example` file and rename it to `terraform.tfvars`
1. Open `terraform.tfvars` and specify `yc_cloud_id`, `yc_folder_id`, `yc_oauth_token`
1. [Install Terraform](https://www.terraform.io/intro/getting-started/install.html)
1. Run `terraform init`
1. Run `terraform plan` and check printed diff.
1. Run `terraform apply` and follow instructions
1. Find username and it's password in `terraform.tfstate`
