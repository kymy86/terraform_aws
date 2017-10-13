provider "aws" {
    region = "${var.aws_region}"
    profile = "${var.aws_profile}"
}

resource "aws_key_pair" "auth" {
    key_name = "${var.aws_key_name}"
    public_key = "${file(var.aws_public_key_path)}"
}

module "iam" {
    source = "./iam"
    app_name = "${var.app_name}"
}

module "network" {
    source = "./network"
    app_name = "${var.app_name}"
    vpc_cidr_block = "${var.vpc_cidr_block}"
    az_zones = "${lookup(var.aws_az, var.aws_region)}"
}

module "security" {
    source = "./security"
    app_name = "${var.app_name}"
    vpc_id = "${module.network.vpc_id}"
    public_subnet = "${module.network.public_cidrs}"
    ssh_cidr = "${var.ssh_cidr}"
}

module "database" {
    source = "./database"
    app_name = "${var.app_name}"
    private_subnet = "${module.network.private_subnet_ids}"
    db_disk_size = "${var.db_disk_size}"
    db_instance_class = "${lookup(var.db_instance_class,var.db_instance_size)}"
    db_master_username = "${var.db_master_username}"
    db_master_password = "${var.db_master_password}"
    db_sg_id = "${module.security.db_sg_id}"
}

resource "aws_efs_file_system" "efs" {
}

data "template_file" "init_bastion" {
    template = "${(file("./user_data/init_bastion.tpl"))}"
    vars {
        db_user = "${var.db_username}"
        db_pass = "${var.db_password}"
        db_name = "${module.database.database_name}"
    }
}

resource "aws_instance" "bastion_host" {
    ami = "${lookup(var.aws_amis, var.aws_region)}"
    instance_type = "${var.instance_type}"
    key_name = "${var.aws_key_name}"
    security_groups = ["${module.security.bastion_sg_id}"]
    subnet_id = "${element(module.network.public_subnet_ids,0)}"
    iam_instance_profile = "${module.iam.instance_profile_id}"

    ebs_block_device = {
        device_name = "/dev/sdb"
        volume_type = "gp2"
        volume_size = "10"
        iops = "100"
    }

    user_data  = "${data.template_file.init_bastion.rendered}"

    tags = {
        Name = "Bastion host instance"
    }
}

data "template_file" "init_db" {
    template = "${file("./user_data/init_db.tpl")}"
    vars {
        db_user = "${var.db_master_username}"
        db_pass = "${var.db_master_password}"
        db_dns = "${module.database.database_dns}"
    }
}

resource "null_resource" "provision_db" {
    triggers {
        db_dns = "${module.database.database_dns}"
    }
    connection {
        type = "ssh"
        host = "${aws_instance.bastion_host.public_ip}"
        user = "${var.ssh_user}"
        private_key = "${file(var.aws_private_key_path)}"
        agent = false
        timeout = "11m"
    }
    provisioner  "remote-exec" {
        inline = "${data.template_file.init_db.rendered}"
    }
}

module "elb" {
    source = "./elb"
    app_name = "${var.app_name}"
    subnets = "${module.network.public_subnet_ids}"
    elb_sg = ["${module.security.elb_sg_id}"]
    vpc_id = "${module.network.vpc_id}"
}

module "asg" {
    source = "./asg"
    aws_amis = "${var.aws_amis}"
    aws_region = "${var.aws_region}"
    instance_type = "${var.instance_type}"
    iam_id = "${module.iam.instance_profile_id}"
    instance_sg = "${module.security.instance_sg_id}"
    app_name = "${var.app_name}"
    db_name = "${module.database.database_name}"
    db_user = "${var.db_username}"
    db_pass = "${var.db_password}"
    db_host = "${module.database.database_dns}"
    key_name = "${var.aws_key_name}"
    alb_tg_arn = "${module.elb.alb_tg_arn}"
    az_zones = "${module.network.public_azs}"
    subnets = "${module.network.public_subnet_ids}"
    efs_id = "${aws_efs_file_system.efs.id}"
    aws_region = "${var.aws_region}"
}
