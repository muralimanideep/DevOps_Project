provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "infra-server" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.small"
  key_name      = "dpp"
  #security_groups        = ["infra-sg"]
  vpc_security_group_ids = [aws_security_group.infra-sg.id]
  subnet_id              = aws_subnet.infra-public-subnet-01.id
  for_each               = toset(["DOCKER"])
  tags = {
    Name = "${each.key}"
  }


}

resource "aws_security_group" "infra-sg" {
  name        = "infra-sg"
  description = "ssh access"
  vpc_id      = aws_vpc.infra-vpc.id

  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "SSH access"
  }


} 

resource "aws_vpc" "infra-vpc" {
  cidr_block = "10.2.0.0/16"
  tags = {
    Name = "infra-vpc"
  }

}

resource "aws_subnet" "infra-public-subnet-01" {
  vpc_id                  = aws_vpc.infra-vpc.id
  cidr_block              = "10.2.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1a"
  tags = {
    Name = "infra-public-subnet-01"
  }

}

resource "aws_subnet" "infra-public-subnet-02" {
  vpc_id                  = aws_vpc.infra-vpc.id
  cidr_block              = "10.2.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1b"
  tags = {
    Name = "infra-public-subnet-02"
  }

}

resource "aws_internet_gateway" "infra-igw" {
  vpc_id = aws_vpc.infra-vpc.id
  tags = {
    Name = "infra-igw"
  }

}

resource "aws_route_table" "infra-public-rt" {
  vpc_id = aws_vpc.infra-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.infra-igw.id
  }
}

resource "aws_route_table_association" "infra-rta-public-subnet-01" {
  subnet_id      = aws_subnet.infra-public-subnet-01.id
  route_table_id = aws_route_table.infra-public-rt.id

}

resource "aws_route_table_association" "infra-rta-public-subnet-02" {
  subnet_id      = aws_subnet.infra-public-subnet-02.id
  route_table_id = aws_route_table.infra-public-rt.id

} 

/*module "sgs" {
  source = "../sg_eks"
  vpc_id = aws_vpc.infra-vpc.id
}

module "eks" {
  source     = "../eks"
  vpc_id     = aws_vpc.infra-vpc.id
  subnet_ids = [aws_subnet.infra-public-subnet-01.id, aws_subnet.infra-public-subnet-02.id]
  sg_ids     = module.sgs.security_group_public
} */

