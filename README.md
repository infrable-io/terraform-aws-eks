# AWS EKS Terraform Module

[![Maintained by Infrable](https://img.shields.io/badge/Maintained%20by-Infrable-000000)](https://infrable.io)

A Terraform module for configuring [Amazon Elastic Kubernetes Service (EKS)](https://aws.amazon.com/eks).

>Amazon EKS is a managed service that makes it easy for you to use Kubernetes on AWS without needing to install and operate your own Kubernetes control plane.

## Overview

This Terraform module provides an opinionated deployment of Amazon EKS. It comprises the following:
* Managed Kubernetes control plane via Amazon EKS
* Compute via managed node groups for running Kubernetes workloads
* Amazon VPC and subnets with public and private subnets (recommended)
* Authentication via AWS IAM
* Authorization via native Kubernetes Role Based Access Control (RBAC)
* AWS Application Load Balancer (ALB) for Kubernetes Ingress

## Terraform Module Documentation

<!-- BEGIN_TF_DOCS -->
## Resources

| Name | Type |
|------|------|
| [aws_kms_key.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_security_group.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [null_resource.patch](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_eks_cluster_auth.cluster_auth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_endpoint_private_access"></a> [cluster\_endpoint\_private\_access](#input\_cluster\_endpoint\_private\_access) | Whether to enable endpoint private access.<br/><br/>You can enable private access to the Kubernetes API server so that all communication between your nodes and the API server stays within your VPC.<br/><br/>When you enable endpoint private access for your cluster, Amazon EKS creates a Route 53 private hosted zone on your behalf and associates it with your cluster's VPC. This private hosted zone is managed by Amazon EKS, and it doesn't appear in your account's Route 53 resources. In order for the private hosted zone to properly route traffic to your API server, your VPC must have enableDnsHostnames and enableDnsSupport set to true, and the DHCP options set for your VPC must include AmazonProvidedDNS in its domain name servers list.<br/><br/>See the AWS documentation on Amazon EKS cluster endpoint access control:<br/>  * https://docs.aws.amazon.com/eks/latest/userguide/cluster-auth.html | `bool` | `false` | no |
| <a name="input_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#input\_cluster\_endpoint\_public\_access) | Whether to enable endpoint public access.<br/><br/>By default, the Kubernetes API server endpoint server endpoint is public to the internet, and access to the API server is secured using a combination of AWS Identity and Access Management (IAM) and native Kubernetes Role Based Access Control (RBAC).<br/><br/>See the AWS documentation on Amazon EKS cluster endpoint access control:<br/>  * https://docs.aws.amazon.com/eks/latest/userguide/cluster-auth.html | `bool` | `true` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `string` | `""` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Version of Kubernetes to use for the EKS cluster (ex. 1.24).<br/><br/>For a list of available versions, see the following documentation:<br/>  * https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_auth_configmap_yaml"></a> [aws\_auth\_configmap\_yaml](#output\_aws\_auth\_configmap\_yaml) | Formatted YAML output of the aws-auth ConfigMap |
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | ARN of CloudWatch log group |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | Name of CloudWatch log group |
| <a name="output_cluster_addons"></a> [cluster\_addons](#output\_cluster\_addons) | Map of attribute maps for all enabled EKS cluster add-ons.<br/><br/>For a list of available Amazon EKS add-ons, see the following documentation:<br/>  * https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html |
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | ARN of the EKS cluster |
| <a name="output_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#output\_cluster\_certificate\_authority\_data) | Base64-encoded certificate data required to communicate with your cluster |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint for the Kubernetes API server |
| <a name="output_cluster_iam_role_arn"></a> [cluster\_iam\_role\_arn](#output\_cluster\_iam\_role\_arn) | ARN of the EKS cluster IAM role |
| <a name="output_cluster_iam_role_name"></a> [cluster\_iam\_role\_name](#output\_cluster\_iam\_role\_name) | EKS cluster IAM role.<br/><br/>This role is used by the Kubernetes cluster managed by Amazon EKS to make calls to other AWS services on your behalf to manage the resources that you use with the service. |
| <a name="output_cluster_iam_role_unique_id"></a> [cluster\_iam\_role\_unique\_id](#output\_cluster\_iam\_role\_unique\_id) | Stable and unique string identifying the IAM role |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | Name of the cluster |
| <a name="output_cluster_identity_providers"></a> [cluster\_identity\_providers](#output\_cluster\_identity\_providers) | Map of attribute maps for all enabled EKS identity providers |
| <a name="output_cluster_oidc_issuer_url"></a> [cluster\_oidc\_issuer\_url](#output\_cluster\_oidc\_issuer\_url) | Issuer URL for the OpenID Connect identity provider |
| <a name="output_cluster_platform_version"></a> [cluster\_platform\_version](#output\_cluster\_platform\_version) | Platform version for the EKS cluster |
| <a name="output_cluster_security_group_arn"></a> [cluster\_security\_group\_arn](#output\_cluster\_security\_group\_arn) | ARN of the EKS cluster security group |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | EKS cluster security group that is created by Amazon EKS for the cluster.<br/><br/>Managed node groups use this security group for control-plane-to-data-plane communication.<br/><br/>This security group is referred to as the 'Cluster security group' in the Amazon EKS console. |
| <a name="output_cluster_status"></a> [cluster\_status](#output\_cluster\_status) | Status of the EKS cluster. One of `CREATING`, `ACTIVE`, `DELETING`, `FAILED` |
| <a name="output_eks_managed_node_groups"></a> [eks\_managed\_node\_groups](#output\_eks\_managed\_node\_groups) | Map of attribute maps for EKS managed node groups |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | The ARN of the OIDC provider if `enable_irsa = true` |
<!-- END_TF_DOCS -->
