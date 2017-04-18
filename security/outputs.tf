output "elb_sc_id" {
    value = "${aws_security_group.mars_sc_elb.id}"
}

output "default_sc_id" {
    value = "${aws_security_group.mars_sc_default.id}"
}

output "aurora_sc_id" {
    value = "${aws_security_group.mars_sc_aurora.id}"
}