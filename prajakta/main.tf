#############VPC#############

resource "aws_vpc" "vpc_1" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.my_vpc
  }
}
##################SUBNET##############

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.vpc_1.id
  cidr_block = "10.0.0.0/24"
  availability_zone = var.subnet_avz_1

  tags = {
    Name = "public_subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.vpc_1.id
  cidr_block = "10.0.1.0/24"
    availability_zone = var.subnet_avz_2

  tags = {
    Name = "private_subnet"
  }
}

############IGW###############

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_1.id

  tags = {
    Name = "igw"
  }
}

###############RTW##############

resource "aws_route_table" "rtw" {
  vpc_id = aws_vpc.vpc_1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "rtw"
  }
}

############ROUTE##############

resource "aws_route" "my_route" {
  route_table_id            = aws_route_table.rtw.id
  destination_cidr_block    = "0.0.0.0/0"  # Destination CIDR block (all traffic)
  gateway_id                = aws_internet_gateway.igw.id  # Target: Internet Gateway
}

#################ASSOCIATION#################

resource "aws_route_table_association" "association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.rtw.id
}

################SECURITY GROUP###############


resource "aws_security_group" "sg" {
  name        = "terraform_SG"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc_1.id

  ingress {
    description = "http from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    description = "ssh from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    description = "ssh from VPC"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform_sg"
  }
}

#####################INSTANCE################


resource "aws_instance" "ins" {
  ami           = var.ins_ami
  instance_type = var.ins_type
  key_name   = "sydney"
  subnet_id      = aws_subnet.private_subnet.id
   security_groups = [aws_security_group.sg.id]

  tags = {
    Name = var.ins_name_1
  }
}

resource "aws_instance" "ins_2" { 
  ami           = var.ins_ami
  instance_type = var.ins_type
  key_name   = "sydney"
  associate_public_ip_address = true
  subnet_id      = aws_subnet.public_subnet.id
   security_groups = [aws_security_group.sg.id]
  tags = {
    Name = var.ins_name_2
  }
}
