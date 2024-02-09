resource "aws_vpc" "wsi-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "wsi-vpc"
  }
}

# ---

resource "aws_subnet" "wsi-public-a" {
  vpc_id     = aws_vpc.wsi-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "wsi-public-a"
  }
}

resource "aws_subnet" "wsi-public-b" {
  vpc_id     = aws_vpc.wsi-vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "wsi-public-b"
  }
}

# ---

resource "aws_subnet" "wsi-private-a" {
  vpc_id     = aws_vpc.wsi-vpc.id
  cidr_block = "10.0.3.0/24"
  
  tags = {
    Name = "wsi-private-a"
  }
}

resource "aws_subnet" "wsi-private-b" {
  vpc_id     = aws_vpc.wsi-vpc.id
  cidr_block = "10.0.4.0/24"

  tags = {
    Name = "wsi-private-b"
  }
}

resource "aws_internet_gateway" "wsi-igw" {
  vpc_id = aws_vpc.wsi-vpc.id

  tags = {
    Name = "wsi-igw"
  }
}

resource "aws_route_table" "wsi-public-rt" {
  vpc_id = aws_vpc.wsi-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wsi-igw.id
  }

  tags = {
    Name = "wsi-public-rt"
  }
}

resource "aws_route_table" "wsi-private-a-rt" {
  vpc_id = aws_vpc.wsi-vpc.id

  tags = {
    Name = "wsi-private-a-rt"
  }
}

resource "aws_route_table" "wsi-private-b-rt" {
  vpc_id = aws_vpc.wsi-vpc.id

  tags = {
    Name = "wsi-private-b-rt"
  }
}

resource "aws_nat_gateway" "wsi-nat-a" {
  depends_on = [ aws_internet_gateway.wsi-igw ]

  subnet_id = aws_subnet.wsi-public-a.id
  allocation_id = aws_eip.nat[0].id

  tags = {
    Name = "wsi-nat-a"
  }
}

resource "aws_nat_gateway" "wsi-nat-b" {
  depends_on = [ aws_internet_gateway.wsi-igw ]

  subnet_id = aws_subnet.wsi-public-b.id
  allocation_id = aws_eip.nat[1].id

  tags = {
    Name = "wsi-nat-b"
  }
}

resource "aws_eip" "nat" {
  count = 2
}

resource "aws_route" "private-a-route" {
  route_table_id         = aws_route_table.wsi-private-a-rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.wsi-nat-a.id
}

resource "aws_route" "private-b-route" {
  route_table_id         = aws_route_table.wsi-private-b-rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.wsi-nat-b.id
}

resource "aws_route_table_association" "public-a-association" {
  subnet_id      = aws_subnet.wsi-public-a.id
  route_table_id = aws_route_table.wsi-public-rt.id
}

resource "aws_route_table_association" "public-b-association" {
  subnet_id      = aws_subnet.wsi-public-b.id
  route_table_id = aws_route_table.wsi-public-rt.id
}

resource "aws_route_table_association" "private-a-association" {
  subnet_id      = aws_subnet.wsi-private-a.id
  route_table_id = aws_route_table.wsi-private-a-rt.id
}

resource "aws_route_table_association" "private-b-association" {
  subnet_id      = aws_subnet.wsi-private-b.id
  route_table_id = aws_route_table.wsi-private-b-rt.id
}