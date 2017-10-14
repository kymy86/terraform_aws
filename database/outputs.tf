output "database_dns" {
    value = "${aws_rds_cluster.db_cluster.endpoint}"
}

output "database_name" {
    value = "${aws_rds_cluster.db_cluster.database_name}"
}

output "instances_ids" {
    value = "${aws_rds_cluster_instance.cluster_instances.*}"
}