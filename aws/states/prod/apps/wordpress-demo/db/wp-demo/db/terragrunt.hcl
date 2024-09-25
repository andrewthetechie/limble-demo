terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-rds.git//?ref=v6.9.0"

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

dependency "db_security_group" {
    config_path = "${get_repo_root()}/aws/states/prod/base/security_groups/db"
}


locals {
}


inputs = {
    # in prod, we'd want to build this identifer to be more unique and easily identifiable.
    # tagging would also be useful to identify db -> service mappings
    identifier = "wordpressdemodb"

    # just set defaults for this example
    create_db_option_group    = false
    create_db_parameter_group = false

    engine               = "mysql"
    engine_version       = "8.0"
    family               = "mysql8.0"
    major_engine_version = "8.0"
    instance_class       = "db.t4g.large"

    # this is a compromise for now to get a demo up and running
    # in a real prod, use the master password management and then write a separate module that
    # creates a new user+password and stores it in the secrets store
    # the downside of this is that password clearly here in the repo + the password shows up in tf state
    # for a demo, with the DB only available inside the VPC, this is an acceptable compromise
    manage_master_user_password = false
    password = "thisisnotagoodpassword12"

    allocated_storage = 20

    # in prod, I'd probably move creating service users to a separate module and use this users as the platform admin user and not share its password
    # its easier to expire/rotate passwords not created by the root of the module
    db_name  = "wordpressDemo"
    username = "wpdemo"
    port     = 3306

    db_subnet_group_name   = dependency.vpc.outputs.database_subnet_group
    vpc_security_group_ids = [dependency.db_security_group.outputs.security_group_id]

    maintenance_window = "Mon:00:00-Mon:03:00"
    backup_window      = "03:00-06:00"

    backup_retention_period = 0

}