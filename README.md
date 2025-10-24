# EKS + ArgoCD

Note: This configuration is intended for development and testing purposes only. For production-grade deployments and recommended best practices, please consult the official AWS documentation.

Prerequisites: 

    1. AWS CLI
    2. Terraform
    3. helm

```bash
$ cd eks-managed-node-group
$ terraform init
$ terraform plan
$ terraform apply --auto-approve
```

Once your EKS is up and running, deploy ArgoCD:

```bash
$ kubectl create namespace argocd
$ helm repo add argo https://argoproj.github.io/argo-helm
$ helm repo update
$ helm install argocd argo/argo-cd -n argocd
$ kubectl get pods -n argocd
```

Once Argo CD is deployed, access your UI and deploy k8s manifests:

```bash
$ kubectl port-forward svc/argocd-server -n argocd 8080:443
```
Open https://localhost:8080

Get the Admin password 
```bash
$ kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```
Login with:
Username: admin
Password: (the decoded value)

```bash
cd argo-k8s
kubectl apply -f argo-app.yaml
```

Note: These resources will cost you money. Do not forget to Run `terraform destroy` when you are done.
