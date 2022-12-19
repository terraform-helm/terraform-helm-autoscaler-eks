<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.47.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_helm"></a> [helm](#module\_helm) | github.com/terraform-helm/terraform-helm-autoscaler | v0.1.1 |
| <a name="module_role_sa"></a> [role\_sa](#module\_role\_sa) | github.com/littlejo/terraform-aws-role-eks.git | v0.1 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | EKS cluster name | `string` | n/a | yes |
| <a name="input_images"></a> [images](#input\_images) | Map of images | <pre>object({<br>    main = optional(string)<br>  })</pre> | <pre>{<br>  "main": null<br>}</pre> | no |
| <a name="input_install_helm"></a> [install\_helm](#input\_install\_helm) | Do you want to install helm chart? | `bool` | `true` | no |
| <a name="input_irsa_iam_role_name"></a> [irsa\_iam\_role\_name](#input\_irsa\_iam\_role\_name) | IAM role name for IRSA | `string` | `"eks-autoscaler"` | no |
| <a name="input_kubernetes_namespace"></a> [kubernetes\_namespace](#input\_kubernetes\_namespace) | Namespace to install autoscaler pod | `string` | `"kube-system"` | no |
| <a name="input_region"></a> [region](#input\_region) | Region of you eks cluster | `string` | n/a | yes |
| <a name="input_release_version"></a> [release\_version](#input\_release\_version) | version of helm release | `string` | `null` | no |
| <a name="input_service_account_name"></a> [service\_account\_name](#input\_service\_account\_name) | Name of the service account to have right to autoscale your cluster | `string` | `"cluster-autoscaler-sa"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->