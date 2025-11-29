variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.2.0.0/16"
}

variable "key_name" {
  description = "vockey"
  type        = string
  default     = "vockey"
}

variable "allowed_ssh_cidr" {
  description = "99.247.155.252/32"
  type        = string
  default     = "0.0.0.0/0"
}
