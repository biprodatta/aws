terraform commands: 

terraform init -reconfigure -backend-config="dev.tfbackend"




eksctl utils associate-iam-oidc-provider \
    --region us-east-1 \
    --cluster mycluster \
    --approve

# Verfy EKS Cluster
eksctl get cluster

# Verify EKS Node Groups
eksctl get nodegroup --cluster=eksdemo1

# Verify if any IAM Service Accounts present in EKS Cluster
eksctl get iamserviceaccount --cluster=eksdemo1
Observation:
1. No k8s Service accounts as of now. 

# Configure kubeconfig for kubectl
eksctl get cluster # TO GET CLUSTER NAME
aws eks --region <region-code> update-kubeconfig --name <cluster_name>
aws eks --region us-east-1 update-kubeconfig --name mycluster

# Verify EKS Nodes in EKS Cluster using kubectl
kubectl get nodes

## Download latest IAM policy document
curl -o iam_policy_latest.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json

aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy_latest.json

# Replaced name, cluster and policy arn (Policy arn we took note in step-02)
eksctl create iamserviceaccount \
  --cluster=mycluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::180789647333:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve


# Get IAM Service Account
eksctl  get iamserviceaccount --cluster mycluster

# Verify if any existing service account
kubectl get sa -n kube-system
kubectl get sa aws-load-balancer-controller -n kube-system