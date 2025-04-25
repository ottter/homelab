<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_deployment.plex](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_namespace.ns](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.tls](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_service.plex](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [tls_private_key.service_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.service_cert](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_root"></a> [domain\_root](#input\_domain\_root) | n/a | `any` | n/a | yes |
| <a name="input_plex_path_config"></a> [plex\_path\_config](#input\_plex\_path\_config) | n/a | `any` | n/a | yes |
| <a name="input_plex_path_movies"></a> [plex\_path\_movies](#input\_plex\_path\_movies) | n/a | `any` | n/a | yes |
| <a name="input_plex_path_tv"></a> [plex\_path\_tv](#input\_plex\_path\_tv) | n/a | `any` | n/a | yes |
| <a name="input_plex_token"></a> [plex\_token](#input\_plex\_token) | n/a | `any` | n/a | yes |
| <a name="input_server_ip"></a> [server\_ip](#input\_server\_ip) | n/a | `any` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->