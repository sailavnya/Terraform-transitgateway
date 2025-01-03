resource "aws_vpc" "VPC_A" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "VPC_A"
  }
}

resource "aws_vpc" "VPC_B" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "VPC_B"
  }
}

resource "aws_vpc" "VPC_C" {
  cidr_block       = "10.1.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "VPC_C"
  }
}
resource "aws_internet_gateway" "VPC_A_IGW" {
  vpc_id = aws_vpc.VPC_A.id

  tags = {
    "name" = "VPC_A_IGW"
  }
}
resource "aws_subnet" "public_subnet_1_for_VPC_A_AZ_2A" {
  vpc_id                  = aws_vpc.VPC_A.id
  cidr_block              = "192.168.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "public_subnet_1_for_VPC_A_AZ_2A"
  }
}

resource "aws_subnet" "public_subnet_2_for_VPC_A_AZ_2B" {
  vpc_id            = aws_vpc.VPC_A.id
  cidr_block        = "192.168.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "public_subnet_2_for_VPC_A_AZ_2B"
  }
}
resource "aws_default_network_acl" "Default_VPC_A_NACL" {
  default_network_acl_id = aws_vpc.VPC_A.default_network_acl_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    "name" = "Default_VPC_A_NACL"
  }
}

resource "aws_default_security_group" "SG_bastion" {
vpc_id = aws_vpc.VPC_A.id

ingress {
from_port = 22
to_port = 22
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}

ingress {
from_port = -1
to_port = -1
protocol = "icmp"
cidr_blocks = ["0.0.0.0/0"]
}

egress {
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
}
}
resource "aws_instance" "Bastion" {
  ami               = "ami-005fc0f236362e99f"
  instance_type     = "t2.micro"
  tenancy           = "default"
  availability_zone = "us-east-1a"
  key_name          = ""
  subnet_id         = aws_subnet.public_subnet_1_for_VPC_A_AZ_2A.id
  security_groups   = ["${aws_default_security_group.SG_bastion.id}"]

  tags = {
    "name" = "Bastion"
  }
}
resource "aws_ec2_transit_gateway" "TGW_Lab" {
  description                     = "the labs transit gateway"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  tags = {
    Name = "TGW_Lab"
  }
}
resource "aws_default_route_table" "VPC_A_RT" {
default_route_table_id = aws_vpc.VPC_A.default_route_table_id

route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.VPC_A_IGW.id
}

route {
cidr_block = "10.0.0.0/16"
transit_gateway_id = aws_ec2_transit_gateway.TGW_Lab.id
}

route {
cidr_block = "10.1.0.0/16"
transit_gateway_id = aws_ec2_transit_gateway.TGW_Lab.id
}

tags = {
Name = "VPC_A_RT"
}
}
resource "aws_ec2_transit_gateway_vpc_attachment" "TGA_VPC_A" {
  subnet_ids         = [aws_subnet.public_subnet_1_for_VPC_A_AZ_2A.id, aws_subnet.public_subnet_2_for_VPC_A_AZ_2B.id]
  transit_gateway_id = aws_ec2_transit_gateway.TGW_Lab.id
  vpc_id             = aws_vpc.VPC_A.id

  tags = {
    Name = "TGA_VPC_A"
  }
}

resource "aws_subnet" "public_subnet_1_for_VPC_B_AZ_2A" {
  vpc_id            = aws_vpc.VPC_B.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "public_subnet_1_for_VPC_B_AZ_2A"
  }
}

resource "aws_subnet" "public_subnet_2_for_VPC_B_AZ_2B" {
  vpc_id            = aws_vpc.VPC_B.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "public_subnet_2_for_VPC_B_AZ_2B"
  }
}
resource "aws_default_route_table" "VPC_B_RT" {
default_route_table_id = aws_vpc.VPC_B.default_route_table_id

route {
cidr_block = "192.168.0.0/16"
transit_gateway_id = aws_ec2_transit_gateway.TGW_Lab.id
}

route {
cidr_block = "10.1.0.0/16"
transit_gateway_id = aws_ec2_transit_gateway.TGW_Lab.id
}

tags = {
Name = "VPC_B_RT"
}
}
resource "aws_default_network_acl" "Default_VPC_B_NACL" {
  default_network_acl_id = aws_vpc.VPC_B.default_network_acl_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    "name" = "Default_VPC_B_NACL"
  }
}

