resource "aws_db_subnet_group" "db_group" {
    name = "main"
    subnet_ids = ["${var.private_subnet}"]
    tags = {
        Name = "Private DB subnet group"
    }
}

resource "aws_rds_cluster" "db_cluster" {
    cluster_identifier = "${var.app_name}-cluster"
    database_name = "${var.app_name}_db"
    master_username = "${var.db_master_username}"
    master_password = "${var.db_master_password}"
    backup_retention_period = 5
    skip_final_snapshot = true
    preferred_backup_window = "05:00-07:00"
    preferred_maintenance_window = "Mon:00:00-Mon:04:00"
    db_subnet_group_name = "${aws_db_subnet_group.db_group.name}"
    vpc_security_group_ids = ["${var.db_sg_id}"]
}

resource "aws_rds_cluster_instance" "cluster_instances" {
    count = 2
    identifier = "${var.app_name}-cluster-${count.index}"
    cluster_identifier = "${aws_rds_cluster.db_cluster.id}"
    instance_class = "${var.db_instance_class}"
    db_subnet_group_name = "${aws_db_subnet_group.db_group.name}"
}