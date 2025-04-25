<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_deployment.discord_bot](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_namespace.ns](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.ghcr_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_discord_image"></a> [discord\_image](#input\_discord\_image) | n/a | `any` | n/a | yes |
| <a name="input_github_pat"></a> [github\_pat](#input\_github\_pat) | n/a | `any` | n/a | yes |
| <a name="input_github_username"></a> [github\_username](#input\_github\_username) | variable "discord\_token" {} | `any` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->