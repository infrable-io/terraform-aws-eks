# -----------------------------------------------------------------------------
# AMAZON ELASTIC KUBERNETES SERVICE (EKS)
# This Terraform module deploys the resources necessary to run an Amazon EKS
# cluster with managed node groups.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# This module has been updated with 0.13 syntax, which means it is no longer
# compatible with any versions below 0.13.
#
# NOTE: '~>' allows only the rightmost version component to increment. For
# example, to allow new patch releases within a specific minor release, use the
# full version number: ~> 1.0.4. This will allow installation of 1.0.5 and
# 1.0.10, but not 1.1.0. This is usually called the pessimistic constraint
# operator.
# -----------------------------------------------------------------------------
terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

data "aws_region" "current" {}

# -----------------------------------------------------------------------------
# AWS KMS KEY
# This KMS key is used for encrypting Kubernetes Secrets.
#
# See the Kubernetes documentation on Secrets:
#   * https://kubernetes.io/docs/concepts/configuration/secret
# -----------------------------------------------------------------------------
resource "aws_kms_key" "eks" {
  description             = "Amazon EKS encryption key"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

# -----------------------------------------------------------------------------
# AMAZON EKS CLUSTER
# This module leverages the official Amazon EKS Terraform module to create
# an EKS cluster and managed node groups.
#
# GitHub:
#   * https://github.com/terraform-aws-modules/terraform-aws-eks
# -----------------------------------------------------------------------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.5.1"

  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  cluster_encryption_config = [{
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }]

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "Allow egress from cluster to nodes on ports 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Allow ingress from node to node for all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Allow all egress from nodes"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  # Configure EKS managed node groups
  eks_managed_node_group_defaults = {
    ami_type               = "AL2_x86_64"
    disk_size              = 50
    instance_types         = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
    vpc_security_group_ids = [aws_security_group.additional.id]
  }

  eks_managed_node_groups = {
    blue = {}
    green = {
      min_size     = 1
      max_size     = 10
      desired_size = 1

      instance_types = ["t3.small"]
      capacity_type  = "SPOT"
      labels         = {}

      taints = {
        dedicated = {
          key    = "dedicated"
          value  = "gpuGroup"
          effect = "NO_SCHEDULE"
        }
      }

      update_config = {
        max_unavailable_percentage = 50 # or set `max_unavailable`
      }

      tags = {}
    }
  }
}

# -----------------------------------------------------------------------------
# CLUSTER AUTHENTICATION
# Amazon EKS uses IAM to provide authentication to your Kubernetes cluster
# (through the `aws eks get-token` command, available in version 1.16.156 or
# later of the AWS CLI, or the AWS IAM Authenticator for Kubernetes), but it
# still relies on native Kubernetes Role Based Access Control (RBAC) for
# authorization. This means that IAM is only used for authentication of valid
# IAM entities. All permissions for interacting with your Amazon EKS cluster's
# Kubernetes API is managed through the native Kubernetes RBAC system.
#
# See the AWS documentation on cluster authentication:
#   * https://docs.aws.amazon.com/eks/latest/userguide/cluster-auth.html
#
# Access to your cluster using AWS IAM entities is enabled by the AWS IAM
# Authenticator for Kubernetes, which runs on the Amazon EKS control plane.
# The authenticator gets its configuration information from the aws-auth
# ConfigMap.
#
# See the AWS documentation on enabling IAM user and role access to your
# cluster:
#   * https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html
# -----------------------------------------------------------------------------
data "aws_eks_cluster_auth" "cluster_auth" {
  name = module.eks.cluster_id
}

