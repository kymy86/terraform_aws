resource "aws_alb" "alb" {
    name = "${var.app_name}-alb"
    internal = false
    subnets = ["${var.subnets}"]
    security_groups = ["${var.elb_sg}"]

    idle_timeout = 300

    tags {
        Name = "${var.app_name} ALB"
    }
}

resource "aws_alb_listener" "alb_http" {
    load_balancer_arn  = "${aws_alb.alb.arn}"
    port = "80"
    protocol = "HTTP"

    default_action {
        target_group_arn = "${aws_alb_target_group.atg.arn}"
        type = "forward"
    }
}

resource "aws_alb_target_group" "atg" {
    name = "${var.app_name}-alb-tg"
    port = 80
    protocol = "HTTP"
    vpc_id = "${var.vpc_id}"
    
    health_check {
        healthy_threshold = 2
        unhealthy_threshold = 2
        timeout = 10
        interval = 30
        path ="/health.htm"
    }
}