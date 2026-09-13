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
3. Add its chart version to [`cluster-vars.yaml`](../clusters/mini/cluster-vars.yaml) and reference it as `${<app>_version}`
4. Push

Listing an app in `apps/mini` is what enables it — that replaces Terraform's `enable_<app>` variables.

## Variable substitution

`clusters/mini/cluster-vars.yaml` is a ConfigMap of non-secret values. Write `${domain_root}` in any manifest and Flux fills it in at apply time. This replaces Terraform's `templatefile()`.

It is also the source for Ansible: the playbook loads the same file via `vars_files` and maps `data.<key>` onto the variable names the roles use. Change an IP, the domain, the timezone or a storage path in this one file and both tools pick it up.

It stays shaped as a ConfigMap because Flux substitution reads from the cluster, not from a file — that is the one format both tools can consume.

**An undefined variable substitutes to an empty string, silently.** Before pushing, check every `${var}` you used is defined in that ConfigMap.

Secrets never go here — see [secrets.md](secrets.md).

## Versions

Chart and image versions live in `cluster-vars.yaml` alongside the other
settings, and are substituted into the manifests — so a version is written in
exactly one place.

```yaml
# clusters/mini/cluster-vars.yaml
radarr_version: "27.13.1"
```

```yaml
# apps/base/radarr/release.yaml
version: "${radarr_version}"
```

The k3s version is the exception: it lives in `ansible/group_vars/all.yml`,
because only Ansible installs k3s.

To upgrade: change the value in `cluster-vars.yaml` and push.

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
