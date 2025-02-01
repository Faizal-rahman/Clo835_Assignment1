# Define the AWS provider
provider "aws" {
  region = "us-east-1"  
}

# Get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Get route table
data "aws_route_table" "default" {
  vpc_id = data.aws_vpc.default.id
}


# Get the existing Internet Gateway
data "aws_internet_gateway" "existing_igw" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Get the default subnet in the default VPC
data "aws_subnet" "default" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "us-east-1a"
}

# Adding SSH key to Amazon EC2
resource "aws_key_pair" "web_key" {
  key_name   = "sshkey"
  public_key = file("sshkey.pub")
}

# Security Group to allow inbound SSH traffic
resource "aws_security_group" "docker_application_sg" {
  name        = "docker-application-sg"
  description = "Allow inbound SSH, HTTP (8080), and MySQL (3306) traffic for Docker applications"

  # Inbound rules (Ingress)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to all IPs (change to a more secure IP range in production)
    description = "Allow SSH access"
  }

  ingress {
    from_port   = 8080
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow access to web application from anywhere
    description = "Allow HTTP access to web app on port 8080 to 8083"
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # (or restrict this to EC2 itself for security)
    description = "Allow MySQL access (consider restricting for security)"
  }

  # Outbound rules (Egress)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}

# Create EC2 instance in the default subnet
resource "aws_instance" "EC2" {
  ami           = "ami-0c614dee691cbbf37"  
  instance_type = "t2.micro"

  subnet_id            = data.aws_subnet.default.id  # Using the default subnet's ID
  vpc_security_group_ids = [aws_security_group.docker_application_sg.id]  # Attach the security group by ID
  associate_public_ip_address = true
  key_name             = aws_key_pair.web_key.key_name  # Use the generated key pair

  tags = {
    Name = "Ec2"
  }
}

# Create Amazon ECR Repository for the Web Application
resource "aws_ecr_repository" "web_application" {
  name = "web-application-repo"  # Name of the repository 

  tags = {
    Name = "web-application-repo"
  }
}

# Create Amazon ECR Repository for MySQL Image
resource "aws_ecr_repository" "mysql" {
  name = "mysql-repo"  # Name of the repository

  tags = {
    Name = "mysql-repo"
  }
}
