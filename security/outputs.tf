output "db_sg_id" {
    value = "${aws_security_group.sc_aurora.id}"
}

output "instance_sg_id" {
    value = "${aws_security_group.sc_instance.id}"
}

output "bastion_sg_id" {
    value = "${aws_security_group.sc_bastion.id}"
}

output "elb_sg_id" {
    value = "${aws_security_group.sc_elb.id}"
}