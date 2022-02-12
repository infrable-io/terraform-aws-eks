# AWS EKS Terraform Module

[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/infrable-io/terraform-aws-eks/blob/master/LICENSE)
[![Maintained by Infrable](https://img.shields.io/badge/Maintained%20by-Infrable-000000)](https://infrable.io)

A Terraform module for creating, managing, and operating a Kubernetes cluster on [Amazon Elastic Kubernetes Service (EKS)](https://aws.amazon.com/eks).

> Amazon EKS is a managed service that makes it easy for you to use Kubernetes on AWS without needing to install and operate your own Kubernetes control plane.

## Overview

This Terraform module provides an opinionated deployment of Amazon EKS. It comprises the following:
* Managed Kubernetes control plane via Amazon EKS
* Compute via managed node groups for running Kubernetes workloads
* Amazon VPC and subnets with public and private subnets (recommended)
* Authentication via AWS IAM
* Authorization via native Kubernetes Role Based Access Control (RBAC)
* AWS Application Load Balancer (ALB) for Kubernetes Ingress
* Amazon EKS add-ons (CoreDNS, kube-proxy, and Amazon VPC CNI)
