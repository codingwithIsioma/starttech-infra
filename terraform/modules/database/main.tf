# ============================================================
# SECTION: ELASTIC CACHE
# ============================================================

# Single-node Redis cache for the backend, placed in the private subnets
resource "aws_elasticache_cluster" "redis-cluster" {
  cluster_id         = "starttech-redis"
  engine             = "redis"
  node_type          = "cache.t3.micro"
  num_cache_nodes    = 1
  port               = 6379
  security_group_ids = [aws_security_group.redis-cluster-sg.id]
  subnet_group_name  = aws_elasticache_subnet_group.redis-cluster-subnet-group.name

  tags = {
    Name = "${var.project_name}-redis"
  }
}

# Tells ElastiCache which (private) subnets it may place Redis nodes in
resource "aws_elasticache_subnet_group" "redis-cluster-subnet-group" {
  name       = "${var.project_name}-redis-cluster-subnet"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-redis-subnet-group"
  }
}

# Security group - only the EKS worker nodes can reach Redis on port 6379
resource "aws_security_group" "redis-cluster-sg" {
  name        = "${var.project_name}-redis-cluster-sg"
  description = "Allow 6379 inbound traffic from EKS Nodes only and all outbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow 6379 traffic from EKS nodes"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.worker_node_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-redis-sg"
  }
}
