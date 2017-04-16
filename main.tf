provider "aws" {
    region = "${var.aws_region}"
    profile = "${var.aws_profile}"
}

resource "aws_vpc" "mars_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "MarsVPC"
    }
}

resource "aws_internet_gateway" "mars_odyssey" {
    vpc_id = "${aws_vpc.mars_vpc.id}"
    tags = {
        Name = "Odyssey IGW"
    }
}

resource "aws_route_table" "planet_route" {
    vpc_id = "${aws_vpc.mars_vpc.id}"
    tags = {
        Name = "Private route table"
    }
}

resource "aws_route" "planet_access" {
    route_table_id = "${aws_route_table.planet_route.id}"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.opportunity.id}"
}

resource "aws_route" "space_access" {
    route_table_id = "${aws_vpc.mars_vpc.main_route_table_id}"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.mars_odyssey.id}"
}

resource "aws_subnet" "arcadia" {
    vpc_id = "${aws_vpc.mars_vpc.id}"
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
    tags = {
        Name = "Arcadia Public VPC"
    }
}

resource "aws_eip" "nat_ip" {
    
}

resource "aws_nat_gateway" "opportunity" {
    allocation_id = "${aws_eip.nat_ip.id}"
    subnet_id = "${aws_subnet.arcadia.id}"
}

resource "aws_subnet" "hellas" {
    vpc_id = "${aws_vpc.mars_vpc.id}"
    cidr_block = "10.0.2.0/24"
    tags = {
        Name = "Hellas Private VPC"
    }
}

resource "aws_route_table_association" "public_subnet_association" {
    subnet_id = "${aws_subnet.arcadia.id}"
    route_table_id = "${aws_vpc.mars_vpc.main_route_table_id}"
}

resource "aws_route_table_association" "private_subnet_association" {
    subnet_id = "${aws_subnet.hellas.id}"
    route_table_id = "${aws_route_table.planet_route.id}"
}