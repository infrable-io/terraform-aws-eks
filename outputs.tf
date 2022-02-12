# -----------------------------------------------------------------------------
# OUTPUTS
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# EKS Cluster
# -----------------------------------------------------------------------------

output "cluster_arn" {
  value       = module.eks.cluster_arn
  description = "ARN of the EKS cluster"
}

output "cluster_certificate_authority_data" {
  value       = module.eks.cluster_certificate_authority_data
  description = <<-EOF
  Base64-encoded certificate data required to communicate with your cluster
  EOF
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "Endpoint for the Kubernetes API server"
}

output "cluster_id" {
  value       = module.eks.cluster_id
  description = "Name of the cluster"
}

output "cluster_oidc_issuer_url" {
  value       = module.eks.cluster_oidc_issuer_url
  description = "Issuer URL for the OpenID Connect identity provider"
}

output "cluster_platform_version" {
  value       = module.eks.cluster_platform_version
  description = "Platform version for the EKS cluster"
}

output "cluster_status" {
  value       = module.eks.cluster_status
  description = "Status of the EKS cluster. One of `CREATING`, `ACTIVE`, `DELETING`, `FAILED`"
}

# -----------------------------------------------------------------------------
# EKS Cluster - Security Group
# -----------------------------------------------------------------------------

output "cluster_security_group_id" {
  value       = module.eks.cluster_security_group_id
  description = <<-EOF
  EKS cluster security group that is created by Amazon EKS for the cluster.

  Managed node groups use this security group for control-plane-to-data-plane
  communication.

  This security group is referred to as the 'Cluster security group' in the
  Amazon EKS console.
  EOF
}

output "cluster_security_group_arn" {
  value       = module.eks.cluster_security_group_arn
  description = "ARN of the EKS cluster security group"
}

# -----------------------------------------------------------------------------
# EKS Cluster - IAM Role
# -----------------------------------------------------------------------------

output "cluster_iam_role_name" {
  value       = module.eks.cluster_iam_role_name
  description = <<-EOF
  EKS cluster IAM role.

  This role is used by the Kubernetes cluster managed by Amazon EKS to make
  calls to other AWS services on your behalf to manage the resources that you
  use with the service.
  EOF
}

output "cluster_iam_role_arn" {
  value       = module.eks.cluster_iam_role_arn
  description = "ARN of the EKS cluster IAM role"
}

output "cluster_iam_role_unique_id" {
  value       = module.eks.cluster_iam_role_unique_id
  description = "Stable and unique string identifying the IAM role"
}

# -----------------------------------------------------------------------------
# EKS Cluster - aws-auth ConfigMap
# -----------------------------------------------------------------------------

output "aws_auth_configmap_yaml" {
  value       = module.eks.aws_auth_configmap_yaml
  description = "Formatted YAML output of the aws-auth ConfigMap"
}

# -----------------------------------------------------------------------------
# EKS Cluster - Add-ons
# -----------------------------------------------------------------------------

output "cluster_addons" {
  value       = module.eks.cluster_addons
  description = <<-EOF
  Map of attribute maps for all enabled EKS cluster add-ons.

  For a list of available Amazon EKS add-ons, see the following documentation:
    * https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html
  EOF
}

# -----------------------------------------------------------------------------
# EKS Cluster - OIDC
# -----------------------------------------------------------------------------

output "cluster_identity_providers" {
  value       = module.eks.cluster_identity_providers
  description = "Map of attribute maps for all enabled EKS identity providers"
}

output "oidc_provider_arn" {
  value       = module.eks.oidc_provider_arn
  description = "The ARN of the OIDC provider if `enable_irsa = true`"
}

# -----------------------------------------------------------------------------
# Managed Node Groups
# -----------------------------------------------------------------------------

output "eks_managed_node_groups" {
  value       = module.eks.eks_managed_node_groups
  description = "Map of attribute maps for EKS managed node groups"
}

# -----------------------------------------------------------------------------
# Amazon CloudWatch
# -----------------------------------------------------------------------------

output "cloudwatch_log_group_arn" {
  value       = module.eks.cloudwatch_log_group_arn
  description = "ARN of CloudWatch log group"
}

output "cloudwatch_log_group_name" {
  value       = module.eks.cloudwatch_log_group_name
  description = "Name of CloudWatch log group"
}
