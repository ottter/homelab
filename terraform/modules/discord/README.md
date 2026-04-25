# Discord Bot

Deploys a Discord bot from a private GHCR image. No ingress or service — the bot connects outbound to Discord's API only.

## Variables

| Variable | Description |
| --- | --- |
| `bot_name` | Name used for the namespace, deployment, and secrets (default: `discord`) |
| `discord_image` | Full image reference, e.g. `ghcr.io/user/repo:tag` |
| `discord_token` | Bot token from <https://discord.com/developers/applications> |
| `github_username` | GitHub username for GHCR image pull |
| `github_pat` | GitHub fine-grained token with `read:packages` on the bot repo only |

## GitHub PAT Setup

Use a fine-grained token scoped as tightly as possible:

1. Go to `github.com` → Settings → Developer Settings → Personal access tokens → Fine-grained tokens
2. Set repository access to the specific bot repo only
3. Under Permissions → Repository permissions → set **Packages** to `Read-only`
4. No other permissions needed

## Redeploying with a new image

`IfNotPresent` is set on the image pull policy — Kubernetes will not pull a new image unless the tag changes or the pod is on a new node. To force a redeploy after pushing a new image to the same tag:

```sh
kubectl rollout restart deployment discord-bot -n discord
```