resource "aws_default_security_group" "DB_1" {
vpc_id = aws_vpc.VPC_B.id

ingress {
from_port = 22
to_port = 22
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}

ingress {
from_port = -1
to_port = -1
protocol = "icmp"
cidr_blocks = ["0.0.0.0/0"]
}

egress {
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
}
}
resource "aws_instance" "DB_1" {
  ami               = "ami-005fc0f236362e99f"
  instance_type     = "t2.micro"
  tenancy           = "default"
  availability_zone = "us-east-1a"
  key_name          = ""
  subnet_id         = aws_subnet.public_subnet_1_for_VPC_B_AZ_2A.id
  security_groups   = ["${aws_default_security_group.DB_1.id}"]

  tags = {
    "name" = "DB_1"
  }
}
resource "aws_ec2_transit_gateway_vpc_attachment" "TGA_VPC_B" {
  subnet_ids         = [aws_subnet.public_subnet_1_for_VPC_B_AZ_2A.id, aws_subnet.public_subnet_2_for_VPC_B_AZ_2B.id]
  transit_gateway_id = aws_ec2_transit_gateway.TGW_Lab.id
  vpc_id             = aws_vpc.VPC_B.id

  tags = {
    Name = "TGA_VPC_A"
  }
}


resource "aws_subnet" "public_subnet_1_for_VPC_C_AZ_2A" {
  vpc_id            = aws_vpc.VPC_C.id
  cidr_block        = "10.1.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "public_subnet_1_for_VPC_C_AZ_2A"
  }
}

resource "aws_subnet" "public_subnet_2_for_VPC_C_AZ_2B" {
  vpc_id            = aws_vpc.VPC_C.id
  cidr_block        = "10.1.3.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "public_subnet_2_for_VPC_C_AZ_2B"
  }
}
resource "aws_default_route_table" "VPC_C_RT" {
default_route_table_id = aws_vpc.VPC_C.default_route_table_id

route {
cidr_block = "192.168.0.0/16"
transit_gateway_id = aws_ec2_transit_gateway.TGW_Lab.id
}

route {
cidr_block = "10.0.0.0/16"
transit_gateway_id = aws_ec2_transit_gateway.TGW_Lab.id
}

tags = {
Name = "VPC_C_RT"
}
}
resource "aws_default_network_acl" "Default_VPC_C_NACL" {
  default_network_acl_id = aws_vpc.VPC_C.default_network_acl_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    "name" = "Default_VPC_C_NACL"
  }
}
resource "aws_default_security_group" "DB_2" {
vpc_id = aws_vpc.VPC_C.id

ingress {
from_port = 22
to_port = 22
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}

ingress {
from_port = -1
to_port = -1
protocol = "icmp"
cidr_blocks = ["0.0.0.0/0"]
}

egress {
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
}
}
resource "aws_instance" "DB_2" {
  ami               = "ami-005fc0f236362e99f"
  instance_type     = "t2.micro"
  tenancy           = "default"
  availability_zone = "us-east-1a"
  key_name          = ""
  subnet_id         = aws_subnet.public_subnet_1_for_VPC_C_AZ_2A.id
  security_groups   = ["${aws_default_security_group.DB_2.id}"]

  tags = {
    "name" = "DB_2"
  }
}
resource "aws_ec2_transit_gateway_vpc_attachment" "TGA_VPC_C" {
  subnet_ids         = [aws_subnet.public_subnet_1_for_VPC_C_AZ_2A.id, aws_subnet.public_subnet_2_for_VPC_C_AZ_2B.id]
  transit_gateway_id = aws_ec2_transit_gateway.TGW_Lab.id
  vpc_id             = aws_vpc.VPC_C.id

  tags = {
    Name = "TGA_VPC_C"
  }
}
resource "aws_ec2_transit_gateway_route_table" "TGW_RTB_VPC_B_C" {
transit_gateway_id = aws_ec2_transit_gateway.TGW_Lab.id

tags = {
"name" = "TGW_RTB_VPC_B_C"
}
}

resource "aws_ec2_transit_gateway_route" "TGW_RTB_VPC_B_C_Route_1" {
destination_cidr_block = "0.0.0.0/0"
transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.TGA_VPC_A.id
transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW_RTB_VPC_B_C.id
}

resource "aws_ec2_transit_gateway_route_table_association" "TGW_RTB_VPC_B_C_Association_1" {
transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.TGA_VPC_B.id
transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW_RTB_VPC_B_C.id
}

resource "aws_ec2_transit_gateway_route_table_association" "TGW_RTB_VPC_B_C_Association_2" {
transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.TGA_VPC_C.id
transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW_RTB_VPC_B_C.id
}
resource "aws_ec2_transit_gateway_route_table" "TGW_RTB_VPC_A" {
  transit_gateway_id = aws_ec2_transit_gateway.TGW_Lab.id

  tags = {
    "name" = "TGW_RTB_VPC_A"
  }
}

resource "aws_ec2_transit_gateway_route" "TGW_RTB_VPC_A_Route_1" {
  destination_cidr_block         = "10.0.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.TGA_VPC_B.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW_RTB_VPC_A.id
}

resource "aws_ec2_transit_gateway_route" "TGW_RTB_VPC_A_Route_2" {
  destination_cidr_block         = "10.1.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.TGA_VPC_C.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW_RTB_VPC_A.id
}

resource "aws_ec2_transit_gateway_route_table_association" "TGW_RTB_VPC_A_Association_1" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.TGA_VPC_A.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW_RTB_VPC_A.id
}

# need to change the AMi id 
