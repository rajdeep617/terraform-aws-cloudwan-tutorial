terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

locals {
  us_east_1_config = flatten([for env, value in var.vpc_config :
    flatten([for region, cidrs in value :
      [for cidr in cidrs :
        { "env"    = env
          "region" = region
        "cidr" = cidr }
        if region == "us-east-1"
    ]])
  ])
  us_east_2_config = flatten([for env, value in var.vpc_config :
    flatten([for region, cidrs in value :
      [for cidr in cidrs :
        { "env"    = env
          "region" = region
        "cidr" = cidr }
        if region == "us-east-2"
    ]])
  ])
}

provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
}

provider "aws" {
  region = "us-east-2"
  alias  = "us-east-2"
}

module "uses1-vpc" {
  for_each = { for region, value in local.us_east_1_config : region => value }
  providers = {
    aws = aws.us-east-1
  }
  source                   = "../../vpc"
  azs                      = var.azs[each.value.region]
  vpc_cidr                 = each.value.cidr
  create_private_subnets   = true
  create_tgw_subnets       = true
  create_nat_gateway       = each.value.env == "egress" ? true : false
  create_public_subnets    = each.value.env == "egress" ? true : false
  create_internet_gateway  = each.value.env == "egress" ? true : false
  create_vpc_ssm_endpoints = each.value.env == "egress" ? false : true
  create_ec2               = each.value.env == "egress" ? false : true
  name_tag                 = each.value.env
}

module "uses2-vpc" {
  for_each = { for region, value in local.us_east_2_config : region => value }
  providers = {
    aws = aws.us-east-2
  }
  source                   = "../../vpc"
  azs                      = var.azs[each.value.region]
  vpc_cidr                 = each.value.cidr
  create_private_subnets   = true
  create_tgw_subnets       = true
  create_nat_gateway       = each.value.env == "egress" ? true : false
  create_public_subnets    = each.value.env == "egress" ? true : false
  create_internet_gateway  = each.value.env == "egress" ? true : false
  create_vpc_ssm_endpoints = each.value.env == "egress" ? false : true
  create_ec2               = each.value.env == "egress" ? false : true
  name_tag                 = each.value.env
}

