output "mars_vpc_id" {
    value = "${aws_vpc.mars_vpc.id}"
}

output "priv_hellas_subnet_id" {
    value = "${aws_subnet.hellas.id}"
}

output "pub_arcadia_subnet_id" {
    value = "${aws_subnet.arcadia.id}"
}

output "nat_opportunity_id" {
    value = "${aws_nat_gateway.opportunity.id}"
}