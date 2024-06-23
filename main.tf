provider "aws" {
  region = var.region
}

module "vpc" {
  source   = "./vpc"
  vpc_name = var.vpc_name
  vpc_cidr = var.vpc_cidr
}

module "internet_gateway" {
  source = "./internet_gateway"
  vpc_id = module.vpc.vpc_id
  name   = "rd-igw"
}

module "public_subnet_a" {
  source                  = "./subnet"
  vpc_id                  = module.vpc.vpc_id
  cidr                    = "10.0.1.0/24"
  map_public_ip_on_launch = true
  name                    = "rd-public-subnet"
  availability_zone       = "ap-southeast-1a"
}

module "public_subnet_b" {
  source                  = "./subnet"
  vpc_id                  = module.vpc.vpc_id
  cidr                    = "10.0.2.0/24"
  map_public_ip_on_launch = true
  name                    = "rd-public-subnet"
  availability_zone       = "ap-southeast-1b"
}

module "public_rt" {
  source     = "./route_table"
  vpc_id     = module.vpc.vpc_id
  gateway_id = module.internet_gateway.internet_gateway_id
  is_public  = true
  name       = "rd-public-rt"
}

resource "aws_route_table_association" "rt_association_public_a" {
  subnet_id      = module.public_subnet_a.subnet_id
  route_table_id = module.public_rt.route_table_id
}

resource "aws_route_table_association" "rt_association_public_b" {
  subnet_id      = module.public_subnet_b.subnet_id
  route_table_id = module.public_rt.route_table_id
}

module "public_sg" {
  source = "./security_group"
  vpc_id = module.vpc.vpc_id
  name   = "rd-public-sg"
  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

module "public_ec2_a" {
  source         = "./ec2_instance"
  name           = "ec2-a"
  ami            = "ami-003c463c8207b4dfa"
  instance_type  = "t2.micro"
  subnet_id      = module.public_subnet_a.subnet_id
  security_group = module.public_sg.sg_id
  key_name       = var.ssh_key
  user_data      = file("scripts/setup-nginx.sh")
}

module "public_ec2_b" {
  source         = "./ec2_instance"
  name           = "ec2-b"
  ami            = "ami-003c463c8207b4dfa"
  instance_type  = "t2.micro"
  subnet_id      = module.public_subnet_b.subnet_id
  security_group = module.public_sg.sg_id
  key_name       = "my-server-keys"
  user_data      = file("scripts/setup-nginx.sh")
}


module "alb" {
  source                     = "./alb"
  lb_name                    = "rd-alb"
  tg_name                    = "my-tg"
  vpc_id                     = module.vpc.vpc_id
  security_group_id          = module.public_sg.sg_id
  subnet_ids                 = [module.public_subnet_a.subnet_id, module.public_subnet_b.subnet_id]
  enable_deletion_protection = false
}

resource "aws_lb_target_group_attachment" "attachment_a" {
  target_group_arn = module.alb.alb_tg_arn
  target_id        = module.public_ec2_a.instance_id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attachment_b" {
  target_group_arn = module.alb.alb_tg_arn
  target_id        = module.public_ec2_b.instance_id
  port             = 80
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

