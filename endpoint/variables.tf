variable "vpc_id" {
  type = string
}
variable "subnet_ids" {
  type = list(string)
}
variable "private_dns_enabled" {
  type    = bool
  default = true
}
variable "ip_address_type" {
  type    = string
  default = "ipv4"
}
variable "ssm_private_dns_enabled" {
  type    = bool
  default = true
}