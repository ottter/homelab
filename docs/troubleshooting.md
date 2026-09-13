# Troubleshooting

```sh
export KUBECONFIG=ansible/kubeconfig
```

## Flux is not picking up a change

```sh
flux get kustomizations                  # is it Ready? what revision?
flux reconcile kustomization flux-system --with-source
flux logs --follow
```

A Kustomization stuck `Unknown` is usually waiting on `dependsOn`. Check the stage before it in the chain.

## An app deployed but something is empty

Almost always an undefined substitution variable — Flux replaces unknown `${var}` with an **empty string** and reports no error.

Check every `${var}` in your manifests exists in `clusters/mini/cluster-vars.yaml`.

## Flux cannot decrypt secrets

```sh
kubectl get secret sops-age -n flux-system    # does the key exist?
flux get kustomization apps                   # error will mention sops
```

If missing, re-run the playbook — the flux role recreates it. If the age key was rotated without updating the cluster, see [secrets.md](secrets.md).

## HelmRelease stuck or failed

```sh
flux get helmreleases -A
kubectl describe helmrelease <name> -n <namespace>
```

Chart version mismatches show here. `versions.yaml` and the HelmRelease must agree — CI enforces it.

## Certificate not issuing

```sh
kubectl get certificate -A
kubectl describe certificate <name> -n <namespace>
kubectl get clusterissuer
```

## Namespace stuck Terminating

```sh
NS=$(kubectl get ns | grep Terminating | awk 'NR==1 {print $1}') && \
kubectl get namespace "$NS" -o json | tr -d "\n" | \
sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/" | \
kubectl replace --raw /api/v1/namespaces/$NS/finalize -f -
```

## Force a redeploy on the same image tag

```sh
kubectl rollout restart deployment <name> -n <namespace>
```

## Cluster reachability

```sh
kubectl get nodes
ssh {username}@{homelab_server_ip} 'sudo systemctl status k3s'
```

## Copying files to the server

```sh
rsync -av --progress /path/to/file {username}@{homelab_server_ip}:/mnt/plex/media/movies/
```
