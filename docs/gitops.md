# GitOps with Flux

Ansible builds the machine. Flux runs the cluster. After bootstrap there is no deploy command — `git push` is the deploy.

## How it fits together

```text
ansible/          the machine   — push-based, runs when you invoke it
clusters/mini/    Flux entrypoint
infrastructure/   cluster addons (MetalLB, cert-manager, Traefik)
apps/             workloads
```

Flux watches `clusters/mini` and reconciles in a dependency chain:

```text
flux-system  →  infra-controllers  →  infra-configs  →  apps
```

Each stage waits for the one before. That ordering is what Terraform could never do in one pass: `kubernetes_manifest` needed CRDs to exist at *plan* time, so a clean apply was impossible. Flux applies server-side and retries until healthy.

## Deploying

```sh
git push
```

Flux polls the repo. To force an immediate sync:

```sh
flux reconcile kustomization flux-system --with-source
```

## Adding an app

1. Create `apps/base/<name>/` with a `kustomization.yaml` listing its resources
2. Add the app to `apps/mini/kustomization.yaml`
3. Pin its chart version in [`versions.yaml`](../versions.yaml) and the CI check
4. Push

Listing an app in `apps/mini` is what enables it — that replaces Terraform's `enable_<app>` variables.

## Variable substitution

`clusters/mini/cluster-vars.yaml` is a ConfigMap of non-secret values. Write `${domain_root}` in any manifest and Flux fills it in at apply time. This replaces Terraform's `templatefile()`.

**An undefined variable substitutes to an empty string, silently.** Before pushing, check every `${var}` you used is defined in that ConfigMap.

Secrets never go here — see [secrets.md](secrets.md).

## Versions

[`versions.yaml`](../versions.yaml) is the single source of truth. Ansible reads it directly via `vars_files`.

Flux manifests cannot read a file, so their chart versions are literals. [`.github/workflows/versions.yml`](../.github/workflows/versions.yml) fails CI if the two drift.

To upgrade: change `versions.yaml`, change the matching HelmRelease, push.

## Checking state

```sh
flux get kustomizations          # reconciliation status
flux get helmreleases -A         # chart status
flux logs --follow               # live controller logs
kubectl get pods -A
```

## Suspending

To stop Flux fighting a manual change:

```sh
flux suspend kustomization apps
# ...do the thing...
flux resume kustomization apps
```
