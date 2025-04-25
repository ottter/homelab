<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.transmission](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_namespace.ns](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.tls](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [tls_private_key.service_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.service_cert](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_root"></a> [domain\_root](#input\_domain\_root) | n/a | `string` | `"local"` | no |
| <a name="input_domain_sub"></a> [domain\_sub](#input\_domain\_sub) | n/a | `string` | `"transmission"` | no |
| <a name="input_homepage_enabled"></a> [homepage\_enabled](#input\_homepage\_enabled) | n/a | `bool` | `true` | no |
| <a name="input_password"></a> [password](#input\_password) | n/a | `string` | `"password"` | no |
| <a name="input_plexdir_downloads"></a> [plexdir\_downloads](#input\_plexdir\_downloads) | n/a | `string` | `"/mnt/plex/downloads"` | no |
| <a name="input_transmission_config"></a> [transmission\_config](#input\_transmission\_config) | n/a | `string` | `"/mnt/plex/transmission/config"` | no |
| <a name="input_username"></a> [username](#input\_username) | n/a | `string` | `"james"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->