provider "aws" {
    region = "${var.aws_region}"
    profile = "${var.aws_profile}"
}

resource "aws_key_pair" "mars_auth" {
  key_name = "${var.aws_key_name}"
  public_key = "${file(var.aws_public_key_path)}"
}

module "network" {
    source = "./network"
}

module "security" {
    source = "./security"
    vpc_id = "${module.network.mars_vpc_id}"
}

resource "aws_iam_role" "s3role" {
    name = "s3MarsRole"

    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "s3role_policy" {
    name = "s3_access_policy"
    role = "${aws_iam_role.s3role.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    }
  ]
}
EOF
}

#create the bucket in S3
resource "aws_s3_bucket" "earth_bucket" {
    bucket = "${var.s3_bucket}"
    force_destroy = true
}

resource "aws_iam_instance_profile" "s3_profile" {
    name = "s3_profile"
    roles = ["${aws_iam_role.s3role.name}"]
}

#creating aws launch configuration
resource "aws_launch_configuration" "mars_conf" {
    name = "mars autoscaling probes"

    lifecycle { create_before_destroy = true }

    image_id = "${lookup(var.aws_amis, var.aws_region)}"
    instance_type = "${var.asg_instance_type}"
    iam_instance_profile = "${aws_iam_instance_profile.s3_profile.id}"
    security_groups = ["${module.security.default_sc_id}"]
    key_name = "${var.aws_key_name}"
    user_data = <<EOF
#!/bin/bash
yum update -y 
yum install httpd -y
service httpd start
chkconfig httpd on
touch /var/www/html/healthy.html
echo "*/1 * * * * sudo aws s3 sync /var/www/html s3://${var.s3_bucket}" >> /etc/crontab
aws s3 sync /var/www/html s3://${var.s3_bucket}
EOF
}

resource "aws_elb" "mars_elb" {
  name = "mars-elb"
  subnets = ["${module.network.pub_arcadia_subnet_id}"]
  security_groups = ["${module.security.elb_sc_id}"]
  idle_timeout = 60
  
  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  
  health_check {
    healthy_threshold = 10
    unhealthy_threshold = 2
    timeout = 5
    target = "HTTP:80/healthy.html"
    interval = 30
  }

  tags {
    Name = "mars-elb"
  }
}

resource "aws_autoscaling_group" "outpost_ag" {
  lifecycle { create_before_destroy = true }
  name = "mars-outposts-autoscaling-group"
  max_size = 3
  min_size = 2
  health_check_grace_period = 300
  health_check_type = "ELB"
  wait_for_elb_capacity = 2
  desired_capacity = 2
  force_delete = true
  launch_configuration = "${aws_launch_configuration.mars_conf.name}"
  vpc_zone_identifier = ["${module.network.pub_arcadia_subnet_id}"]
  load_balancers = ["${aws_elb.mars_elb.id}"]

  tag {
    key = "name"
    value = "mars-autoscaled-instance"
    propagate_at_launch = true
  }
}

resource "aws_instance" "mars_db" {
  ami = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "${var.db_instance_type}"
  key_name = "${var.aws_key_name}"
  security_groups = ["${module.security.db_sc_id}"]
  subnet_id = "${module.network.priv_hellas_subnet_id}"

  ebs_block_device = {
    device_name = "/dev/sdb"
    volume_type = "io1"
    volume_size = "10"
    iops = "500"
  }

  user_data = "${file("./user_data/init.sh")}"

  tags = {
    key = "Name"
    value = "Mars DB Instance"
  }
}