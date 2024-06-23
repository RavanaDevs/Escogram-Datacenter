variable "ami" {
  description = "The AMI ID"
}

variable "instance_type" {
  description = "The instance type"
}

variable "subnet_id" {
  description = "The Subnet ID"
}

variable "security_group" {
  description = "The Security Group ID"
}

variable "associate_public_ip_address" {
  description = "Associate a public IP address"
  type        = bool
  default     = true
}

variable "key_name" {
  description = "The key pair name for the instance"
}

variable "name" {
  description = "The name of the instance"
  default     = "ec2-instance"
}

variable "user_data" {
    description = "User data script for ec2 instance"
    default = ""
}
