terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-vpc.git//?ref=v5.13.0"

  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()

    # could use terragrunt to load a lot of this config from common files like the AZs 
    arguments = [
    ]
  }
}

include "remote_state" {
    path = find_in_parent_folders("prod.hcl")
    expose = true
}


locals {
    name = "limble-example"
    region = "us-east-2"
    vpc_cidr = "10.10.0.0/16"
    azs = [for az in ["a", "b", "c"]: "${local.region}${az}"]
}


inputs = {
    name = local.name
    region = local.region
    cidr = local.vpc_cidr

    azs = local.azs
    public_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
    private_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 3)]
    database_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 6)]
    create_database_subnet_group = true

    enable_nat_gateway = true
    single_nat_gateway = true

    # tag subnets for k8s elbs
    public_subnet_tags = {
        "kubernetes.io/role/elb" = 1
    }

    private_subnet_tags = {
        "kubernetes.io/role/internal-elb" = 1
    }

    # in prod, use terraform to load default tags and setup default tags on all resources
    tags = {
        name = local.name
    }
}