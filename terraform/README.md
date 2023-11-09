# terraform commands from begining: 

terraform init -reconfigure -backend-config="dev.tfbackend"
terraform plan --var-file="dev.tfvars"
terraform apply --var-file="dev.tfvars"
alias k=kubectl
aws eks --region us-east-2 update-kubeconfig --name mycluster
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"

eksctl utils associate-iam-oidc-provider \
    --region us-east-2 \
    --cluster mycluster \
    --approve

## create role and sa:
eksctl create iamserviceaccount \
  --cluster=mycluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::648667311034:policy/aws_alb_controller_policy \
  --override-existing-serviceaccounts \
  --approve

## install aws-load-balancer-controller:
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=mycluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-2 \
  --set vpcId=vpc-09a08aefd36ba285a \
  --set image.repository=602401143452.dkr.ecr.us-east-2.amazonaws.com/amazon/aws-load-balancer-controller

( docker image ecr repo URl is based on your region, find repo url as per your region from here:
https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html )

### you should see the same iam role created in postal
eksctl get iamserviceaccount --cluster=mycluster
### you should see the service account named aws-load-balancer-controller
kubectl get sa -n kube-system
### you should see two pods running with name starting aws-load-balancer-controller-****
kubectl get pods -n kube-system

## tag your private subnets with below:
key: kubernetes.io/role/internal-elb value: 1
key: kubernetes.io/cluster/${your-cluster-name} value:  shared (if the subnet is used for other aws resources) owned (if the subnet is dedicated to eks only)
## tag your public subnets with below:
key: kubernetes.io/role/elb value: 1
key: kubernetes.io/cluster/${your-cluster-name} value:  shared (if the subnet is used for other aws resources) owned (if the subnet is dedicated to eks only)

run the manifest file for your application using kubectl apply -f abc.yaml


# delete EKS cluster:

eksctl delete iamserviceaccount --cluster mycluster --name aws-load-balancer-controller --namespace=kube-system
(if it doesnt delete the Cloudformation stack then delete that manually from aws console, it will delete the iam role)
helm uninstall aws-load-balancer-controller -n kube-system
terraform destroy --var-file="dev.tfvars"


### Download latest IAM policy document
curl -o iam_policy_latest.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json


# install Kubergrunt in mac
brew install kubergrunt

kubergrunt eks oidc-thumbprint --issuer-url https://oidc.eks.us-east-2.amazonaws.com/id/EDB102942B5238492E4748A970E6F11A
