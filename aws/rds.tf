resource "aws_db_instance" "db" {
  allocated_storage                     = "10"
  auto_minor_version_upgrade            = "true"
  availability_zone                     = "eu-west-1b"
  backup_retention_period               = "1"
  backup_window                         = "04:29-04:59"
  ca_cert_identifier                    = "rds-ca-2019"
  copy_tags_to_snapshot                 = "false"
  db_subnet_group_name                  = aws_db_subnet_group.sn_group.name
  deletion_protection                   = "false"
  engine                                = "mysql"
  engine_version                        = "5.7"
  iam_database_authentication_enabled   = "false"
  identifier                            = "${var.name}-db-cluster-instance-1"
  instance_class                        = "db.t3.small"
  iops                                  = "0"
  kms_key_id                            = "arn:aws:kms:eu-west-1:409881401509:key/a71bba63-cc1c-4ab8-8eed-f257e2c3ffb6"
  license_model                         = "general-public-license"
  maintenance_window                    = "sat:02:29-sat:02:59"
  max_allocated_storage                 = "0"
  monitoring_interval                   = "0"
  multi_az                              = "false"
  option_group_name                     = "default:mysql-5-7"
  parameter_group_name                  = "default.mysql5.7"
  performance_insights_enabled          = "false"
  performance_insights_retention_period = "0"
  port                                  = "3306"
  publicly_accessible                   = "false"
  storage_encrypted                     = "true"
  storage_type                          = "gp2"
  username                              = var.db_username
  password                              = var.db_password
  vpc_security_group_ids                = [aws_security_group.db.id]
}

resource "aws_db_subnet_group" "sn_group" {
  description = "${var.name}-db-sg"
  name        = "${var.name}-db-sg"
  subnet_ids  = [aws_subnet.sn1a.id, aws_subnet.sn1b.id]
}

