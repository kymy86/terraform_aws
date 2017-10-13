output "elb_endpoint" {
    value = "http://${module.elb.elb_dns}"
}

output "bastion_host_ip" {
    value  ="${aws_instance.bastion_host.public_ip}"
}

output "cluster_dns" {
    value = "${module.database.database_dns}"
}