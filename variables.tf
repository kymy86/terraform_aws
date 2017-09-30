variable "aws_region" {
    description = "AWS region where launch the EC2"
    default = "eu-west-1"
}

variable "aws_az" {
    description = "Availability zones"
    default = {
        eu-central-1 = "eu-central-1c,eu-central-1a,eu-central-1b"
        eu-west-1 = "eu-west-1c,eu-west-1a,eu-west-1b"
        eu-west-2 = "eu-west-2c,eu-west-2a,eu-west-2b"
    }
}

variable "ssh_user" {
    description = "Username of SSH connection"
    default = "ubuntu"
}

variable "vpc_cidr_block" {
    default = "10.0.0.0/16"
}

variable "aws_profile" {
    description = "AWS client profile"
    default = "default"
}

variable "aws_amis" {
    default = {
        eu-central-1 = "ami-1e339e71"
        eu-west-1 = "ami-785db401"
        eu-west-2 = "ami-996372fd"
    }
}

variable "instance_type" {
    default = "t2.small"
}

variable "aws_private_key_path" {
    description = <<DESCRIPTION
Path to the SSH private key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.
Example: ~/.ssh/my_private_key.pem
DESCRIPTION
}

variable "aws_public_key_path" {
    description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Example: ~/.ssh/my_public_key.pub
DESCRIPTION
}

variable "aws_key_name" {
    description = "Name of the AWS key pair"
}

variable "app_name" {
    description = "Every resources will be named with this string"
    default = "webres"
}

variable "db_disk_size" {
    description = "Database storage"
    default = 10
}

variable "db_instance_class" {
    description = "Database instance class"
    default = {
        small = "db.t2.small"
        medium = "db.t2.medium"
        large = "db.r3.large"
        xlarge = "db.r3.xlarge"
    }
}

variable "db_instance_size" {
    description = "Size of DB instance"
}

variable "db_master_password" {
    description = "Aurora instance master password"
}

variable "db_master_username" {
    description = "Aurora instance master username"
}

variable "db_password" {
    description = "Database password"
}

variable "db_username" {
    description = "Database username"
}

variable "ssh_cidr" {
    type = "list"
    description = "CIDR blocks from where the SSH connection are allowed"
}
