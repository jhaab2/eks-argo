module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "my-eks-cluster"
  kubernetes_version = "1.31"

  # EKS Addons
  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  endpoint_public_access  = true # Keep it false for PROD env.
  endpoint_private_access = true # This is used in cluster hardening.
  #endpoint_public_access_cidrs = ["YOUR.PC.IP.ADDR/MASK"]
  enable_cluster_creator_admin_permissions = true 
  


  eks_managed_node_groups = {
    node_group_1 = {
      instance_types = ["t3.medium"]
      #ami_type       = "AL2023_x86_64_STANDARD"

      min_size = 1
      max_size = 3
      desired_size = 1
      capacity_type  = "SPOT"
    }
  }
  tags = local.tags
}

# Create local kubeconfig 

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes = {
    host = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token = data.aws_eks_cluster_auth.cluster.token
  }
}

# INSTALL ARGOCD

resource "helm_release" "argocd" {
  name = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-cd"
  namespace = "argocd"
  create_namespace = true
  version = "9.0.0"

  depends_on = [module.eks]
}