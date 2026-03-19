# -----------------------------------------------
# EC2 IAM Role — CloudWatch, SSM, S3 access
# -----------------------------------------------
resource "aws_iam_role" "ec2" {
  name = "${var.env}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = { Name = "${var.env}-ec2-role" }
}

# CloudWatch — metrics and logs
resource "aws_iam_role_policy" "ec2_cloudwatch" {
  name = "${var.env}-ec2-cloudwatch"
  role = aws_iam_role.ec2.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "cloudwatch:PutMetricData",
        "cloudwatch:GetMetricStatistics",
        "cloudwatch:ListMetrics",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ]
      Resource = "*"
    }]
  })
}

# SSM — Systems Manager access (no bastion needed)
resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# S3 — read/write to logs-backup bucket only
resource "aws_iam_role_policy" "ec2_s3" {
  name = "${var.env}-ec2-s3"
  role = aws_iam_role.ec2.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ]
      Resource = [
        var.bucket_arn,
        "${var.bucket_arn}/*"
      ]
    }]
  })
}

# Instance profile — attaches role to EC2
resource "aws_iam_instance_profile" "ec2" {
  name = "${var.env}-ec2-instance-profile"
  role = aws_iam_role.ec2.name
}

# -----------------------------------------------
# Terraform Deployment Role — EC2, VPC, IAM, RDS, S3
# -----------------------------------------------
resource "aws_iam_role" "terraform" {
  name = "${var.env}-terraform-deploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = "arn:aws:iam::${var.account_id}:root" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = { Name = "${var.env}-terraform-deploy-role" }
}

# EC2 permissions
resource "aws_iam_role_policy" "terraform_ec2" {
  name = "${var.env}-terraform-ec2"
  role = aws_iam_role.terraform.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ec2:*"
      ]
      Resource = "*"
    }]
  })
}

# VPC permissions
resource "aws_iam_role_policy" "terraform_vpc" {
  name = "${var.env}-terraform-vpc"
  role = aws_iam_role.terraform.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ec2:CreateVpc",
        "ec2:DeleteVpc",
        "ec2:ModifyVpcAttribute",
        "ec2:CreateSubnet",
        "ec2:DeleteSubnet",
        "ec2:CreateInternetGateway",
        "ec2:DeleteInternetGateway",
        "ec2:AttachInternetGateway",
        "ec2:DetachInternetGateway",
        "ec2:CreateNatGateway",
        "ec2:DeleteNatGateway",
        "ec2:CreateRouteTable",
        "ec2:DeleteRouteTable",
        "ec2:CreateRoute",
        "ec2:DeleteRoute",
        "ec2:AssociateRouteTable",
        "ec2:DisassociateRouteTable",
        "ec2:AllocateAddress",
        "ec2:ReleaseAddress",
        "ec2:CreateSecurityGroup",
        "ec2:DeleteSecurityGroup",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:AuthorizeSecurityGroupEgress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupEgress",
        "ec2:Describe*"
      ]
      Resource = "*"
    }]
  })
}

# IAM permissions (scoped to manage roles/profiles only)
resource "aws_iam_role_policy" "terraform_iam" {
  name = "${var.env}-terraform-iam"
  role = aws_iam_role.terraform.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:GetRole",
        "iam:PassRole",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:GetRolePolicy",
        "iam:CreateInstanceProfile",
        "iam:DeleteInstanceProfile",
        "iam:AddRoleToInstanceProfile",
        "iam:RemoveRoleFromInstanceProfile",
        "iam:GetInstanceProfile",
        "iam:ListAttachedRolePolicies",
        "iam:ListRolePolicies"
      ]
      Resource = "*"
    }]
  })
}

# RDS permissions
resource "aws_iam_role_policy" "terraform_rds" {
  name = "${var.env}-terraform-rds"
  role = aws_iam_role.terraform.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "rds:CreateDBInstance",
        "rds:DeleteDBInstance",
        "rds:ModifyDBInstance",
        "rds:DescribeDBInstances",
        "rds:CreateDBSubnetGroup",
        "rds:DeleteDBSubnetGroup",
        "rds:DescribeDBSubnetGroups",
        "rds:CreateDBSnapshot",
        "rds:DeleteDBSnapshot",
        "rds:DescribeDBSnapshots",
        "rds:ListTagsForResource",
        "rds:AddTagsToResource"
      ]
      Resource = "*"
    }]
  })
}

# S3 permissions
resource "aws_iam_role_policy" "terraform_s3" {
  name = "${var.env}-terraform-s3"
  role = aws_iam_role.terraform.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:CreateBucket",
        "s3:DeleteBucket",
        "s3:GetBucketPolicy",
        "s3:PutBucketPolicy",
        "s3:GetBucketVersioning",
        "s3:PutBucketVersioning",
        "s3:GetBucketPublicAccessBlock",
        "s3:PutBucketPublicAccessBlock",
        "s3:GetEncryptionConfiguration",
        "s3:PutEncryptionConfiguration",
        "s3:PutLifecycleConfiguration",
        "s3:GetLifecycleConfiguration",
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ]
      Resource = "*"
    }]
  })
}
