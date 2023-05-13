terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

locals {
  vpc_network_bit         = split("/", var.vpc_cidr)[1]
  subnet_network_bit      = local.vpc_network_bit == "24" ? 4 : 8
  tgw_subnet_network_bit  = 28 - local.vpc_network_bit
  public_subnet_count     = var.create_public_subnets ? length(var.azs) : 0
  private_subnet_count    = var.create_private_subnets ? length(var.azs) : 0
  tgw_subnet_count        = var.create_tgw_subnets ? length(var.azs) : 0
  private_subnet_rt_count = var.create_private_subnets || (var.create_tgw_subnets && !var.create_private_subnets) ? (var.shared_ngw ? 1 : length(var.azs)) : 0
  public_subnet_rt_count  = var.create_public_subnets ? 1 : 0
  tgw_subnet_rt_count     = var.create_tgw_subnets && var.create_nat_gateway ? 1 : 0
  create_igw              = var.create_public_subnets && var.create_internet_gateway ? 1 : 0
  ngw_count               = var.create_public_subnets && var.create_nat_gateway ? (var.shared_ngw ? 1 : length(var.azs)) : 0
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = var.instance_tenancy
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = {
    Name = "${var.name_tag}-vpc"
  }
}

############ Public Subnet Configuration ##############################

resource "aws_internet_gateway" "main" {
  count = local.create_igw

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name_tag}-igw"
  }
}

resource "aws_subnet" "public-subnets" {
  count = local.public_subnet_count

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, local.subnet_network_bit, count.index + (2 * length(var.azs)) + 1)
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = format("${var.name_tag}-public-subnet-%s", count.index + 1)
  }
}

resource "aws_route_table" "public-rt" {
  count = local.public_subnet_rt_count

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name_tag}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count = local.public_subnet_count

  subnet_id      = aws_subnet.public-subnets[count.index].id
  route_table_id = aws_route_table.public-rt[0].id
}

resource "aws_route" "igw" {
  count = local.public_subnet_rt_count

  route_table_id         = aws_route_table.public-rt[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main[0].id

  timeouts {
    create = "5m"
  }
}

############ Private Subnet Configuration ##############################

resource "aws_subnet" "private-subnets" {
  count = local.private_subnet_count

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, local.subnet_network_bit, count.index + length(var.azs) + 1)
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = format("${var.name_tag}-private-subnet-%s", count.index + 1)
  }
}

resource "aws_route_table" "private-rt" {
  count = local.private_subnet_rt_count

  vpc_id = aws_vpc.main.id

  tags = {
    Name = format("${var.name_tag}-private-rt-%s", count.index + 1)
  }
}

resource "aws_route_table_association" "private" {
  count = local.private_subnet_count

  subnet_id      = aws_subnet.private-subnets[count.index].id
  route_table_id = local.private_subnet_count == local.private_subnet_rt_count ? aws_route_table.private-rt[count.index].id : aws_route_table.private-rt[0].id
}


##NGW Configuration
resource "aws_nat_gateway" "main" {
  count = local.ngw_count

  allocation_id = aws_eip.ngw[count.index].id
  subnet_id     = aws_subnet.public-subnets[count.index].id

  tags = {
    Name = format("${var.name_tag}-nat-gateway-%s", count.index + 1)
  }
}

resource "aws_eip" "ngw" {
  count = local.ngw_count

  vpc = true

  tags = {
    Name = format("${var.name_tag}-nat-eip-%s", count.index + 1)
  }
}

resource "aws_route" "ngw" {
  count = local.ngw_count

  route_table_id         = aws_route_table.private-rt[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.shared_ngw ? aws_nat_gateway.main[0].id : aws_nat_gateway.main[count.index].id

  timeouts {
    create = "5m"
  }
}

############ TGW Subnet Configuration ##############################

resource "aws_subnet" "tgw-subnets" {
  count = local.tgw_subnet_count

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, local.tgw_subnet_network_bit, count.index)
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = format("${var.name_tag}-tgw-subnet-%s", count.index + 1)
  }
}

resource "aws_route_table_association" "tgw" {
  count = local.tgw_subnet_count

  subnet_id      = aws_subnet.tgw-subnets[count.index].id
  route_table_id = local.private_subnet_count == local.private_subnet_rt_count ? aws_route_table.private-rt[count.index].id : aws_route_table.private-rt[0].id
}