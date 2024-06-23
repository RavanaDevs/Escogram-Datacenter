variable "vpc_id" {}
variable "is_public" {}
variable "gateway_id" {}
variable "name" {}

resource "aws_route_table" "route_table" {
  vpc_id = var.vpc_id

  dynamic "route" {
    for_each = var.is_public ? [1] : []
    content {
      cidr_block = "0.0.0.0/0"
      gateway_id = var.gateway_id
    }
  }

  tags = {
    Name = var.name
  }
}

output "route_table_id" {
  value = aws_route_table.route_table.id
}
