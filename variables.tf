variable "aws_region" {
    description = "AWS region where launch servers"
    default = "eu-west-1"
}

variable "aws_profile" {
    description = "aws profile"
    default = "default"
}

variable "aws_amis" {
    default = {
        eu-west-1 = "ami-e5083683"
        eu-central-1 = "ami-5b06d634"
        us-east-1 = "ami-22ce4934"
        us-west-1 = "ami-9e247efe"
    }
}

variable "s3_bucket" {
    description = "S3 bucket where files are stored for autoscaling group"
}

variable "asg_instance_type" {
    default  = "t2.micro"
}

variable "db_instance_type" {
    default = "t2.medium"
}

variable "aws_public_key_path" {
    description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.
Example: ~/.ssh/terraform.pub
DESCRIPTION
}

variable "aws_key_name" {
    description = "Name of the AWS key pair"
}

variable "db_user" {
 description = "Aurora database user"   
}

variable "db_pass" {
    description = "Aurora database password"
}