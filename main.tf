# -----------------------------------------------------------------------------
# AMAZON ELASTIC KUBERNETES SERVICE (EKS)
# This Terraform module deploys the resources necessary to run an Amazon EKS
# cluster.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# This module has been updated with 0.12 syntax, which means it is no longer
# compatible with any versions below 0.12.
# -----------------------------------------------------------------------------
terraform {
  required_version = ">= 0.12"
}
