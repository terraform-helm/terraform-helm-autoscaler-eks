locals {
  eks_oidc_issuer_url   = var.oidc_provider != null ? var.oidc_provider : replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")
  eks_oidc_provider_arn = "arn:${data.aws_partition.this.partition}:iam::${data.aws_caller_identity.this.account_id}:oidc-provider/${local.eks_oidc_issuer_url}"
}

data "aws_partition" "this" {}
data "aws_caller_identity" "this" {}

data "aws_eks_cluster" "this" {
  name = var.cluster_id
}

data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplateVersions"
    ]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeInstanceTypes",
      "eks:DescribeNodegroup",
    ]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/${var.cluster_id}"
      values   = ["owned"]
    }
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    principals {
      type        = "Federated"
      identifiers = [local.eks_oidc_provider_arn]
    }

    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    condition {
      test     = "StringLike"
      variable = "${local.eks_oidc_issuer_url}:sub"
      values   = ["system:serviceaccount:${var.kubernetes_namespace}:${var.service_account_name}"]
    }
    condition {
      test     = "StringLike"
      variable = "${local.eks_oidc_issuer_url}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeInstanceTypes",
      "eks:DescribeNodegroup",
    ]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/${var.cluster_id}"
      values   = ["owned"]
    }
  }
}

module "helm" {
  source = "github.com/terraform-helm/terraform-helm-autoscaler"
  count  = var.install_helm ? 1 : 0
  images = var.images
  set_values = [
    {
      name  = "rbac.serviceAccount.name"
      value = var.service_account_name
    },
    {
      name  = "rbac.serviceAccount.create"
      value = "false"
    }
  ]
  values = [templatefile("${path.module}/helm/autoscaler.yaml", {
    aws_region     = "eu-west-3",
    eks_cluster_id = var.cluster_id,
    }
  )]
}

resource "kubernetes_service_account_v1" "this" {
  metadata {
    name        = var.service_account_name
    namespace   = var.kubernetes_namespace
    annotations = { "eks.amazonaws.com/role-arn" : aws_iam_role.this.arn }
  }

  dynamic "image_pull_secret" {
    for_each = var.kubernetes_svc_image_pull_secrets != null ? var.kubernetes_svc_image_pull_secrets : []
    content {
      name = image_pull_secret.value
    }
  }

  automount_service_account_token = true
}

resource "aws_iam_role" "this" {
  name                  = var.irsa_iam_role_name
  description           = "AWS IAM Role for the Kubernetes service account ${var.service_account_name}."
  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy.json
  path                  = var.irsa_iam_role_path
  force_detach_policies = true
  permissions_boundary  = var.irsa_iam_permissions_boundary
}

resource "aws_iam_policy" "this" {
  name        = var.irsa_iam_policy_name
  description = "Cluster Autoscaler IAM policy"
  policy      = data.aws_iam_policy_document.cluster_autoscaler.json
}

resource "aws_iam_role_policy_attachment" "this" {
  policy_arn = aws_iam_policy.this.arn
  role       = aws_iam_role.this.name
}
