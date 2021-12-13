// subnet group for aurora
resource "aws_db_subnet_group" "db" {
  name       = "sbcntr-rds-subnet-group"
  subnet_ids = [var.subnet_db1, var.subnet_db2]
}

// aurora cluster
resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = "sbcntr-db"
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.10.0"
  db_subnet_group_name    = aws_db_subnet_group.db.name
  port                    = "3306"
  vpc_security_group_ids  = [var.db_sg]
  database_name           = "sbcntrapp"
  master_username         = "admin"
  master_password         = var.db_pass
  backup_retention_period = 1
  preferred_backup_window = "07:00-09:00"
  storage_encrypted       = true
}

resource "aws_rds_cluster_instance" "db_instance" {
  count                = 2
  identifier           = "sbcntrdb${count.index}"
  cluster_identifier   = aws_rds_cluster.aurora.id
  publicly_accessible  = false
  instance_class       = "db.t3.small"
  engine               = aws_rds_cluster.aurora.engine
  engine_version       = aws_rds_cluster.aurora.engine_version
  db_subnet_group_name = aws_db_subnet_group.db.name
}
