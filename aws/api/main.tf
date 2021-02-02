resource "aws_instance" "api" {
  ami                         = var.ami
  associate_public_ip_address = "false"

  credit_specification {
    cpu_credits = "unlimited"
  }

  disable_api_termination = "false"
  ebs_optimized           = "true"

  enclave_options {
    enabled = "false"
  }

  get_password_data  = "false"
  hibernation        = "false"
  instance_type      = var.instance_type
  ipv6_address_count = "0"
  key_name           = "example"

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = "1"
    http_tokens                 = "optional"
  }

  monitoring = "false"
  private_ip = format("%s%s", substr(var.subnet, 0, 7), ".10")

  root_block_device {
    delete_on_termination = "true"
    encrypted             = "false"
    throughput            = "0"
    volume_size           = "64"
    volume_type           = "gp2"
  }

  source_dest_check = "true"
  subnet_id         = var.subnet_id

  tags = {
    Name = "${var.name}-api"
  }

  tenancy          = "default"
  user_data_base64 = "IyEvYmluL3NoCgphcHQtZ2V0IGluc3RhbGwgcHl0aG9uLW1pbmltYWw="

  volume_tags = {
    Name = "${var.name}-api"
  }

  vpc_security_group_ids = var.security_groups
}