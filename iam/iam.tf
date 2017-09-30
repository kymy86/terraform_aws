resource "aws_iam_role" "role" {
    name = "${var.app_name}_role"
    assume_role_policy = "${file("${path.module}/policies/role.json")}"
}

resource "aws_iam_role_policy" "role_policy" {
    name = "${var.app_name}_role_policy"
    policy = "${file("${path.module}/policies/policy.json")}"
    role = "${aws_iam_role.role.id}"
}

resource "aws_iam_instance_profile" "inst_profile" {
    name = "${var.app_name}_profile"
    path = "/"
    role = "${aws_iam_role.role.name}"
}