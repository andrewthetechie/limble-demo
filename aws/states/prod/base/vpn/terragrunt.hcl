terraform {
  source = "git::git@github.com:babicamir/terraform-aws-vpn-client.git//?ref=v1.0.0"

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
    organization_name      = "limble"
    project-name           = "demo"
    environment            = "prod"
    # Network information
    vpc_id                 = dependency.vpc.outputs.vpc_id
    subnet_id              = dependency.vpc.outputs.private_subnets[0]
    client_cidr_block      = "172.0.0.0/22"
    # VPN config options
    split_tunnel           = "true" # or false
    vpn_inactive_period = "300" # seconds
    session_timeout_hours  = "8"
    logs_retention_in_days = "7"
    # List of users to be created
    aws-vpn-client-list    = ["root", "user-1", "user2"] #Do not delete "root" user!
}