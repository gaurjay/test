resource "aws_vpc" "test-vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "dev_sub" {
  vpc_id                  = aws_vpc.test-vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "dev_sub"
  }
}

resource "aws_subnet" "dev_sub1" {
  vpc_id            = aws_vpc.test-vpc.id
  cidr_block        = "10.123.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    "Name" = "dev_sub1"
  }
}

resource "aws_internet_gateway" "dev_igw" {
  vpc_id = aws_vpc.test-vpc.id

  tags = {
    Name = "dev_igw"
  }
}

resource "aws_route_table" "dev_pub_rt" {
  vpc_id = aws_vpc.test-vpc.id

  tags = {
    Name = "dev_rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.dev_pub_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.dev_igw.id
}

resource "aws_route_table_association" "dev_ass" {
  subnet_id  = aws_subnet.dev_sub.id
  route_table_id = aws_route_table.dev_pub_rt.id
}

resource "aws_security_group" "dev_sg" {
  name = "dev"
  vpc_id = aws_vpc.test-vpc.id

  ingress {
    from_port = 0
    to_port = 0
    protocol ="-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol ="-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "dev_auth" {
  key_name = "devkey"
  public_key = file("/home/leo/.ssh/id_ed25519.pub")
}

resource "aws_instance" "dev_node" {
  count = 2
  instance_type = "t2.medium"
  ami = data.aws_ami.server_ami.id

  tags = {
    Name = "dev-${count.index}"
  }

  key_name = aws_key_pair.dev_auth.id 
  vpc_security_group_ids = [aws_security_group.dev_sg.id]
  subnet_id = aws_subnet.dev_sub.id

  root_block_device {
    volume_size = 10
  } 
}

