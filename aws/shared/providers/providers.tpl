provider "aws" {
  region  = "${region}"
  default_tags{
    tags = {
    %{ for key, value in tags }
      "${key}" = "${value}",
    %{ endfor }
    }
  }
}

terraform {
  backend "s3" {}
  required_version = "${terraform_version}"

  required_providers {
    %{ for provider_name, provider_config in providers }
    ${provider_name} = {
      source  = "${provider_config.source}"
      version = "${provider_config.version}"
    }
    %{ endfor }
  }
}