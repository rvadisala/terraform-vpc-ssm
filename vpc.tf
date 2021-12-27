provider "aws" {
  region = "us-west-2"
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "VPC" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "patch-vpc"
  }
}



resource "aws_subnet" "PublicSubnet1" {
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.VPC.id
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "Public Subnet 1A"
  }
}



resource "aws_subnet" "PublicSubnet2" {
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.VPC.id
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "Public Subnet 1B"
  }
}



resource "aws_subnet" "PublicSubnet3" {
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.VPC.id
  availability_zone       = data.aws_availability_zones.available.names[2]

  tags = {
    Name = "Public Subnet 1C"
  }
}



resource "aws_subnet" "PrivateSubnet1" {
  cidr_block              = "10.0.11.0/24"
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.VPC.id
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "Private Subnet 1A"
  }
}



resource "aws_subnet" "PrivateSubnet2" {
  cidr_block              = "10.0.12.0/24"
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.VPC.id
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "Private Subnet 1B"
  }
}



resource "aws_subnet" "PrivateSubnet3" {
  cidr_block              = "10.0.13.0/24"
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.VPC.id
  availability_zone       = data.aws_availability_zones.available.names[2]

  tags = {
    Name = "Private Subnet 1C"
  }
}

resource "aws_route_table" "RouteTablePublic" {
  vpc_id     = aws_vpc.VPC.id
  depends_on = [aws_internet_gateway.Igw]

  tags = {
    Name = "Public_Route_Table"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Igw.id
  }
}

resource "aws_route_table_association" "AssociationForRouteTablePublic1" {
  subnet_id      = aws_subnet.PublicSubnet1.id
  route_table_id = aws_route_table.RouteTablePublic.id
}

resource "aws_route_table_association" "AssociationForRouteTablePublic2" {
  subnet_id      = aws_subnet.PublicSubnet2.id
  route_table_id = aws_route_table.RouteTablePublic.id
}

resource "aws_route_table_association" "AssociationForRouteTablePublic3" {
  subnet_id      = aws_subnet.PublicSubnet3.id
  route_table_id = aws_route_table.RouteTablePublic.id
}



resource "aws_route_table" "RouteTablePrivate1" {
  vpc_id     = aws_vpc.VPC.id
  depends_on = [aws_nat_gateway.NatGw1]

  tags = {
    Name = "Private Route Table 1A"
  }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NatGw1.id
  }
}

resource "aws_route_table_association" "AssociationForRouteTablePrivate10" {
  subnet_id      = aws_subnet.PrivateSubnet1.id
  route_table_id = aws_route_table.RouteTablePrivate1.id
}



resource "aws_route_table" "RouteTablePrivate2" {
  vpc_id     = aws_vpc.VPC.id
  depends_on = [aws_nat_gateway.NatGw2]

  tags = {
    Name = "Private Route Table 1B"
  }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NatGw2.id
  }
}

resource "aws_route_table_association" "AssociationForRouteTablePrivate20" {
  subnet_id      = aws_subnet.PrivateSubnet2.id
  route_table_id = aws_route_table.RouteTablePrivate2.id
}



resource "aws_route_table" "RouteTablePrivate3" {
  vpc_id     = aws_vpc.VPC.id
  depends_on = [aws_nat_gateway.NatGw3]

  tags = {
    Name = "Private Route Table 1C"
  }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NatGw3.id
  }
}

resource "aws_route_table_association" "AssociationForRouteTablePrivate30" {
  subnet_id      = aws_subnet.PrivateSubnet3.id
  route_table_id = aws_route_table.RouteTablePrivate3.id
}



resource "aws_internet_gateway" "Igw" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "IGW"
  }
}

resource "aws_eip" "EipForNatGw1" {
}

resource "aws_nat_gateway" "NatGw1" {
  allocation_id = aws_eip.EipForNatGw1.id
  subnet_id     = aws_subnet.PublicSubnet1.id

  tags = {
    Name = "NAT GW 1A"
  }
}

resource "aws_eip" "EipForNatGw2" {
}

resource "aws_nat_gateway" "NatGw2" {
  allocation_id = aws_eip.EipForNatGw2.id
  subnet_id     = aws_subnet.PublicSubnet2.id

  tags = {
    Name = "NAT GW 1B"
  }
}

resource "aws_eip" "EipForNatGw3" {
}

resource "aws_nat_gateway" "NatGw3" {
  allocation_id = aws_eip.EipForNatGw3.id
  subnet_id     = aws_subnet.PublicSubnet3.id

  tags = {
    Name = "NAT GW 1C"
  }
}

resource "aws_flow_log" "FlowLogs" {
  traffic_type         = "ALL"
  log_destination_type = "cloud-watch-logs"
  vpc_id               = aws_vpc.VPC.id
  log_destination      = aws_cloudwatch_log_group.CwLogGroup.arn
  iam_role_arn         = aws_iam_role.CwLogIamRole.arn
}

resource "aws_cloudwatch_log_group" "CwLogGroup" {
  name = "FlowLogs"
}

resource "aws_iam_role" "CwLogIamRole" {
  name               = "iamRoleFlowLogsToCloudWatchLogs"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["vpc-flow-logs.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "CwLogIamRoleInlinePolicyRoleAttachment0" {
  name   = "allow-access-to-cw-logs"
  role   = aws_iam_role.CwLogIamRole.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "FlowLogsCreateLogStream2014110",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams"
            ],
            "Resource": "*"
        }
    ]
}
POLICY
}



resource "aws_security_group" "allow-ssh" {
  name        = "allow-ssh-traffic"
  description = "A security group that allows inbound SSH traffic (TCP port 22)."
  vpc_id      = aws_vpc.VPC.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
