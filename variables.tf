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