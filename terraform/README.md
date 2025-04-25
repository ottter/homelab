<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.17.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.36.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 4.0.6 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_discord"></a> [discord](#module\_discord) | ./modules/discord | n/a |
| <a name="module_homepage"></a> [homepage](#module\_homepage) | ./modules/homepage | n/a |
| <a name="module_kubecost"></a> [kubecost](#module\_kubecost) | ./modules/kubecost | n/a |
| <a name="module_nginx"></a> [nginx](#module\_nginx) | ./modules/nginx | n/a |
| <a name="module_plex"></a> [plex](#module\_plex) | ./modules/plex | n/a |
| <a name="module_radarr"></a> [radarr](#module\_radarr) | ./modules/radarr | n/a |
| <a name="module_sonarr"></a> [sonarr](#module\_sonarr) | ./modules/sonarr | n/a |
| <a name="module_transmission"></a> [transmission](#module\_transmission) | ./modules/transmission | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apikey_finnhub"></a> [apikey\_finnhub](#input\_apikey\_finnhub) | API key from <https://finnhub.io/> | `string` | `"apikey"` | no |
| <a name="input_apikey_openweathermap"></a> [apikey\_openweathermap](#input\_apikey\_openweathermap) | API key from <https://openweathermap.org/> | `string` | `"apikey"` | no |
| <a name="input_apikey_weatherapi"></a> [apikey\_weatherapi](#input\_apikey\_weatherapi) | API key from <https://www.weatherapi.com/> | `string` | `"apikey"` | no |
| <a name="input_discord_image"></a> [discord\_image](#input\_discord\_image) | Name of Docker image to deploy | `any` | n/a | yes |
| <a name="input_domain_root"></a> [domain\_root](#input\_domain\_root) | Root domain name for the environment. (.local; homelab.local) | `string` | `"local"` | no |
| <a name="input_enable_discord"></a> [enable\_discord](#input\_enable\_discord) | Enable the Discord module | `bool` | `false` | no |
| <a name="input_enable_homepage"></a> [enable\_homepage](#input\_enable\_homepage) | Enable the Homepage module | `bool` | `false` | no |
| <a name="input_enable_kubecost"></a> [enable\_kubecost](#input\_enable\_kubecost) | Enable the Kubecost module | `bool` | `false` | no |
| <a name="input_enable_plex"></a> [enable\_plex](#input\_enable\_plex) | Enable the Plex module | `bool` | `false` | no |
| <a name="input_enable_radarr"></a> [enable\_radarr](#input\_enable\_radarr) | Enable the Radarr module | `bool` | `false` | no |
| <a name="input_enable_sonarr"></a> [enable\_sonarr](#input\_enable\_sonarr) | Enable the Sonarr module | `bool` | `false` | no |
| <a name="input_enable_transmission"></a> [enable\_transmission](#input\_enable\_transmission) | Enable the Transmission module | `bool` | `false` | no |
| <a name="input_github_pat"></a> [github\_pat](#input\_github\_pat) | Github PAT to access image on Github Container Registry | `any` | n/a | yes |
| <a name="input_github_username"></a> [github\_username](#input\_github\_username) | Github Username to access image on Github Container Registry | `any` | n/a | yes |
| <a name="input_kubeconfig"></a> [kubeconfig](#input\_kubeconfig) | Location of kube config file to access cluster | `string` | `"~/.kube/config"` | no |
| <a name="input_kubecost_token"></a> [kubecost\_token](#input\_kubecost\_token) | Kubecost token. A free trial one can be gotten from <https://www.kubecost.com/install.html> | `any` | n/a | yes |
| <a name="input_node_ip"></a> [node\_ip](#input\_node\_ip) | A List of IP Addresses associated with the cluster | `list(any)` | <pre>[<br/>  "192.168.0.144"<br/>]</pre> | no |
| <a name="input_plex_path_config"></a> [plex\_path\_config](#input\_plex\_path\_config) | Filepath on NFS share for Plex config | `string` | `"/mnt/plex/config"` | no |
| <a name="input_plex_path_downloads"></a> [plex\_path\_downloads](#input\_plex\_path\_downloads) | n/a | `string` | `"/mnt/plex/downloads"` | no |
| <a name="input_plex_path_movies"></a> [plex\_path\_movies](#input\_plex\_path\_movies) | Filepath on NFS share for Plex movies | `string` | `"/mnt/plex/movies"` | no |
| <a name="input_plex_path_root"></a> [plex\_path\_root](#input\_plex\_path\_root) | Filepath on NFS share for Plex root location | `string` | `"/mnt/plex"` | no |
| <a name="input_plex_path_tv"></a> [plex\_path\_tv](#input\_plex\_path\_tv) | Filepath on NFS share for Plex tv | `string` | `"/mnt/plex/tv"` | no |
| <a name="input_plex_token"></a> [plex\_token](#input\_plex\_token) | Create a Plex account and get a token from <https://www.plex.tv/claim/> | `string` | `"apikey"` | no |
| <a name="input_stock_watchlist"></a> [stock\_watchlist](#input\_stock\_watchlist) | List of stock ticker symbols (compatible with Finnhub API) | `list(string)` | <pre>[<br/>  "SPY",<br/>  "NVDA",<br/>  "TSM",<br/>  "MSFT",<br/>  "AAPL"<br/>]</pre> | no |
| <a name="input_transmission_pass"></a> [transmission\_pass](#input\_transmission\_pass) | Basic Auth password to access Transmission. Can be disabled in values.yaml | `string` | `"password"` | no |
| <a name="input_transmission_user"></a> [transmission\_user](#input\_transmission\_user) | Basic Auth username to access Transmission. Can be disabled in values.yaml | `string` | `"admin"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->