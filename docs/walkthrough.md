# Walkthrough

This guide provides a comprehensive walkthrough for creating, managing, and operating a Kubernetes cluster on Amazon EKS.

The following sections provide a brief overview of each topic with references to supporting documentation in `walkthrough/`.

## Table of Contents
* [Cluster Authentication](#cluster-authentication)

## Cluster Authentication

Amazon EKS uses IAM to provide authentication to your Kubernetes cluster. This is accomplished using the `aws eks get-token` command (AWS CLI version 1.16.156 or later) or the  [AWS IAM Authenticator for Kubernetes](https://github.com/kubernetes-sigs/aws-iam-authenticator)). However, Amazon EKS still relies on native Kubernetes [Role Based Access Control](https://kubernetes.io/docs/admin/authorization/rbac) (RBAC) for authorization. This means that IAM is only used for authentication of valid IAM entities. All permissions for interacting with your Amazon EKS cluster's Kubernetes API is managed through the native Kubernetes RBAC system. The following picture shows this relationship.

[Cluster Authentication](img/cluster-authentication.png)

**Topics**
* [Create or update a kubeconfig file for Amazon EKS](/walkthrough/cluster-authentication/create-or-update-a-kubeconfig-file-for-amazon-eks.md)
