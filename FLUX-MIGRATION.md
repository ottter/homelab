# Flux / GitOps migration plan

Status: **in progress.** Steps 1-2 of §7 complete (tooling + SOPS).
Traefik drift fixed (see §8).

Context:

- **`/terraform` is destroyed** — no app workloads in the cluster. Nothing to
  migrate, nothing to tear down. This is a greenfield build for the app layer.
- **`/ansible` is built and running** — k3s, MetalLB, Traefik, cert-manager
  are all live and healthy on `192.168.0.210`. We treat this as precious and
  change it as little as possible.

`/terraform` stays in place, untouched, as a working reference while the Flux
tree is built alongside it.

---

## 1. What changes, what doesn't

| Layer | Today | After |
| --- | --- | --- |
| OS, hardening, NFS, dnsmasq | Ansible | **Ansible (unchanged)** |
| k3s install | Ansible | **Ansible (unchanged)** |
| Flux bootstrap | — | Ansible (one new role) |
| MetalLB / Traefik / cert-manager | Ansible `networking` role | **Flux** (`infrastructure/`) |
| IPAddressPool, ClusterIssuer, Middleware | Ansible `networking` role | **Flux** (`infrastructure/`) |
| 9 apps | Terraform | **Flux** (`apps/`) |
| Secrets | gitignored `homelab.tfvars` | **SOPS + age**, encrypted in git |

`/terraform` is not deleted. It becomes reference material.

### Note on the `networking` role

The Ansible `networking` role currently installs MetalLB, Traefik and
cert-manager via `helm` shell-outs. Flux needs to own these, because the app
HelmReleases depend on them and Flux must be able to reconcile the whole
dependency chain.

The role is **not deleted** — it is reduced to installing the Helm binary only
(if we still want it on the box), with the cluster-addon tasks commented out
and a pointer to `infrastructure/`. That keeps the rollback path obvious.

---

## 2. Target layout

```text
clusters/mini/               Flux entrypoint (what `flux bootstrap` writes)
  flux-system/               managed by Flux itself
  infrastructure.yaml        Kustomization -> infrastructure/
  apps.yaml                  Kustomization -> apps/mini  (dependsOn infrastructure)

infrastructure/
  controllers/               HelmRepository + HelmRelease
    metallb.yaml
    cert-manager.yaml
    traefik.yaml
  configs/                   things that need the CRDs to exist first
    metallb-pool.yaml        IPAddressPool + L2Advertisement
    cluster-issuer.yaml      selfSigned issuer + CA cert + CA issuer
    traefik-middleware.yaml  local-ipallowlist

apps/
  base/<app>/                HelmRelease (or Deployment) + Certificate + kustomization.yaml
  mini/
    kustomization.yaml       which apps are on, plus per-cluster patches
    secrets.enc.yaml         SOPS-encrypted
    cluster-vars.yaml        ConfigMap: domain_root, IPs, paths
```

### How Terraform concepts map

| Terraform | Flux |
| --- | --- |
| `count = var.enable_x ? 1 : 0` | app listed (or not) in `apps/mini/kustomization.yaml` |
| `templatefile(values-tmpl.yaml, {...})` | HelmRelease `values:` + `postBuild.substituteFrom` |
| `var.domain_root`, `var.server_ip`, paths | ConfigMap `cluster-vars`, substituted by Flux |
| secrets in `homelab.tfvars` | SOPS-encrypted Secret, decrypted in-cluster |
| `depends_on = [module.transmission]` | `dependsOn:` on the Kustomization |
| `kubernetes_manifest` Certificate | plain `Certificate` YAML (no CRD-at-plan-time problem) |

The `kubernetes_manifest` CRD ordering problem disappears entirely. Flux uses
server-side apply and retries until healthy, so "CRD and CR in the same commit"
just works. This is the single biggest quality-of-life win.

---

## 3. Secrets: SOPS + age (walkthrough)

The repo `github.com/ottter/homelab` is on a public remote, so this must be
done correctly before any secret is committed. Nothing else proceeds until
this step works.

**The model:** `age` is the encryption tool (one keypair). `sops` is the
file-format tool that encrypts *only the values* in a YAML file, leaving keys
readable — so a diff still shows which secret changed, without revealing it.
The private key goes on the cluster as a Secret; Flux decrypts at apply time.
The private key is **never** committed.

### 3a. Install tooling (Windows)

```powershell
choco install age sops -y
# flux CLI:
choco install flux -y
```

### 3b. Generate the age keypair

