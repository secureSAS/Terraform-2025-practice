//create a VPC
resource "aws_vpc" "lab2_vpc"{
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "lab2_vpc"
    }
}

//create IGW
resource "aws_internet_gateway" "IGW_1"{
    vpc_id = aws_vpc.lab2_vpc.id
    tags = {
        name = "IGW_1"
    }
}
//Create 2 subnets
//create Public subnet
resource "aws_subnet" "public_subnet1"{
 vpc_id = aws_vpc.lab2_vpc.id
 cidr_block = "10.0.1.0/24"
 availability_zone = "ap-south-1a"
 map_public_ip_on_launch = true  

  tags = {
    Name = "public_subnet1"
  }
  
}
//Create private subnet
resource "aws_subnet" "private_subnet1"{
 vpc_id = aws_vpc.lab2_vpc.id
 cidr_block = "10.0.2.0/24"
 availability_zone = "ap-south-1b"
  tags = {
    Name = "private_subnet1"
  }
  
}
//Create internet Route table 
resource "aws_route_table" "RT1"{
  vpc_id = aws_vpc.lab2_vpc.id
  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW_1.id
  }  
  route{
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }
  tags = {
    name = "RT1"
  }
}

//Create intranet route table
resource "aws_route_table" "RT2"{
  vpc_id = aws_vpc.lab2_vpc.id
  route{
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }
  tags = {
    name = "RT2"
  }
}

//Create Route Table association
resource "aws_route_table_association" "a1"{
    subnet_id = aws_subnet.public_subnet1.id
    route_table_id = aws_route_table.RT1.id
}
resource "aws_route_table_association" "a2"{
    subnet_id = aws_subnet.private_subnet1.id
    route_table_id = aws_route_table.RT2.id
}

//Create Security Group
resource "aws_security_group" "SG1"{
 vpc_id = aws_vpc.lab2_vpc.id
 #First Ingress rule-Allow ICMP
 ingress{
    from_port = -1
    to_port = -1
    protocol = "ICMP"
    cidr_blocks =["0.0.0.0/0"]
 }   
 # Second ingress rule: Allow SSH (port 22) traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }
  egress{
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

//Create EC2 instance in Public subnet
resource "aws_instance" "instance-1"{
    ami           = "ami-02ddb77f8f93ca4ca" 
    instance_type = "t2.micro"
    subnet_id = aws_subnet.public_subnet1.id
    key_name = "my-keypair"
    vpc_security_group_ids = [aws_security_group.SG1.id]
}

//Create EC2 instance in private subnet
resource "aws_instance" "instance-2"{
    ami           = "ami-02ddb77f8f93ca4ca" 
    instance_type = "t2.micro"
    subnet_id = aws_subnet.private_subnet1.id
    key_name = "my-keypair"
    vpc_security_group_ids = [aws_security_group.SG1.id]
}

test test test




