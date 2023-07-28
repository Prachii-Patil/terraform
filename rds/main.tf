provider "aws" {
    region  = "ap-southeast-2"
   
}

resource "aws_db_instance" "example" {
  identifier             = "my-rds-instance"
  engine                 = var.engine_name
  instance_class         = "db.t2.micro"
  allocated_storage      = var.storage_number
  storage_type           = "gp2"
  username               = var.username_name
  password               = "admin123"
  publicly_accessible    = false
}