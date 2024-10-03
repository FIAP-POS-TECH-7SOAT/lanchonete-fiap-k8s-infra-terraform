terraform {
  required_version = "1.9.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.63.0"
    }
  }
  backend "s3" {}
}

data "aws_iam_role" "eks_cluster_role" {
  name = "LabRole"
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  token      = var.aws_session_token
}


resource "aws_eks_cluster" "lanchonete-fiap-cluster" {

  name     = var.cluster_name
  role_arn = data.aws_iam_role.eks_cluster_role.arn
  tags = {
    Description = "EKS"
    
  }

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_public_access  = true
    endpoint_private_access = true
  }

}

resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = var.cluster_name
  subnet_ids      = var.subnet_ids
  node_role_arn   = data.aws_iam_role.eks_cluster_role.arn
  node_group_name = "${var.cluster_name}-node-group"
  instance_types  = [var.node_instance_type]

  scaling_config {
    desired_size = var.desired_capacity
    max_size     = var.max_size_capacity
    min_size     = var.min_size_capacity
  }

  depends_on = [aws_eks_cluster.lanchonete-fiap-cluster]
}
