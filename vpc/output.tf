output "vpc_id" {
  value = aws_vpc.main.id
}
output "private_subnets_ids" {
  value = aws_subnet.private-subnets[*].id
}
output "public_subnets_ids" {
  value = aws_subnet.public-subnets[*].id
}
output "igw_id" {
  value = join("", aws_internet_gateway.main[*].id)
}
output "ngw_ids" {
  value = aws_nat_gateway.main[*].id
}
output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}