provider "aws" {
    region = "${var.aws_region}"
    profile = "${var.aws_profile}"
}

module "security" {
    source = "./security"
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
}

resource "aws_iam_instance_profile" "s3_profile" {
    name = "s3_profile"
    roles = ["${aws_iam_role.s3role.name}"]
}

#creating aws launch configuration
resource "aws_launch_configuration" "mars_conf" {
    name = "mars autoscaling probes"
    image_id = "${lookup(var.aws_amis, var.aws_region)}"
    instance_type = "${var.asg_instance_type}"
    iam_instance_profile = "${aws_iam_instance_profile.s3_profile.id}"
    security_groups = ["${module.security.default_sc_id}"]
    user_data = <<EOF
#!/bin/bash
yum update -y 
yum install httpd -y
service httpd start
chkconfig httpd on
echo "*/1 * * * * sudo aws s3 sync /var/www/html s3://${var.s3_bucket}" >> /etc/crontab
aws s3 sync /var/www/html s3://${var.s3_bucket}
EOF
}

#creating bucket
#syncing command aws s3 sync /var/www/html s3://bucket-name