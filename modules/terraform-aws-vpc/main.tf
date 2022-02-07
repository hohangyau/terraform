variable "public_subnets_list" {
  default = []
}

variable "private_subnets_list" {
  default = []
}

variable "custom_subnets_list" {
  default = []
}



#Level 1
resource "aws_vpc" "my_vpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "My VPC"
  }
}

resource "aws_subnet" "my_public_subnets" {

  vpc_id     = aws_vpc.my_vpc.id
  count = length(var.public_subnets_list)  == 0 ? 0 : length(var.public_subnets_list)
  cidr_block = var.public_subnets_list[count.index]
  tags = {
    Name = "Public Subnet"
  }
  depends_on = [
      aws_vpc.my_vpc
  ]
}

resource "aws_internet_gateway" "my_internet_gw" {
  vpc_id     = aws_vpc.my_vpc.id
  count = length(var.public_subnets_list)  == 0 ? 0 : 1
  tags = {
    Name = "main"
  }
    depends_on = [
      aws_vpc.my_vpc
  ]
}

#level 2
resource "aws_subnet" "my_nated_private_subnets" {
  vpc_id     = aws_vpc.my_vpc.id
  count = length(var.private_subnets_list)  == 0 ? 0 : length(var.private_subnets_list)
  cidr_block = var.private_subnets_list[count.index]
  tags = {
    Name = "NAT-ed private Subnet"
  }
}

resource "aws_eip" "nat_gw_eip" {
  count = length(var.private_subnets_list)  == 0 ? 0 : 1
  vpc = true
}

resource "aws_nat_gateway" "gw" {
  count = length(var.private_subnets_list)  == 0 ? 0 : 1

  allocation_id = aws_eip.nat_gw_eip[count.index].id
  subnet_id     = aws_subnet.my_public_subnets[0].id
  depends_on = [
      aws_eip.nat_gw_eip,
      aws_subnet.my_public_subnets
  ]
  tags = {
    "Name" = "attach to a public subnet"
  }
}

resource "aws_route_table" "my_vpc_nated_route_table" {
    count = length(var.private_subnets_list)  == 0 ? 0 : 1
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.gw[count.index].id
    }

    tags = {
        Name = "Main Route Table for NAT-ed private subnet"
    }
}

resource "aws_route_table_association" "my_vpc_nated_route_table_asso" {
    count = length(var.private_subnets_list)  == 0 ? 0 : 1

    subnet_id = aws_subnet.my_nated_private_subnets[count.index].id
    route_table_id = aws_route_table.my_vpc_nated_route_table[count.index].id
}

#level 3
resource "aws_subnet" "my_custom_subnets" {
  vpc_id     = aws_vpc.my_vpc.id
  count = length(var.custom_subnets_list)  == 0 ? 0 : length(var.custom_subnets_list)
  cidr_block = var.custom_subnets_list[count.index]
  tags = {
    Name = "custom Subnet"
  }
}