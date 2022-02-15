# Create or update a kubeconfig file for Amazon EKS

## What is a kubeconfig file?

You use kubeconfig files to organize information about clusters, users, namespaces, and authentication mechanisms. The `kubectl` command-line tool uses kubeconfig files to find the information it needs to choose a cluster and communicate with the API server of a cluster.

**NOTE**: A file that is used to configure access to clusters is called a *kubeconfig file*. This is a generic way of referring to configuration files. It does not mean that there is a file named `kubeconfig`.

By default, `kubectl` looks for a file named `config` in the `$HOME/.kube` directory. You can specify other kubeconfig files by setting the `KUBECONFIG` environment variable or by setting the `--kubeconfig` flag.

## Create or update your kubeconfig file

In order to interact with the Kubernetes API server using `kubectl`, you must create a `kubeconfig` file for your cluster (or update an existing one).

There are two methods for creating or updating your kubeconfig file for Amazon EKS:
1. Automatically using the AWS CLI (`update-kubeconfig` command)
2. Manually using the AWS CLI or the `aws-iam-authenticator`

Amazon EKS uses the `aws eks get-token` command with `kubectl` for cluster authentication. If you have the AWS CLI installed on your system, then by default the AWS IAM Authenticator for Kubernetes uses the same credentials that are returned with the following command:

```bash
aws sts get-caller-identity
```

## Create or update your kubeconfig file automatically

**Method 1**: Automatically using the AWS CLI (`update-kubeconfig` command)

1. Ensure that you have version 1.16.156 or later of the AWS CLI installed.

**NOTE**: You must be using Python version 2.7.9 or later, otherwise, you will receive `hostname doesn't match` errors when making calls to Amazon EKS.

2. Create or update your kubeconfig file for your cluster.

   ```bash
   aws eks update-kubeconfig --name <cluster-name>
   ```

**Additional Considerations**
* By default, the resulting configuration file is created at the default kubeconfig file location (`.kube/config`) in your home directory or merged with an existing kubeconfig file at that location. You can specify another path with the `--kubeconfig` option.
* You can specify an IAM role ARN to use for authentication with the `--role-arn` option when you issue `kubectl` commands. Otherwise, the IAM entity in your default AWS CLI or SDK credential chain is used. You can view your default AWS CLI or SDK identity by running the `aws sts get-caller-identity` command.
* To run the `update-kubeconfig` command, you must have permission to use the `eks:DescribeCluster` API action with the cluster that you specify.

3. Test your configuration.

   ```bash
   kubectl get svc
   ```

## Create or update your kubeconfig file manually

**Method 2**: Manually using the AWS CLI or the `aws-iam-authenticator`

1. Retrieve the endpoint for your cluster.

   ```bash
   aws eks describe-cluster \
     --region <region> \
     --name <cluster-name> \
     --query "cluster.endpoint" \
     --output text
   ```

2. Retrieve the Base64-encoded certificate data required to communicate with your cluster.

   ```bash
   aws eks describe-cluster \
     --region <region> \
     --name <cluster-name> \
     --query "cluster.certificateAuthority.data" \
     --output text
   ```

3. Create or update your kubeconfig file (`$HOME/.kube/config`) with the following contents:

   **AWS CLI (`aws eks get-token`)**

   ```yaml
   apiVersion: v1
   clusters:
   - cluster:
       server: <cluster.endpoint>
       certificate-authority-data: <cluster.certificateAuthority.data>
     name: kubernetes
   contexts:
   - context:
       cluster: kubernetes
       user: aws
     name: aws
   current-context: aws
   kind: Config
   preferences: {}
   users:
   - name: aws
     user:
       exec:
         apiVersion: client.authentication.k8s.io/v1alpha1
         command: aws
         args:
           - "eks"
           - "get-token"
           - "--cluster-name"
           - <cluster-name>
           # - "--role-arn"
           # - "role-arn"
         # env:
           # - name: AWS_PROFILE
           #   value: "aws-profile"
   ```

   **[AWS IAM authenticator for Kubernetes](https://github.com/kubernetes-sigs/aws-iam-authenticator)**

   ```yaml
   apiVersion: v1
   clusters:
   - cluster:
       server: <cluster.endpoint>
       certificate-authority-data: <cluster.certificateAuthority.data>
     name: kubernetes
   contexts:
   - context:
       cluster: kubernetes
       user: aws
     name: aws
   current-context: aws
   kind: Config
   preferences: {}
   users:
   - name: aws
     user:
       exec:
         apiVersion: client.authentication.k8s.io/v1alpha1
         command: aws-iam-authenticator
         args:
           - "token"
           - "-i"
           - <cluster-name>
           # - "-r"
           # - "role-arn"
         # env:
           # - name: AWS_PROFILE
           #   value: "aws-profile"
   ```

**NOTE**: Replace `<cluster.endpoint>` and `<cluster.certificateAuthority.data>` with the values retrieved in the previous step. Replace `<cluster-name>` with the name of your cluster.

**Using a non-default kubeconfig file**

If you want to add the configuration for your EKS cluster to a separate, non-default kubeconfig file, simply write the file to a non-default location and update your `KUBECONFIG` environment variable accordingly.

To ensure changes to your `KUBECONFIG` environment variable persistent between sesssion, update your shell initialization file:

```bash
export KUBECONFIG=$KUBECONFIG:~/.kube/<cluster>
```

3. Test your configuration.

   ```bash
   kubectl get svc
   ```
