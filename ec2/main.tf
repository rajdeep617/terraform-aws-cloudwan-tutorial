data "aws_ami" "amazon_linux" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
}

data "aws_iam_policy" "ssm" {
  name = "AmazonSSMManagedInstanceCore"
}

#To generate random IAM role name
resource "random_integer" "random" {
  min = 1
  max = 100
  keepers = {
    # Generate a new integer each time we switch to a new listener ARN
    listener_arn = var.name_tag
  }
}

resource "aws_instance" "main" {
  count = var.instance_count

  ami                         = var.ami_id == null ? data.aws_ami.amazon_linux.id : var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.instance_count <= length(var.subnet_id) ? var.subnet_id[count.index] : var.subnet_id[0]
  key_name                    = aws_key_pair.ec2.key_name
  iam_instance_profile        = aws_iam_instance_profile.ssm.name
  associate_public_ip_address = var.associate_public_ip_address
  vpc_security_group_ids      = [aws_security_group.ec2.id]

  tags = {
    Name = format("${var.name_tag}-%s", count.index + 1)
  }
}

resource "aws_security_group" "ec2" {
  vpc_id      = var.vpc_id
  description = var.name_tag
  name_prefix = var.name_tag
  lifecycle {
    create_before_destroy = true
  }

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      protocol    = ingress.value.protocol
      to_port     = ingress.value.to_port
      cidr_blocks = ingress.value.cidr_block
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.name_tag
  }
}

# RSA key of size 4096 bits
resource "tls_private_key" "ec2" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2" {
  key_name   = var.name_tag
  public_key = tls_private_key.ec2.public_key_openssh
}

resource "aws_iam_role" "ec2_ssm_role" {
  name               = "${var.name_tag}-${random_integer.random.result}-ec2-ssm-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Name = "${var.name_tag}-ec2-ssm-role"
  }
}

resource "aws_iam_role_policy_attachment" "ec2_cloudwatch_metrics_attachment" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = data.aws_iam_policy.ssm.arn
}

resource "aws_iam_instance_profile" "ssm" {
  name = "${var.name_tag}-${random_integer.random.result}-ssm"
  role = aws_iam_role.ec2_ssm_role.name
}