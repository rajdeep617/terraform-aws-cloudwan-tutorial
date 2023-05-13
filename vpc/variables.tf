variable "name_tag" {
  type        = string
  description = "The value of name tag to used on all resources"
}
variable "vpc_cidr" {
  type        = string
  description = "IPv4 CIDR for VPC"
}
variable "azs" {
  description = "List of availability zones names"
  type        = list(string)
}
variable "enable_dns_hostnames" {
  type        = bool
  description = "Should enable DNS hostname"
  default     = true
}
variable "enable_dns_support" {
  type        = bool
  description = "Should enable DNS support"
  default     = true
}
variable "instance_tenancy" {
  description = "Instances tenancy to launch into the VPC"
  type        = string
  default     = "default"
}
variable "create_tgw_subnets" {
  description = "Should create Transit Gateway subnets"
  type        = bool
  default     = false
}
variable "create_public_subnets" {
  description = "Should create public subnets"
  type        = bool
  default     = false
}
variable "create_private_subnets" {
  description = "Should create private subnets"
  type        = bool
  default     = false
}
variable "create_internet_gateway" {
  description = "Should Create Internet Gateway"
  type        = bool
  default     = false
}
variable "create_nat_gateway" {
  description = "Should Create Nat Gateway"
  type        = bool
  default     = false
}
variable "shared_ngw" {
  description = "Should create a shared NAT Gateway"
  type        = bool
  default     = true
}
variable "create_ec2" {
  description = "Should create EC2 instance"
  type        = bool
  default     = false
}
variable "create_vpc_ssm_endpoints" {
  description = "Should create ssm vpc endpoints"
  type        = bool
  default     = false
}
