terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-ssm-parameter.git//?ref=v1.1.0"

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
dependency "db" {
    config_path = "${get_repo_root()}/aws/states/prod/apps/wordpress-demo/db/wp-demo/db"
}


locals {
}


inputs = {
    name = "/prod/wpdemo/db/wp-demo-creds"
    secure_type = true
    value = jsonencode({
        host = dependency.db.outputs.db_instance_endpoint
        port = dependency.db.outputs.db_instance_port
        dbname = dependency.db.outputs.db_instance_name
        user = dependency.db.outputs.db_instance_username
        # hardcoded just for demo purposes
        password = "thisisnotagoodpassword12"
    }) 


}