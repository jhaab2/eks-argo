# EKS + ArgoCD

Note: This configuration is intended for development and testing purposes only. For production-grade deployments and recommended best practices, please consult the official AWS documentation.

Prerequisites: 

    1. AWS CLI
    2. Terraform
    3. helm

```bash
cd eks-managed-node-group
terraform init
terraform plan
terraform apply --auto-approve
```

Once Argo CD is deployed, deploy the first App:

```bash
cd argo-app
kubectl apply -f argo-app.yaml
```

Access ArgoCD UI:

```bash
kubectl get ingress -n argocd
```
Open Loadbalancer URL

Get the Admin password 
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```
Login with:
Username: admin
Password: (the decoded value)

Note: These resources will cost you money. Do not forget to Run `terraform destroy` when you are done.
