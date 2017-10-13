data "template_file" "init_server" {
    template = "${(file("./user_data/init_server.tpl"))}"
    vars {
        db_name = "${var.db_name}"
        db_user = "${var.db_user}"
        db_pass = "${var.db_pass}"
        db_host = "${var.db_host}"
        efs_id = "${var.efs_id}"
        aws_region = "${var.aws_region}"
    }
}

resource "aws_cloudwatch_metric_alarm" "cw_alarm" {
    alarm_name = "${var.app_name}-alarm"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods = 2
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = 60
    statistic = "Average"
    threshold = 80

    dimensions {
        AutoScalingGroupName = "${aws_autoscaling_group.autoscaling_group.name}"
    }

    alarm_description = "This metric monitors ec2 cpu utilization"
    alarm_actions = ["${aws_autoscaling_policy.asgp.arn}"]
}

resource "aws_launch_configuration" "lc_conf" {
    name_prefix = "launch-px"
    image_id = "${lookup(var.aws_amis, var.aws_region)}"
    instance_type = "${var.instance_type}"
    iam_instance_profile = "${var.iam_id}"
    security_groups = ["${var.instance_sg}"]
    key_name = "${var.key_name}"
    
    ebs_block_device = {
        device_name = "/dev/sdf"
        volume_type = "gp2"
        volume_size = "20"
        iops = "100"
    }

    user_data = "${data.template_file.init_server.rendered}"
}

resource "aws_autoscaling_group" "autoscaling_group" {
    name = "${var.app_name}-asg"
    max_size = 5
    min_size = 2
    health_check_type = "ELB"
    health_check_grace_period = 600
    force_delete = true
    launch_configuration = "${aws_launch_configuration.lc_conf.name}"
    target_group_arns = ["${var.alb_tg_arn}"]
    vpc_zone_identifier = ["${var.subnets}"]
    
    tag {
        key = "Name"
        value = "${var.app_name} web instance"
        propagate_at_launch = true
    }
}

resource "aws_autoscaling_policy" "asgp" {
    name = "${var.app_name}-policy"
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    cooldown = 600
    autoscaling_group_name = "${aws_autoscaling_group.autoscaling_group.name}"
}

