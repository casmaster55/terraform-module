# provider "aws" {
#   region = "your-aws-region"
# }

resource "aws_vpc" "kubernetes_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "kubernetes_subnet" {
  vpc_id     = aws_vpc.kubernetes_vpc.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_security_group" "kubernetes_sg" {
  name        = "kubernetes_sg"
  description = "Security group for Kubernetes cluster"

  vpc_id = aws_vpc.kubernetes_vpc.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "kubernetes_cluster" {
  source = "github.com/kubernetes/terraform-aws-kubernetes//modules/cluster"

  cluster_name             = "my-kubernetes-cluster"
  cluster_node_instance_type = "t2.micro"
  cluster_node_count        = 3

  vpc_id              = aws_vpc.kubernetes_vpc.id
  subnet_ids          = [aws_subnet.kubernetes_subnet.id]
  security_group_ids  = [aws_security_group.kubernetes_sg.id]
}