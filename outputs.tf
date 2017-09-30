output "elb_endpoint" {
    value = "http://${module.elb.elb_dns}"
}

output "s3_bucket_name" {
    value = "${aws_s3_bucket.replica_bucket.id}"
}

output "bastion_host_ip" {
    value  ="${aws_instance.bastion_host.public_ip}"
}

output "cluster_dns" {
    value = "${module.database.database_dns}"
}