```powershell
mkdir $HOME\.config\sops\age -Force
age-keygen -o $HOME\.config\sops\age\keys.txt
```

Prints a public key (`age1...`). Private key lives only in `keys.txt`.

**Back `keys.txt` up somewhere offline.** Lose it and every encrypted file in
the repo is unrecoverable.

### 3c. `.sops.yaml` in repo root

Tells sops what to encrypt and with which key. Committed — it contains only
the *public* key.

```yaml
creation_rules:
  - path_regex: .*\.enc\.yaml$
    encrypted_regex: ^(data|stringData)$
    age: age1YOUR_PUBLIC_KEY_HERE
```

`encrypted_regex` means only `data:`/`stringData:` get encrypted — the
`kind`, `metadata`, and name stay plaintext and reviewable.

### 3d. Load the private key into the cluster

```sh
kubectl create namespace flux-system
kubectl create secret generic sops-age \
  --namespace=flux-system \
  --from-file=age.agekey=$HOME/.config/sops/age/keys.txt
```

Best done as an Ansible task so a rebuild is repeatable.

### 3e. Tell Flux to decrypt

On the apps Kustomization:

```yaml
decryption:
  provider: sops
  secretRef:
    name: sops-age
```

### 3f. Day-to-day use

```sh
sops apps/mini/secrets.enc.yaml   # opens editor, decrypted; re-encrypts on save
```

Commit the `.enc.yaml`. Safe on a public repo.

### Secrets to migrate from homelab.tfvars

`plex_token`, `transmission_user`, `transmission_pass`, `discord_token`,
`github_pat`, `apikey_finnhub`, `apikey_openweathermap`, `apikey_weatherapi`,
`apikey_overseerr`, `apikey_yamtrack`, plus the Radarr/Sonarr keys (see §5).

---

## 4. Flux bootstrap

Flux bootstrap commits to the repo, so it needs a GitHub PAT with `repo` scope.

```powershell
$env:GITHUB_TOKEN="ghp_..."
flux bootstrap github `
  --owner=ottter `
  --repository=homelab `
  --branch=main `
  --path=clusters/mini `
  --personal
```

This installs the Flux controllers, commits `clusters/mini/flux-system/`, and
starts reconciling. From then on, `git push` is the deploy mechanism.

`KUBECONFIG` must point at `ansible/kubeconfig` (or `~/.kube/config`).

---

## 5. The Radarr/Sonarr API-key problem

Terraform reads the generated API key out of the running pod
(`radarr/outputs.tf` + `files/config.sh`) and feeds it to Homepage. Flux has
no way to read a live value and template it elsewhere.

**Decision: pin the keys instead of discovering them.**

Radarr and Sonarr accept a pre-set API key. We generate one ourselves, put it
in SOPS, and both the app and Homepage read the same known value. This:

- removes `outputs.tf` from both modules
- removes the `kubectl exec` / API-key-scraping half of `config.sh`
- makes Homepage's config fully static

Generate with `openssl rand -hex 16` (Radarr/Sonarr use 32-char hex keys).

The *other* half of `config.sh` — POSTing to the Radarr API to register
Transmission as a download client and set the remote path mapping — has no
GitOps equivalent either. Options, in order of preference:

1. **Do it once by hand in the UI.** Config persists in the app's own
   database on the NFS/host volume. Honest about what it is: app-level
   setup, not cluster state. Recommended while learning Flux.
2. **Kubernetes Job** running the same curl calls, applied by Flux. Keeps it
   automated; costs you bash-in-a-pod to maintain.

Starting with (1) and revisiting later is fine, and keeps this migration
focused on Flux rather than on porting a provisioner.

---

## 6. Per-app notes

| App | Shape | Notes |
| --- | --- | --- |
| overseerr | HelmRelease + Certificate | simplest — good first app |
| yamtrack | Deployment + Service + Ingress + Certificate | hand-written manifests; `random_password` -> SOPS |
| transmission | HelmRelease + Certificate | basic-auth creds -> SOPS |
| plex | Deployment + Service (LoadBalancer, own IP) | `plex_token` -> SOPS; hostPath volumes |
| radarr | HelmRelease + Certificate | pinned API key (§5) |
| sonarr | HelmRelease + Certificate | pinned API key (§5) |
| homepage | HelmRelease + ConfigMap + Certificate | 5 config files; consumes pinned keys |
| discord | Deployment + 2 Secrets | token + GHCR pull secret -> SOPS |

TrueCharts note: charts come from `oci://oci.trueforge.org/truecharts`. Flux
supports OCI via `HelmRepository` with `type: oci`. We should **pin chart
versions** in each HelmRelease — Terraform wasn't pinning them, which means
today's deploys are not reproducible.

