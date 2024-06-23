variable "vpc_name" {}
variable "vpc_cidr" {}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}
