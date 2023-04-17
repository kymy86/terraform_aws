variable "aws_ami" {
    type = string
}

variable "aws_region" {
    type  = string
}

variable "instance_type" {
    type = string
}

variable "iam_id" {
    type = string
}

variable "instance_sg" {
    type = string
}

variable "app_name" {
    type = string
}

variable "key_name" {
    type = string
}

variable "db_name" {
    type = string
}

variable "db_user" {
    type = string
}

variable "db_pass" {
    type = string
}

variable "db_host" {
    type = string
}

variable "alb_tg_arn" {
    type = string
}

variable "az_zones" {
    type = list
}

variable "subnets" {
    type = string
}

variable "efs_id" {
    type = string
}