---

## 7. Order of work

Each step is independently verifiable. Nothing is destructive to Ansible.

**Do not re-run the Ansible bootstrap playbook.** The cluster is already
built. Re-running is not needed and risks disturbing a working install.

1. ~~**Install tooling**~~ — DONE. In WSL: flux 2.9.5, sops 3.13.3, age 1.0.0.
2. ~~**SOPS setup**~~ — DONE. Keypair at `~/.config/sops/age/keys.txt`
   (mode 600), public key in `.sops.yaml`, encrypt/decrypt round-trip verified,
   `.gitignore` hardened against plaintext key commits.
   **Outstanding: back up `keys.txt` offline.**
3. **`flux bootstrap`** against the existing cluster, path `clusters/mini`.
   Non-destructive — it only adds the `flux-system` namespace.
   *Verify:* `flux check`, `flux get kustomizations`.
4. **`infrastructure/` — adopt, don't reinstall.** MetalLB, Traefik and
   cert-manager are already running at the versions in §8. Write HelmReleases
   pinned to *those exact versions* so Flux adopts the existing releases
   instead of upgrading or replacing them.
   *Verify:* Traefik keeps `192.168.0.220`; no pod restarts; `flux get hr -A`
   all Ready. Then comment out the corresponding Ansible networking tasks.
5. **`infrastructure/configs`** — IPAddressPool, ClusterIssuer, Middleware.
   These already exist and match; Flux should report "no drift."
   **Do not let Flux recreate `homelab-ca`** — see §9.2.
   *Verify:* `kubectl get clusterissuer homelab-ca` still Ready, same age.
6. **First app: overseerr.** Proves HelmRelease + Certificate + ingress +
   the substitution mechanism end to end.
   *Verify:* `https://overseerr.local` loads with a trusted cert.
7. **Secrets-dependent apps:** plex, transmission, yamtrack, discord.
8. **radarr + sonarr** with pinned keys.
9. **homepage** last — it consumes everything above.
10. **CI:** replace `terraform.yml` workflow with a Flux-aware one
    (`kustomize build` dry-run, `flux check --pre`). Keep `ansible.yml`.
11. **README** rewrite: deployment order becomes Ansible -> bootstrap -> push.

---

## 8. Verified cluster state (checked 2026-09-12)

The k3s cluster is **up and healthy**; only the Terraform-managed apps are gone.

```text
node        minipc  Ready  v1.35.3+k3s1  Ubuntu 24.04.4  192.168.0.210
namespaces  cert-manager, metallb-system, traefik  (no app namespaces — as expected)
traefik     LoadBalancer 192.168.0.220  — single instance, healthy
clusterissuers  homelab-ca (Ready), homelab-ca-issuer (Ready)
ipaddresspool   homelab-pool  192.168.0.220-192.168.0.230
```

### Traefik: resolved — but a real drift bug was found

There is only **one** Traefik. The running cluster was installed with
`--disable traefik`, so the k3s bundled copy never existed.

However, the repo's `k3s_extra_args` did **not** contain `--disable traefik`.
The live server and the repo had drifted. A rebuild from this repo would have
produced two ingress controllers fighting over the same IngressClass.

**Fixed:** `--disable traefik` added to `ansible/roles/k3s/defaults/main.yml`.
No effect on the running cluster (already correct); it makes a rebuild
reproduce what is actually there.

### Chart versions to pin (read from live cluster)

| Component | Version |
| --- | --- |
| k3s | `v1.35.3+k3s1` |
| MetalLB | `0.14.9` |
| Traefik | `35.2.0` |
| cert-manager | `v1.17.2` |

These match `ansible/group_vars/all.yml`, so the infrastructure layer carries
over 1:1 into Flux HelmReleases. The **app** charts (TrueCharts) were never
pinned and must be pinned as each app is ported.

---

## 9. Open questions

1. **`terraform/` retention** — keep as reference indefinitely, or delete
   once Flux is fully green? Recommend keeping until step 10 passes.
2. **cert-manager CA secret** — `homelab-ca-secret` currently exists in the
   cluster and your browser trusts it. If Flux recreates the ClusterIssuer
   from scratch it may mint a **new** CA, requiring a re-import on every
   machine. Worth preserving the existing secret rather than regenerating.
