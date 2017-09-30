variable "app_name" {
    type = "string"
}

variable "subnets" {
    type = "list"
}

variable "elb_sg" {
    type = "list"
}

variable "vpc_id" {
    type = "string"
}