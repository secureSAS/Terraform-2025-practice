// Initialize the AWS provider
provider "aws" {
  region = "ap-south-1" 
}

// Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16" 
  tags = {
    Name = "my-vpc"
  }
}

//create internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_igw"
  }
}

// Create 2 subnets inside the VPC
resource "aws_subnet" "my_subnet1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24" 
  availability_zone       = "ap-south-1a" 
  map_public_ip_on_launch = true  

  tags = {
    Name = "my-subnet1"
  }
}

resource "aws_subnet" "my_subnet2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24" 
  availability_zone       = "ap-south-1b" 
  map_public_ip_on_launch = true  

  tags = {
    Name = "my-subnet2"
  }
}

resource "aws_route_table" "my_rt1" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }
  tags = {
    Name = "my_rt1"
  }
} 

resource "aws_route_table_association" "a1" {
  subnet_id      = aws_subnet.my_subnet1.id
  route_table_id = aws_route_table.my_rt1.id
}

resource "aws_route_table_association" "a2" {
  subnet_id      = aws_subnet.my_subnet2.id
  route_table_id = aws_route_table.my_rt1.id
}

// Create a security group for the EC2 instance
resource "aws_security_group" "my_sg" {
  name_prefix = "my-sg-"
  vpc_id = aws_vpc.my_vpc.id

# First ingress rule: Allow ICMP (ping) traffic
  ingress {
    from_port   = -1  # ICMP protocol does not use port numbers
    to_port     = -1  # ICMP protocol does not use port numbers
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow ICMP from any source (for demonstration purposes)
  }

# Second ingress rule: Allow SSH (port 22) traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from any source (for demonstration purposes)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// Create 2 EC2 instance
resource "aws_instance" "my_instance1" {
  ami           = "ami-02ddb77f8f93ca4ca" # Change to your desired AMI
  instance_type = "t2.micro"              # Change to your desired instance type
  subnet_id     = aws_subnet.my_subnet1.id
  key_name      = "my-keypair"         # Change to your SSH key pair name
  vpc_security_group_ids = [aws_security_group.my_sg.id]

  tags = {
    Name = "my-ec2-instance1"
  }
}

resource "aws_instance" "my_instance2" {
  ami           = "ami-02ddb77f8f93ca4ca" # Change to your desired AMI
  instance_type = "t2.micro"              # Change to your desired instance type
  subnet_id     = aws_subnet.my_subnet2.id
  key_name      = "my-keypair"         # Change to your SSH key pair name
  vpc_security_group_ids = [aws_security_group.my_sg.id]

  tags = {
    Name = "my-ec2-instance2"
  }
}

testing git changes ... 
