variable "name_tag" {
  type        = string
  description = "The value of name tag to used on all resources"
}
variable "instance_count" {
  description = "Number of instances to launch"
  type        = number
  default     = 1
}
variable "ami_id" {
  description = "Ami ID of EC2 instance"
  type        = string
  default     = null
}
variable "instance_type" {
  description = "Ec2 instance type"
  type        = string
  default     = "t3.micro"
}
variable "subnet_id" {
  description = "List of Subnet IDs to launch EC2 instance"
  type        = list(string)
}
variable "associate_public_ip_address" {
  description = "Should attach public IP"
  type        = bool
  default     = false
}
variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}
variable "ingress_rules" {
  description = "Map of CIDR Security group rules"
  type = map(object({
    from_port  = number
    to_port    = number
    protocol   = string
    cidr_block = list(string)
  }))
  default = {
    all = {
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      cidr_block = ["0.0.0.0/0"]
    }
  }
}