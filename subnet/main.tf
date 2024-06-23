variable "vpc_id" {}
variable "cidr" {}
variable "map_public_ip_on_launch" {}
variable "availability_zone" {}
variable "name" {}

resource "aws_subnet" "subnet" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.cidr
  map_public_ip_on_launch = var.map_public_ip_on_launch
  availability_zone       = var.availability_zone

  tags = {
    Name = var.name
  }
}

output "subnet_id" {
  value = aws_subnet.subnet.id
}
