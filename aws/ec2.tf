module "api" {
  source          = "./api"
  name            = var.name
  subnet          = aws_subnet.sn1a.cidr_block
  subnet_id       = aws_subnet.sn1a.id
  ami             = "ami-089cc16f7f08c4457"
  instance_type   = "t2.small"
  vpc             = aws_vpc.vpc.id
  security_groups = [aws_security_group.all.id]
}

module "web" {
  source          = "./web"
  name            = var.name
  subnet          = aws_subnet.sn1b.cidr_block
  subnet_id       = aws_subnet.sn1b.id
  ami             = "ami-089cc16f7f08c4457"
  instance_type   = "t2.micro"
  vpc             = aws_vpc.vpc.id
  security_groups = [aws_security_group.all.id]
}

###
# Security Groups
###

resource "aws_security_group" "all" {
  description = "${var.name}-sg-all"
  name        = "${var.name}-sg-all"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_security_group" "db" {
  description = "${var.name}-sg-db"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    self        = "false"
    to_port     = "0"
  }

  ingress {
    cidr_blocks     = ["10.10.0.0/16"]
    from_port       = "3306"
    protocol        = "tcp"
    security_groups = [aws_security_group.all.id]
    self            = "false"
    to_port         = "3306"
  }

  name   = "${var.name}-sg-db"
  vpc_id = aws_vpc.vpc.id
}

resource "aws_security_group" "front" {
  description = "${var.name}-sg-lb-front"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    self        = "false"
    to_port     = "0"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "443"
    protocol    = "tcp"
    self        = "false"
    to_port     = "443"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "80"
    protocol    = "tcp"
    self        = "false"
    to_port     = "80"
  }

  name   = "${var.name}-sg-lb-front"
  vpc_id = aws_vpc.vpc.id
}

resource "aws_security_group" "redis" {
  description = "${var.name}-sg-redis"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    self        = "false"
    to_port     = "0"
  }

  ingress {
    from_port       = "6379"
    protocol        = "tcp"
    security_groups = [aws_security_group.all.id]
    self            = "false"
    to_port         = "6379"
  }

  name   = "${var.name}-sg-redis"
  vpc_id = aws_vpc.vpc.id
}

###
# Security Group Rules
###

resource "aws_security_group_rule" "all_egr" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = "0"
  protocol          = "-1"
  security_group_id = aws_security_group.all.id
  to_port           = "0"
  type              = "egress"
}

resource "aws_security_group_rule" "all_ing" {
  from_port         = "0"
  protocol          = "-1"
  security_group_id = aws_security_group.all.id
  self              = "true"
  to_port           = "0"
  type              = "ingress"
}

resource "aws_security_group_rule" "all_to_front" {
  from_port                = "0"
  protocol                 = "-1"
  security_group_id        = aws_security_group.all.id
  source_security_group_id = aws_security_group.front.id
  to_port                  = "0"
  type                     = "ingress"
}