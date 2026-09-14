# Secrets

Flux runs **inside** the cluster, so it only sees what is in git — a gitignored file is invisible to it. Secrets therefore live in git, encrypted.

`age` is the encryption backend; `sops` is the file format. SOPS encrypts only the *values*, leaving keys and structure readable — so diffs still show which secret changed without revealing it.

## The keypair

```sh
age-keygen -o ~/.config/sops/age/keys.txt
```

Produces both halves in one file:

| Half | Where it lives | Committed? |
| --- | --- | --- |
| Public (`age1...`) | `.sops.yaml` as the recipient | **Yes** — safe |
| Private (`AGE-SECRET-KEY-1...`) | `~/.config/sops/age/keys.txt` (mode 600) | **Never** |

**Back up `keys.txt` offline.** Lose it and every `*.enc.yaml` in this repo is unrecoverable. This is the single point of failure.

The cluster gets a copy as the `sops-age` secret in `flux-system`, created by the Ansible flux role. The apps Kustomization declares `decryption.provider: sops`, so Flux decrypts at apply time.

## What committed secrets look like

```yaml
kind: Secret
metadata:
  name: plex-secrets          # readable
  namespace: plex             # readable
stringData:
  PLEX_CLAIM: ENC[AES256_GCM,data:x9C715ufd8Mk...]   # encrypted
```

Safe on a public repo. Without the private key, `sops --decrypt` fails with "Failed to get the data key".

## Editing

```sh
sops apps/base/radarr/secret.enc.yaml
```

Each app has its own file at `apps/base/<app>/secret.enc.yaml`. Opens your editor with plaintext and re-encrypts on save; you never handle ciphertext directly.

To read without editing:

```sh
sops --decrypt apps/base/radarr/secret.enc.yaml
```

## What is stored

| Secret | Namespace | Holds |
| --- | --- | --- |
| `plex-secrets` | plex | `PLEX_CLAIM` |
| `transmission-secrets` | transmission | basic-auth `USER` / `PASS` |
| `radarr-secrets` | radarr | pinned `RADARR__AUTH__APIKEY` |
| `sonarr-secrets` | sonarr | pinned `SONARR__AUTH__APIKEY` |
| `yamtrack-secrets` | yamtrack | Django `SECRET` |
| `discord-secrets` | discord | `DISCORD_TOKEN` |
| `discord-ghcr` | discord | GHCR pull credentials (private image) |
| `homepage-secrets` | homepage | `HOMEPAGE_VAR_*` API keys |

Homepage reads its keys as `{{HOMEPAGE_VAR_NAME}}` placeholders resolved at runtime, so no key is ever written into the ConfigMap.

## Rotating the key

Only needed if `keys.txt` is exposed, or for scheduled hygiene. **Give the cluster the new key before pushing files encrypted to it**, or Flux stops decrypting and reconciliation breaks.

```sh
# 1. New keypair, keeping the old one until verified
age-keygen -o ~/.config/sops/age/keys-new.txt
grep "public key" ~/.config/sops/age/keys-new.txt

# 2. Put that public key in .sops.yaml (replace the age: value)

# 3. Re-encrypt. Needs the OLD key to decrypt and the NEW one to encrypt,
#    so use both at once.
cat ~/.config/sops/age/keys.txt ~/.config/sops/age/keys-new.txt > ~/.config/sops/age/keys-both.txt
for f in apps/base/*/secret.enc.yaml; do
  SOPS_AGE_KEY_FILE=~/.config/sops/age/keys-both.txt sops updatekeys -y "$f"
done

# 4. Cluster gets the new key BEFORE the push
kubectl create secret generic sops-age \
  --namespace=flux-system \
  --from-file=age.agekey=$HOME/.config/sops/age/keys-new.txt \
  --dry-run=client -o yaml | kubectl apply -f -

# 5. Promote, then commit and push
mv ~/.config/sops/age/keys-new.txt ~/.config/sops/age/keys.txt
rm ~/.config/sops/age/keys-both.txt

# 6. Verify
flux reconcile kustomization apps --with-source
flux get kustomizations
```

Keep the old key backed up until step 6 passes. Then back up the new one.

After rotation the old key no longer decrypts the file — that is the point of a rotation, as opposed to just adding a second recipient.

## Leak scanning

`.github/workflows/secrets.yml` runs TruffleHog on every push and PR, weekly on a schedule, and on demand. It scans the **full history** (`fetch-depth: 0`) — a secret deleted in a later commit is still retrievable from the earlier one, so scanning only the tip would miss the case that matters.

`--results=verified` means it only fails when a credential is confirmed **live** against the provider's API. SOPS files are base64 ciphertext and the age key in `.sops.yaml` is public, so neither trips it.

If it ever fails, treat the credential as compromised: **revoke it first**, then rewrite history. Deleting the file in a new commit does not remove it from git.
