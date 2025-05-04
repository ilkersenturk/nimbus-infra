######### VPC #########
#VIrtual cloud network defines the network ip range 
# it depend on cidr block, region and aws

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "region" {
  default = "us-east-2"
}

provider "aws" {
  region = var.region
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "nimbus-vpc"
  }
}


######### Internet Gateway #########

#An Internet Gateway (IGW) is what allows resources in your public subnets (like EC2) to talk to the internet.
# rosource means we will be creating aws_internet_gateway
#vpc_id = aws_vpc.main.id	🔹 This attaches the Internet Gateway to your VPC

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "nimbus-igw"
  }
}


######### Public Subnets #########

#A subnet (short for sub-network) is a logical subdivision of your VPC's CIDR block.
#RESOURCE ==> CREATING AWS_SUBNET NAMED public_a
#IT DPEND ON VPC_ID, CIDR_BLOCK,AVAILITY ZONE,
#map_public_ip_on_launch ==> IMPORTANT WHAT EVER THE SERVICE ATTACHED WILL HAVE INTERNET

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "nimbus-public-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true
  tags = {
    Name = "nimbus-public-b"
  }
}
######### Private Subnets #########
# Private Subnet A
resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.11.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false

  tags = {
    Name = "nimbus-private-a"
  }
}

# Private Subnet B
resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.12.0/24"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = false

  tags = {
    Name = "nimbus-private-b"
  }
}

######### Public Route Table #########

#Without this, even if your instance has a public IP, it won’t work, 
#because AWS needs a route telling it how to get to the internet.

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "nimbus-public-rt"
  }
}


######### Route Table Associations #########
#A route table alone doesn’t do anything until it’s assigned to a subnet.

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}