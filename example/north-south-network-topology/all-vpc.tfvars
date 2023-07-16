azs = {
  us-east-1 = ["us-east-1a", "us-east-1b", "us-east-1c"]
  us-east-2 = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

vpc_config = {
  prod = {
    us-east-1 = ["10.11.0.0/16"]
    us-east-2 = ["10.12.0.0/16"]
  }
  dev = {
    us-east-1 = ["10.1.0.0/16"]
    us-east-2 = ["10.2.0.0/16"]
  }
  egress = {
    us-east-1 = ["10.100.0.0/16"]
    us-east-2 = ["10.200.0.0/16"]
  }
}
