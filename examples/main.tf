# -----------------------------------------------------------------------------
# AMAZON ELASTIC KUBERNETES SERVICE (EKS)
# -----------------------------------------------------------------------------
provider "aws" {
  region = "us-east-1"
}

module "terraform_aws_eks" {
  source = "../../terraform-aws-eks"
}
