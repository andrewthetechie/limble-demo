locals {
  provider_versions = yamldecode(file("${get_repo_root()}/aws/shared/providers/providers_config.yaml"))
  env = "prod"
  tfstate_bucket_name_base = "limbledemo-${local.env}-tfstate"
  # add some uniqueness to the bucket name
  tfstate_bucket_name = "${local.tfstate_bucket_name_base}-${lower(md5(local.tfstate_bucket_name_base))}"
  region = "us-east-2"
  tags = {
      managed = "terraform"
      env = local.env
    }
}


# configure the remote state for the whole account 
# use S3 and dynamo for now
remote_state {
  backend = "s3"

  config = {
    encrypt        = true
    bucket         = local.tfstate_bucket_name
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "prod-tf-locks"
  }
}


generate "provider" {
  path = "versions.tf"
  if_exists = "overwrite"
  contents = templatefile("${get_repo_root()}/aws/shared/providers/providers.tpl", 
  {
    region = local.region
    tags = local.tags
    terraform_version = local.provider_versions.terraform_version
    providers = local.provider_versions.providers
  })
}