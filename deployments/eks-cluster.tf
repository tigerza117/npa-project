resource "aws_security_group" "regit-eks" {
  name   = "${var.branch_prefix} Regit EKS Security Group"
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.branch_prefix} Regit EKS Security Group"
  }
}

resource "aws_eks_cluster" "regit" {
  name     = "${var.branch_prefix}-Regit"
  role_arn = "arn:aws:iam::${var.aws_account_id}:role/${var.role_name}"

  vpc_config {
    security_group_ids = [aws_security_group.regit-eks.id]
    subnet_ids         = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  }
}
