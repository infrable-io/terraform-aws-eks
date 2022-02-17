# VPC and subnet considerations

Amazon EKS recommends running a cluster in a VPC with public and private subnets so that Kubernetes can create public load balancers in the public subnets that load balance traffic to Pods running on nodes that are in private subnets. This configuration is not required, however. You can run a cluster in a VPC with only private or only public subnets, depending on your networking and security requirements.

When you create an Amazon EKS cluster, you specify the VPC subnets where Amazon EKS can place elastic network interfaces. Amazon EKS requires subnets in at least two Availability Zone, and creates up to four network interfaces across these subnets to facilitate control plane communication to your nodes. This communication channel supports Kubernetes functionality such as `kubectl exec` and `kubectl logs`. The Amazon EKS created [cluster security group](https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html#cluster-sg) and any additional security groups that you specify when you create your cluster are applied to these network interfaces. Each Amazon EKS created network interface has Amazon EKS `<cluster-name>` in its description.

Make sure that the subnets that you specify during cluster creation have enough available IP addresses for the Amazon EKS created network interfaces. If you're going to deploy a cluster that uses the IPv4 family, we recommend creating small (`/28`), dedicated subnets for Amazon EKS created network interfaces, and only specifying these subnets as part of cluster creation. Other resources, such as nodes and load balancers, should be launched in separate subnets from the subnets specified during cluster creation.

**IMPORTANT**

* Nodes and load balancers can be launched in any subnet in your cluster's VPC, including subnets not registered with Amazon EKS during cluster creation. Subnets do not require any tags for nodes. For Kubernetes load balancing auto discovery to work, subnets must be tagged as described in [subnet tagging](https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html#vpc-subnet-tagging).

* Subnets associated with your cluster cannot be changed after cluster creation. If you need to control exactly which subnets the Amazon EKS created network interfaces are placed in, then specify only two subnets during cluster creation, each in a different Availability Zone.

* Clusters created using v1.14 or earlier contain a `kubernetes.io/cluster/<cluster-name>` tag on your VPC. This tag was only used by Amazon EKS and can be safely removed.

* Nodes must be able to communicate with the control plane and other AWS services. If your nodes are deployed in a private subnet and you want Pods to have outbound access to the internet, then the private subnet must meet one of the following requirements:
  * Subnets with only IPv4 CIDR blocks must have a default route to a [NAT gateway](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html). The NAT gateway must be assigned a public IPv4 address to provide internet access for the nodes.
  * Subnets with IPv6 CIDR blocks must have a default route to an [egress-only internet gateway](https://docs.aws.amazon.com/vpc/latest/userguide/egress-only-internet-gateway.html).

**NOTE**: Your VPC must have DNS hostname and DNS resolution support, or your nodes can't register with your cluster.

## VPC IP addressing

If you want Pods deployed to nodes in public subnets to have outbound internet access, then your public subnets must be configured to auto-assign public IPv4 addresses or IPv6 addresses.

## Subnet tagging

For 1.18 and earlier clusters, Amazon EKS adds the following tag to all subnets passed in during cluster creation. Amazon EKS does not add the tag to subnets passed in when creating 1.19 clusters. If the tag exists on subnets used by a cluster created on a version earlier than 1.19, and you update the cluster to 1.19, the tag is not removed from the subnets.
* **Key**: `kubernetes.io/cluster/<cluster-name>`
* **Value**:`shared`

You can optionally use this tag to control where Elastic Load Balancers are provisioned, in addition to the required subnet tags for using automatically provisioned Elastic Load Balancers. For more information about load balancer subnet tagging, see [Application load balancing on Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html) and [Network load balancing on Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/network-load-balancing.html).
