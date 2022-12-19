data "aws_iam_policy_document" "this" {
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

module "role_sa" {
  source        = "github.com/littlejo/terraform-aws-role-eks.git?ref=v0.1"
  name          = var.irsa_iam_role_name
  inline_policy = data.aws_iam_policy_document.this.json
  cluster_id    = var.cluster_id
  create_sa     = true
  service_accounts = {
    main = {
      name      = var.service_account_name
      namespace = var.kubernetes_namespace
    }
  }
}

module "helm" {
  source          = "github.com/terraform-helm/terraform-helm-autoscaler?ref=v0.1.1"
  count           = var.install_helm ? 1 : 0
  release_version = var.release_version
  images          = var.images
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
    aws_region     = var.region,
    eks_cluster_id = var.cluster_id,
    }
  )]
}
