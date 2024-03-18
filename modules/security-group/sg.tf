resource "aws_security_group" "balancers_sg" {
  name_prefix = var.balancers_sg_name
  vpc_id      = var.vpc_id
  description = var.balancers_sg_description

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "eks_cluster_sg" {
  name_prefix = var.eks_cluster_sg_name
  description = var.eks_cluster_sg_description
  vpc_id      = var.vpc_id

  ingress {
    description     = "Custom TCP on port 3000"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.balancers_sg.id]
  }

  egress {
    description = "All traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
