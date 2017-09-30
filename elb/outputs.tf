output "elb_name" {
    value = "${aws_alb.alb.name}"
}

output  "elb_dns" {
    value = "${aws_alb.alb.dns_name}"
}

output "alb_tg_arn" {
    value ="${aws_alb_target_group.atg.arn}"
}