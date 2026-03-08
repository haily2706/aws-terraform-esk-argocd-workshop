# terraform/main.tf
# ─────────────────────────────────────────────────────────────────
# Creates: VPC (public only) + EKS Cluster + Spot Node Group
# Cost: ~$0.12/hour ($0.10 control plane + $0.013 spot node)
# ─────────────────────────────────────────────────────────────────

# =====================================================================
# DATA: Discover available AZs in the region
# =====================================================================
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]   # ← only standard AZs, not opt-in
  }
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
  #            ↑ take first 2 AZs (e.g., us-east-1a, us-east-1b)
  #            EKS requires at least 2 AZs for the control plane
}

# =====================================================================
# VPC: Public subnets only (no NAT Gateway = saves $1.08/day)
# =====================================================================
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"

  azs            = local.azs
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  #                  ↑ Two public subnets, one per AZ

  # ❌ NO private subnets — no NAT Gateway needed
  enable_nat_gateway = false

  # DNS settings (required for EKS)
  enable_dns_hostnames = true
  enable_dns_support   = true

  # ⚠️ CRITICAL: Nodes need public IPs to reach the internet
  map_public_ip_on_launch = true

  # Tags that EKS uses to discover subnets for load balancers
  public_subnet_tags = {
    "kubernetes.io/role/elb"                            = 1
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  tags = {
    Environment = "workshop"
    Terraform   = "true"
  }
}

# =====================================================================
# EKS CLUSTER
# =====================================================================
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.cluster_version

  # ── Access ──────────────────────────────────────────────────────
  endpoint_public_access = true
  #   ↑ Makes the K8s API reachable from your laptop.
  #     For production, restrict with cluster_endpoint_public_access_cidrs.

  # ⚠️ CRITICAL: Grants your IAM user admin access to the cluster
  enable_cluster_creator_admin_permissions = true
  #   ↑ Without this, you can't run kubectl after cluster creation!

  # ── Add-ons (minimum required set) ─────────────────────────────
  addons = {
    coredns = {                         # ← DNS resolution inside cluster
      most_recent = true
    }
    kube-proxy = {                      # ← Service networking (iptables)
      most_recent = true
    }
    vpc-cni = {                         # ← Pod networking (assigns IPs)
      most_recent    = true
      before_compute = true             # ← Install BEFORE nodes join
    }
    eks-pod-identity-agent = {          # ← IAM roles for pods
      most_recent    = true
      before_compute = true
    }
    aws-ebs-csi-driver = {             # ← EBS volume provisioning for PVCs
      most_recent              = true
      service_account_role_arn = module.ebs_csi_irsa.iam_role_arn
    }
  }

  # ── Network ────────────────────────────────────────────────────
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets
  #              ↑ Nodes go in public subnets (no NAT needed)

  # ── Managed Node Group ─────────────────────────────────────────
  eks_managed_node_groups = {
    workshop = {
      ami_type = "AL2023_x86_64_STANDARD"
      #           ↑ Amazon Linux 2023 — default for EKS 1.30+

      instance_types = ["t3.medium", "t3a.medium"]
      #                  ↑ Multiple types = better spot availability
      #                  t3a.medium is ~10% cheaper (AMD)

      capacity_type = "SPOT"
      #                ↑ THE KEY SETTING — 70% cheaper than on-demand

      min_size     = 1                  # ← minimum 1 node always running
      max_size     = 2                  # ← can scale to 2 if needed
      desired_size = 1                  # ← start with 1 node

      labels = {
        role = "workshop"
      }
    }
  }

  tags = {
    Environment = "workshop"
    Terraform   = "true"
  }
}

# =====================================================================
# IAM ROLE: EBS CSI Driver (IRSA)
# =====================================================================
module "ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name             = "${var.cluster_name}-ebs-csi"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = {
    Environment = "workshop"
    Terraform   = "true"
  }
}