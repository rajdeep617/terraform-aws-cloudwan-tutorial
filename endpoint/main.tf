data "aws_region" "main" {}

data "aws_vpc" "main" {
  id = var.vpc_id
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = var.vpc_id
  subnet_ids        = var.subnet_ids
  service_name      = "com.amazonaws.${data.aws_region.main.name}.ssmmessages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.endpoint.id
  ]

  private_dns_enabled = var.ssm_private_dns_enabled
  ip_address_type     = var.ip_address_type
  tags = {
    name = "ssmmessages-endpoint-poc"
  }
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = var.vpc_id
  subnet_ids        = var.subnet_ids
  service_name      = "com.amazonaws.${data.aws_region.main.name}.ssm"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.endpoint.id
  ]

  private_dns_enabled = var.ssm_private_dns_enabled
  ip_address_type     = var.ip_address_type
  tags = {
    Name = "ssm-endpoint-poc"
  }
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = var.vpc_id
  subnet_ids        = var.subnet_ids
  service_name      = "com.amazonaws.${data.aws_region.main.name}.ec2messages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.endpoint.id
  ]

  private_dns_enabled = var.ssm_private_dns_enabled
  ip_address_type     = var.ip_address_type
  tags = {
    Name = "ec2messages-endpoint-poc"
  }
}

resource "aws_security_group" "endpoint" {
  name        = "ssm-endpoint"
  description = "Allow https"
  vpc_id      = var.vpc_id

  ingress {
    description = "TLS from Spokes"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssm-endpoint"
  }
}
###Ref: https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-setting-up-messageAPIs.html
resource "aws_vpc_endpoint_policy" "ec2messages" {
  vpc_endpoint_id = aws_vpc_endpoint.ec2messages.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowRequestsByOrgsIdentitiesToOrgsResources",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "*"
        },
        "Action" : ["ec2messages:AcknowledgeMessage",
          "ec2messages:DeleteMessage",
          "ec2messages:FailMessage",
          "ec2messages:GetEndpoint",
          "ec2messages:GetMessages",
        "ec2messages:SendReply"]
        "Resource" : "*",
      }
    ]
  })
}

resource "aws_vpc_endpoint_policy" "ssmmessages" {
  vpc_endpoint_id = aws_vpc_endpoint.ssmmessages.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowRequestsByOrgsIdentitiesToOrgsResources",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "*"
        },
        "Action" : ["ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        "Resource" : "*",
      }
    ]
  })
}

resource "aws_vpc_endpoint_policy" "ssm" {
  vpc_endpoint_id = aws_vpc_endpoint.ssm.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowRequestsByOrgsIdentitiesToOrgsResources",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "*"
        },
        "Action" : ["ssm:DescribeInstanceProperties",
          "ssm:DescribeDocumentParameters",
          "ssm:ListInstanceAssociations",
          "ssm:RegisterManagedInstance",
          "ssm:UpdateInstanceInformation",
          "ssm:GetManifest",
          "ssm:PutConfigurePackageResult"
        ]
        "Resource" : "*",
      }
    ]
  })
}