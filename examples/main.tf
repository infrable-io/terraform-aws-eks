# -----------------------------------------------------------------------------
# AMAZON ELASTIC KUBERNETES SERVICE (EKS)
# -----------------------------------------------------------------------------
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "terraform_aws_eks" {
  source = "../../terraform-aws-eks"

  cluster_name                    = "eks-cluster"
  cluster_version                 = "1.24"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
}
