output "key_name" {
  value = aws_key_pair.ec2.key_name
}
output "ec2_private_key" {
  value = tls_private_key.ec2.private_key_pem
}