locals {
  # Create initial kubeconfig file with user 'terraform' with access to the
  # Kubernetes API server.
  kubeconfig = yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = "terraform"
    clusters = [{
      name = module.eks.cluster_id
      cluster = {
        server                     = module.eks.cluster_endpoint
        certificate-authority-data = module.eks.cluster_certificate_authority_data
      }
    }]
    contexts = [{
      name = "terraform"
      context = {
        cluster = module.eks.cluster_id
        user    = "terraform"
      }
    }]
    users = [{
      name = "terraform"
      user = {
        token = data.aws_eks_cluster_auth.cluster_auth.token
      }
    }]
  })

  # NOTE: The initial aws-auth ConfigMap is generated using the IAM roles for
  # managed node groups, self-managed node groups, and Fargate profiles if they
  # exist.
  #
  # See the official Amazon EKS Terraform module for context.
  aws_auth_configmap_yaml = <<-EOT
  ${chomp(module.eks.aws_auth_configmap_yaml)}
      # - rolearn: arn:aws:iam::<aws-account>:role/<iam-role>
      #   username: system:node:{{EC2PrivateDNSName}}
      #   groups:
      #     - system:bootstrappers
      #     - system:masters
      #     - system:nodes
  EOT
}

resource "null_resource" "patch" {
  triggers = {
    kubeconfig = base64encode(local.kubeconfig)
    cmd_patch  = "kubectl patch configmap/aws-auth --patch \"${local.aws_auth_configmap_yaml}\" -n kube-system --kubeconfig <(echo $KUBECONFIG | base64 --decode)"
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
    command = self.triggers.cmd_patch
  }
}

# -----------------------------------------------------------------------------
# AMAZON VPC (CLUSTER NETWORKING)
# This module leverages the official Amazon VPC Terraform module to create
# a VPC for the EKS cluster with private and public subnets.
#
# NOTE: This VPC architecture (private and public subnets) is considered the
# best practice for common Kubernetes workloads on AWS. In this configuration,
# nodes are instantiated in the private subnets and ingress resources (like
# load balancers) are instantiated in the public subnets. This allows for
# maximum control over traffic to the nodes and works well for a majority of
# Kubernetes applications.
#
# GitHub:
#   * https://github.com/terraform-aws-modules/terraform-aws-vpc
# -----------------------------------------------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"

  azs = [
    "${data.aws_region.current.name}a",
    "${data.aws_region.current.name}b",
    "${data.aws_region.current.name}c"
  ]

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  # The following are required in order to enable private access to the
  # Kubernetes API server.
  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_flow_log                      = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true

  # The subnets are tagged so that Kubernetes is able to deploy load balancers
  # to them.
  #
  #   * Key: kubernetes.io/cluster/<cluster-name>
  #   * Value: 1
  #
  # See the AWS documentation on subnet tagging:
  #   * https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html#vpc-subnet-tagging
  #
  # When you create a Kubernetes Ingress, an AWS Application Load Balancer
  # (ALB) is provisioned that load balances application traffic. ALBs can be
  # used with Pods that are deployed to Nodes or to AWS Fargate. You can deploy
  # an ALB to public or private subnets.
  #
  # Your public and private subnets must meet the following requirements. This
  # is unless you explicitly specify subnet IDs as an annotation on a Service
  # or Ingress object. In this situation, Kubernetes and the AWS load balancer
  # controller use those subnets directly to create the load balancer and the
  # following tags aren't required.
  #
  #   Private subnets: Must be tagged in the following format. This is so that
  #   Kubernetes and the AWS load balancer controller know that the subnets can
  #   be used for internal load balancers.
  #
  #     * Key: kubernetes.io/role/internal-elb
  #     * Value: 1
  #
  #   Public subnets: Must be tagged in the following format. This is so that
  #   Kubernetes knows to use only the subnets that were specified for external
  #   load balancers. This way, Kubernetes doesn't choose a public subnet in
  #   each availability zone (lexicographically based on their subnet ID).
  #
  #     * Key: kubernetes.io/role/elb
  #     * Value: 1
  #
  # See the AWS documentation on application load balancing on Amazon EKS:
  #   * https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = 1
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = 1
  }
}

resource "aws_security_group" "additional" {
  name_prefix = "${var.cluster_name}-additional"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow ingress on port 22 (SSH) from within VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}
