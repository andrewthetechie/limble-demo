terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-acm.git//?ref=v5.1.0"

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
dependency "zone" {
    config_path = "${get_repo_root()}/aws/states/prod/base/dns/zones/${local.domain_name}"
}


locals {
    domain_name = "limbledemo.herrington.network"
}


inputs = {
    domain_name = local.domain_name
    zone_id = dependency.zone.outputs.route53_zone_zone_id[local.domain_name]
    validation_method = "DNS"
    # get a wildcard too
    subject_alternative_names = [
        "*.${local.domain_name}"
    ]
    wait_for_validation = true
}