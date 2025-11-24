variable "env_name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "asg_min_size" {
  type = number
}

variable "asg_max_size" {
  type = number
}

variable "bucket_name" {
  type = string
}

variable "images_prefix" {
  type    = string
  default = "images/"
}

variable "key_name" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "web_sg_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "iam_instance_profile_name" {
  type    = string
  default = "LabInstanceProfile"
}
