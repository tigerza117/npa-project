resource "aws_security_group" "noice-nodegroup" {
  name   = "${var.branch_prefix} Noice EKS Nodegroup Security Group"
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "${var.branch_prefix} Noice EKS Nodegroup Security Group"
  }
}

resource "aws_security_group_rule" "noice-nodegroup-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.noice-nodegroup.id
  source_security_group_id = aws_security_group.regit-eks.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "noice-nodegroup-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.noice-nodegroup.id
  source_security_group_id = aws_security_group.regit-eks.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "noice-nodegroup-ingress-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.noice-nodegroup.id
  source_security_group_id = aws_security_group.regit-eks.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_eks_node_group" "noice-nodegroup" {
  cluster_name    = aws_eks_cluster.regit.name
  node_group_name = "${var.branch_prefix}-Noice-Nodegroup"
  node_role_arn   = "arn:aws:iam::${var.aws_account_id}:role/${var.role_name}"
  subnet_ids      = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  instance_types  = ["t3.large"]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
}
