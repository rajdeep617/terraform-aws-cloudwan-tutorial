variable "azs" {
  type = map(list(string))
}

variable "vpc_config" {
  type = map(any)
}