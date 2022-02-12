# -----------------------------------------------------------------------------
# AMAZON ELASTIC KUBERNETES SERVICE (EKS)
# -----------------------------------------------------------------------------
provider "aws" {
  region = "us-east-1"
}

module "terraform_aws_eks" {
  source = "../../terraform-aws-eks"

  cluster_name                    = "eks-cluster"
  cluster_version                 = "1.21"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
}
