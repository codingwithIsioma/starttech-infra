# ============================================================
# SECTION: ELASTIC KUBERNETES SERVICE
# ============================================================
# =============================
# Cluster
# =============================
resource "aws_eks_cluster" "control_plane" {
  name     = "starttech-cluster"
  version  = "1.35"
  role_arn = aws_iam_role.control_plane_role.arn
  vpc_config {
    subnet_ids = var.private_subnet_ids
  }
  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [aws_iam_role_policy_attachment.control-plane-AmazonEKSClusterPolicy]
}

# Control Plane IAM Policies
resource "aws_iam_role" "control_plane_role" {
  name = "${var.project_name}-control-plane-iam-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "control-plane-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.control_plane_role.name
}

# ==============================
# Worker Nodes
# ==============================
resource "aws_eks_node_group" "worker_nodes" {
  cluster_name    = aws_eks_cluster.control_plane.name
  node_group_name = "starttech-node-group"
  node_role_arn   = aws_iam_role.worker_nodes_role.arn
  subnet_ids      = var.private_subnet_ids
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 2
  }
  instance_types = ["t3.medium"]

  depends_on = [aws_iam_role_policy_attachment.worker-node-AmazonEC2ContainerRegistryReadOnly, aws_iam_role_policy_attachment.worker-node-AmazonEKS_CNI_Policy, aws_iam_role_policy_attachment.worker-node-AmazonEKSWorkerNodePolicy]
}

# Worker Node IAM Policies
resource "aws_iam_role" "worker_nodes_role" {
  name = "${var.project_name}-node-group-iam-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "worker-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker_nodes_role.name
}
resource "aws_iam_role_policy_attachment" "worker-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker_nodes_role.name
}
resource "aws_iam_role_policy_attachment" "worker-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker_nodes_role.name
}


# ==============================
# SECTION: CLUSTER ACCESS, OIDC AND CONTROLLER IAM ROLE
# ==============================

# OIDC provider - lets Kubernetes service accounts assume IAM roles
data "tls_certificate" "eks" {
  url = aws_eks_cluster.control_plane.identity[0].oidc[0].issuer
}

locals {
  oidc_host = replace(aws_eks_cluster.control_plane.identity[0].oidc[0].issuer, "https://", "")
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  url             = aws_eks_cluster.control_plane.identity[0].oidc[0].issuer
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
}

# Role only the controller's service account can assume
resource "aws_iam_role" "lb_controller" {
  name = "${var.project_name}-lb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRoleWithWebIdentity"
      Principal = { Federated = aws_iam_openid_connect_provider.eks.arn }
      Condition = {
        StringEquals = {
          "${local.oidc_host}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          "${local.oidc_host}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "lb_controller" {
  name   = "${var.project_name}-lb-controller-policy"
  policy = file("${path.module}/iam_policy.json")
}

resource "aws_iam_role_policy_attachment" "lb_controller" {
  role       = aws_iam_role.lb_controller.name
  policy_arn = aws_iam_policy.lb_controller.arn
}

# ==============================
# SECTION: ALB CONTROLLER
# ==============================

# Install the alb controller with Helm
resource "helm_release" "lb_controller" {
  name            = "aws-load-balancer-controller"
  repository      = "https://aws.github.io/eks-charts"
  chart           = "aws-load-balancer-controller"
  namespace       = "kube-system"
  wait            = true
  atomic          = true
  cleanup_on_fail = true

  set = [
    { name = "clusterName", value = aws_eks_cluster.control_plane.name },
    { name = "region", value = var.aws_region },
    { name = "vpcId", value = var.vpc_id },
    { name = "serviceAccount.name", value = "aws-load-balancer-controller" },
    { name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn", value = aws_iam_role.lb_controller.arn },
  ]

  depends_on = [aws_eks_node_group.worker_nodes, aws_iam_role_policy_attachment.lb_controller]
}

# Create the base Ingress that creates the ALB
resource "kubernetes_ingress_v1" "alb_base" {
  metadata {
    name      = "${var.project_name}-alb-base"
    namespace = "default"
    annotations = {
      "alb.ingress.kubernetes.io/scheme"             = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"        = "ip"
      "alb.ingress.kubernetes.io/group.name"         = "starttech"
      "alb.ingress.kubernetes.io/load-balancer-name" = "starttech-alb"
      "alb.ingress.kubernetes.io/actions.default-404" = jsonencode({
        type = "fixed-response"
        fixedResponseConfig = {
          contentType = "text/plain"
          statusCode  = "404"
          messageBody = "not found"
        }
      })
    }
  }
  spec {
    ingress_class_name = "alb"
    default_backend {
      service {
        name = "default-404"
        port {
          name = "use-annotation"
        }
      }
    }
  }
  wait_for_load_balancer = true
  depends_on             = [helm_release.lb_controller]
}
