# Terraform (legacy)

> **Superseded by Flux.** All eight modules are ported to `apps/base/`. This
> directory is kept as reference and is no longer applied.
>
> The state file here is stale — it lists namespaces that no longer exist.
> Do not run `terraform apply`.

Still useful while the migration settles:

- `modules/*/files/config.sh` — the Radarr/Sonarr download-client and remote
  path mapping payloads, now a manual one-time step. See
  [docs/apps.md](../docs/apps.md).
- `homelab.tfvars` — gitignored, superseded by `apps/mini/secrets.enc.yaml`.

Delete this directory once the Flux deployment is verified.
