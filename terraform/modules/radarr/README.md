<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.radarr](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_namespace.ns](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.tls](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [null_resource.configure_radarr](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [tls_private_key.service_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.service_cert](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |
| [kubernetes_secret.radarr_key](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/secret) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_root"></a> [domain\_root](#input\_domain\_root) | n/a | `string` | `"local"` | no |
| <a name="input_domain_sub"></a> [domain\_sub](#input\_domain\_sub) | n/a | `string` | `"radarr"` | no |
| <a name="input_homepage_enabled"></a> [homepage\_enabled](#input\_homepage\_enabled) | n/a | `bool` | `true` | no |
| <a name="input_plexdir_movies"></a> [plexdir\_movies](#input\_plexdir\_movies) | n/a | `string` | `"/mnt/plex/movies"` | no |
| <a name="input_plexdir_root"></a> [plexdir\_root](#input\_plexdir\_root) | Filepath on NFS share for Plex root location | `string` | `"/mnt/plex"` | no |
| <a name="input_server_ip"></a> [server\_ip](#input\_server\_ip) | n/a | `any` | n/a | yes |
| <a name="input_transmission_enabled"></a> [transmission\_enabled](#input\_transmission\_enabled) | n/a | `bool` | `true` | no |
| <a name="input_transmission_ns"></a> [transmission\_ns](#input\_transmission\_ns) | n/a | `string` | `"transmission"` | no |
| <a name="input_transmission_pass"></a> [transmission\_pass](#input\_transmission\_pass) | n/a | `string` | `"password"` | no |
| <a name="input_transmission_user"></a> [transmission\_user](#input\_transmission\_user) | n/a | `string` | `"admin"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_radarr_api_key"></a> [radarr\_api\_key](#output\_radarr\_api\_key) | n/a |
<!-- END_TF_DOCS -->