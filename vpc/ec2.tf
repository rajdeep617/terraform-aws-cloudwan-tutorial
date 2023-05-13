module "ec2" {
  count = var.create_ec2 ? 1 : 0

  source    = "../ec2"
  name_tag  = var.name_tag
  subnet_id = aws_subnet.private-subnets[*].id
  vpc_id    = aws_vpc.main.id
}
