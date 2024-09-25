terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-eks.git//?ref=v20.24.2"

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

dependency "dbsg" {
    config_path = "${get_repo_root()}/aws/states/prod/base/security_groups/db"
}

locals {}

inputs = {
  cluster_name    = "prod-cluster"
  cluster_version = "1.30"

  # EKS Addons
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = dependency.vpc.outputs.private_subnets
  # add the db security groups
  cluster_additional_security_group_ids = [dependency.dbsg.outputs.security_group_id]

  eks_managed_node_groups = {
    base = {
      instance_types = ["m6i.large"]

      min_size = 2
      max_size = 5
      desired_size = 2
    }
  }

  enable_cluster_creator_admin_permissions = true

  # in prod, this would be a role that got handed out to people to access
  # just shortcutting it with iam users for demo purposes
  # access_entries = {
  #   iam_user_admin = {
  #     principal_arn = "arn:aws:iam::445567106346:user/andrew"
  #     policy_associations = {
  #       admin = {
  #         policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  #         access_scope = {
  #           type = "cluster"
  #         }
  #       }
  #     }
  #   }
  #   iam_user_ro = {
  #     principal_arn = "arn:aws:iam::445567106346:user/readonly"
  #     policy_associations = {
  #       readonly = {
  #         policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  #         access_scope = {
  #           type = "cluster"
  #         }
  #       }
  #     }
  #   }
  # }

  tags = {
    name = "prod-cluster"
    env = "prod"
  }

}