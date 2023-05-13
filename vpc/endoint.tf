module "endpoint" {
  count = var.create_vpc_ssm_endpoints ? 1 : 0

  source     = "../endpoint"
  subnet_ids = aws_subnet.private-subnets[*].id
  vpc_id     = aws_vpc.main.id
}
