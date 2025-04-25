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
| [helm_release.homepage](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_config_map.homepage_config](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_namespace.ns](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.tls](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [tls_private_key.service_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.service_cert](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apikey_finnhub"></a> [apikey\_finnhub](#input\_apikey\_finnhub) | API key from https://finnhub.io/ | `string` | `"apikey"` | no |
| <a name="input_apikey_openweathermap"></a> [apikey\_openweathermap](#input\_apikey\_openweathermap) | API key from https://openweathermap.org/ | `string` | `""` | no |
| <a name="input_apikey_radarr"></a> [apikey\_radarr](#input\_apikey\_radarr) | API Key from Radarr | `string` | `""` | no |
| <a name="input_apikey_sonarr"></a> [apikey\_sonarr](#input\_apikey\_sonarr) | API Key from Sonarr | `string` | `""` | no |
| <a name="input_apikey_weatherapi"></a> [apikey\_weatherapi](#input\_apikey\_weatherapi) | API key from https://www.weatherapi.com/ | `string` | `""` | no |
| <a name="input_domain_root"></a> [domain\_root](#input\_domain\_root) | n/a | `string` | `"local"` | no |
| <a name="input_domain_sub"></a> [domain\_sub](#input\_domain\_sub) | n/a | `string` | `"homepage"` | no |
| <a name="input_server_ip"></a> [server\_ip](#input\_server\_ip) | n/a | `any` | n/a | yes |
| <a name="input_stock_watchlist"></a> [stock\_watchlist](#input\_stock\_watchlist) | List of stock ticker symbols (compatible with Finnhub API) | `list(string)` | <pre>[<br/>  "SPY",<br/>  "NVDA",<br/>  "TSM",<br/>  "MSFT",<br/>  "AAPL"<br/>]</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->