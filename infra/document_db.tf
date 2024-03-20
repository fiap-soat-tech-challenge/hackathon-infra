resource "aws_db_subnet_group" "docdb" {
  name       = "subnet_group_docdb"

  subnet_ids = aws_subnet.private_subnet.*.id

  tags = {
    Name = "DB subnet group"
  }
}

resource "aws_security_group" "docdb" {
  name = "${var.app_name}-docdb-sg"
  description = "SG for DocumentDB"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    protocol        = "tcp"
    from_port       = 27017
    to_port         = 27017
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    description = "DocumentDB acesso externo"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_docdb_cluster_parameter_group" "parameter_group" {
  family      = "docdb5.0"
  name        = "docdb-point-management-pg"

  parameter {
    name  = "tls"
    value = "disabled"
  }
}

resource "aws_docdb_cluster" "docdb" {
  cluster_identifier      = "docdb-point-management"
  engine                  = "docdb"
  master_username         = var.docdb_username
  master_password         = var.docdb_password
  preferred_backup_window = "05:00-06:00"
  skip_final_snapshot     = true
  apply_immediately       = true
  availability_zones      = var.availability_zones
  db_subnet_group_name    = aws_db_subnet_group.docdb.name
  vpc_security_group_ids  = [aws_security_group.docdb.id]
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.parameter_group.name
}

resource "aws_docdb_cluster_instance" "docdb_instances" {
  count              = 1
  identifier         = "docdb-instance-${count.index}"
  cluster_identifier = aws_docdb_cluster.docdb.id
  instance_class     = "db.t3.medium"
  apply_immediately = true
}