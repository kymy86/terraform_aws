resource "aws_security_group" "sc_aurora" {
    name = "${var.app_name}-aurora-sg"
    description = "Security group for database instance"
    vpc_id = "${var.vpc_id}"

    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["${var.public_subnet}"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Security group for db instance/s"
    }
}

resource "aws_security_group" "sc_bastion" {
    name = "${var.app_name}-bastion-instance-sg"
    description = "Security group for basion host instance"
    vpc_id  = "${var.vpc_id}"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = "${var.ssh_cidr}"
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Security group for bastion host"
    }

}

resource "aws_security_group" "sc_elb" {
    name = "${var.app_name}-elb-sg"
    description = "Security group for ELB"
    vpc_id = "${var.vpc_id}"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Security group for ELB"
    }
}
    
resource "aws_security_group" "sc_instance" {
    name = "${var.app_name}-web-instance-sg"
    description = "Security group for web server instance"
    vpc_id  = "${var.vpc_id}"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = ["${aws_security_group.sc_bastion.id}"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Security group for web server instance"
    }

}

resource "aws_security_group" "efs_sg" {
    name = "${var.app_name}-efs-sg"
    description = "Security group for EFS"
    vpc_id = "${var.vpc_id}"

    ingress {
        from_port = 2049
        to_port = 2049
        protocol = "tcp"
        security_groups = ["${aws_security_group.sc_instance.id}"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Security group from EFS"
    }
}