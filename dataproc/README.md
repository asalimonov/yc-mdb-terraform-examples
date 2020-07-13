# Deployment of Yandex.Cloud Data Proc via Terraform

## Intro

An example of deploying Yandex Data Proc with his  own
Virtual Private Cloud (VPC) and isolated networks. There are:

* Bastion host - virtual machine with white IP address
* Data Proc cluster with master node, 2 data nodes and 3 compute nodes
* Managed ClickHouse cluster in high-available configuration
* 2 object storage buckets for data and jobs/logs
* 2 service accounts for managing of buckets and for Data Proc cluster

## Usage

1. Open terminal and go to environment folder
1. Create a copy of `terraform.tfvars.example` file and rename it to `terraform.tfvars`
1. Open `terraform.tfvars` and specify `yc_cloud_id`, `yc_folder_id`, `yc_oauth_token`
1. [Install Terraform](https://www.terraform.io/intro/getting-started/install.html)
1. Run `terraform init`
1. Run `terraform plan` and check printed diff
1. Run `terraform apply` and follow instructions
1. Turn on NAT on subnet for Data Proc cluster
1. Run `terraform apply` again
1. Find info about the environment in `terraform.tfstate`

## Notes
1. NAT for subnet is available by request to Yandex Cloud Support
1. You can use NAT instance instead of NAT feature. Please ask me if you want it in the example