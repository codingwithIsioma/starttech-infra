# ============================================================
# SECTION: DATA SOURCES
# ============================================================

# 1.0 AVAILABILITY ZONES
data "aws_availability_zones" "available" {
  state = "available"
}

# ============================================================
# SECTION: NETWORKING
# ============================================================

# 1.0 VPC Resource
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "starttech-vpc"
  }
}

# 2.0 SUBNETS
# 2.1 Public Subnet - Create two public subnets in two different availability zones
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr_block[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                     = "${var.project_name}-public-subnet-${count.index + 1}"
    "kubernetes.io/role/elb" = 1
  }
}
# 2.2 Private Subnet - Create two private subnets in two different availablity zones
resource "aws_subnet" "private" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr_block[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name                              = "${var.project_name}-private-subnet-${count.index + 1}"
    "kubernetes.io/role/internal-elb" = 1
  }
}

# 3.0 INTERNET GATEWAY
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# 4.0 ELASTIC IP - For NAT Gateway
resource "aws_eip" "nat" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}

# 5.0 NAT GATEWAY
# For private subnet outbound access, lives on one public subnet
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "${var.project_name}-nat-gw"
  }
}

# 6.0 ROUTE TABLES
# 6.1.0 Public subnet Route Table and Route Table Association - points all traffic from 0.0.0.0/0 to the IGW and can also point all the data packets arriving to the right resource it needs to arrive at within the public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}
# 6.1.1 Two route table associations, one for each public subnet
resource "aws_route_table_association" "public" {
  count          = 2
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public[count.index].id
}

# 6.2.0 Private subnet Route Table and Route Table Association - points 0.0.0.0/0 traffic to the NAT gateway
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}
# 6.2.1 Two route table associations, one for each private subnet
resource "aws_route_table_association" "private" {
  count          = 2
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private[count.index].id
}
