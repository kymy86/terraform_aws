output "database_dns" {
    value = "${aws_rds_cluster.db_cluster.endpoint}"
}

output "database_name" {
    value = "${aws_rds_cluster.db_cluster.database_name}"
}