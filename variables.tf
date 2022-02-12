# -----------------------------------------------------------------------------
# VARIABLES
# -----------------------------------------------------------------------------

variable "cluster_name" {
  type        = string
  default     = ""
  description = "Name of the EKS cluster"
}

variable "cluster_version" {
  type        = string
  default     = null
  description = <<-EOF
  Version of Kubernetes to use for the EKS cluster (ex. 1.21).

  For a list of available versions, see the following documentation:
    * https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html
  EOF
}

variable "cluster_endpoint_private_access" {
  type        = bool
  default     = false
  description = <<-EOF
  Whether to enable endpoint private access.

  You can enable private access to the Kubernetes API server so that all
  communication between your nodes and the API server stays within your VPC.

  When you enable endpoint private access for your cluster, Amazon EKS creates
  a Route 53 private hosted zone on your behalf and associates it with your
  cluster's VPC. This private hosted zone is managed by Amazon EKS, and it
  doesn't appear in your account's Route 53 resources. In order for the private
  hosted zone to properly route traffic to your API server, your VPC must have
  enableDnsHostnames and enableDnsSupport set to true, and the DHCP options set
  for your VPC must include AmazonProvidedDNS in its domain name servers list.

  See the AWS documentation on Amazon EKS cluster endpoint access control:
    * https://docs.aws.amazon.com/eks/latest/userguide/cluster-auth.html
  EOF
}

variable "cluster_endpoint_public_access" {
  type        = bool
  default     = true
  description = <<-EOF
  Whether to enable endpoint public access.

  By default, the Kubernetes API server endpoint server endpoint is public to
  the internet, and access to the API server is secured using a combination of
  AWS Identity and Access Management (IAM) and native Kubernetes Role Based
  Access Control (RBAC).

  See the AWS documentation on Amazon EKS cluster endpoint access control:
    * https://docs.aws.amazon.com/eks/latest/userguide/cluster-auth.html
  EOF
}
