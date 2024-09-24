terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-security-group.git//?ref=v5.2.0"

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


# use terragrunt dependency to load the VPC state info
dependency "vpc" {
    config_path = "${get_repo_root()}/aws/states/prod/base/vpc"
}

locals {

}


inputs = {
    name = "MYSQL"
    description = "SG for Mysql"
    vpc_id      = dependency.vpc.outputs.vpc_id

    # ingress with the whole vpc for now. In prod, we'd want to lock this down to
    # ingress only with k8s
    ingress_with_cidr_blocks = [
    {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        description = "MySQL access from within VPC"
        cidr_blocks = dependency.vpc.outputs.vpc_cidr_block
    },
    ]
}