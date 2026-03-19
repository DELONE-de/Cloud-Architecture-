# --- DB Subnet Group (private subnets only) ---
resource "aws_db_subnet_group" "main" {
  name       = "${var.env}-db-subnet-group"
  subnet_ids = [var.private_subnet_id, var.private_db_subnet_id]

  tags = {
    Name = "${var.env}-db-subnet-group"
  }
}

# --- RDS PostgreSQL Instance ---
resource "aws_db_instance" "postgres" {
  identifier        = "${var.env}-postgres"
  engine            = "postgres"
  engine_version    = "15.4"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.db_sg_id]

  # Storage encryption
  storage_encrypted = true

  # Automated backups
  backup_retention_period = 7
  backup_window           = "02:00-03:00"
  maintenance_window      = "mon:04:00-mon:05:00"

  # Keep database private
  publicly_accessible = false

  skip_final_snapshot = false
  final_snapshot_identifier = "${var.env}-postgres-final-snapshot"

  tags = {
    Name = "${var.env}-postgres"
  }
}
