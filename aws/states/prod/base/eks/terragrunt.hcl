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

  eks_managed_node_groups = {
    base = {
      instance_types = ["m6i.large"]

      min_size = 2
      max_size = 5
      desired_size = 2
    }
  }

  tags = {
    name = "prod-cluster"
    env = "prod"
  }

}