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
