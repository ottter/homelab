# Backups

Nightly snapshot of app **config** to `/var/backups/homelab` on the node. Managed by the `backup` Ansible role.

On-box only — nothing is copied off the machine or into the repo.

## What is and is not backed up

| Data | Backed up | Why |
| --- | --- | --- |
| App config (radarr, sonarr, overseerr, homepage) | Yes | PVCs on `local-path`, lost if the PVC is deleted |
| Yamtrack SQLite DB | Yes | `/var/lib/yamtrack/db` |
| Transmission config | Yes, if present | `/mnt/plex/transmission/config` |
| Cluster state (namespaces, HelmReleases, secrets) | No | Flux rebuilds it from git |
| Media files | No | Large and re-downloadable |
| k3s etcd | No | Nothing in it that git does not already describe |

Config is small, so a snapshot is megabytes, not gigabytes.

**This protects against:** an accidental Flux prune, a deleted PVC, a bad app upgrade, a cluster rebuild.

**It does not protect against:** the disk dying or the machine being stolen. On-box backups are one disk away from total loss. Copying `/var/backups/homelab` somewhere else occasionally is the cheapest fix.

## How it works

A systemd timer runs `/usr/local/bin/homelab-backup.sh` daily at `backup_on_calendar` (default 03:30, plus up to 10 minutes of jitter).

The script scales the SQLite-backed apps to zero, waits for the pods to exit, archives the configured paths, then scales them back. Copying a live SQLite file can capture a torn write that restores as a corrupt database, so the brief downtime is deliberate.

Replicas are restored by an `EXIT` trap, so apps come back even if the archive step fails. The script then waits for each rollout and **exits non-zero if an app does not become ready** — an app left down matters more than a missed backup.

Archives are written as `.part` and renamed on success, so an interrupted run never leaves a file that looks usable.

## Settings

In `ansible/group_vars/all.yml`:

| Variable | Default | Meaning |
| --- | --- | --- |
| `backup_enabled` | `true` | Set `false` to remove the timer, service and script |
| `backup_retention` | `7` | Snapshots kept; one run per day, so roughly 7 days |
| `backup_on_calendar` | `"03:30"` | systemd `OnCalendar` format |

Paths and the quiesced deployment list are in `ansible/roles/backup/defaults/main.yml`.

## Checking on it

```bash
systemctl list-timers homelab-backup.timer
systemctl status homelab-backup.service
journalctl -u homelab-backup.service -n 50
ls -lh /var/backups/homelab
```

Run one immediately:

```bash
sudo systemctl start homelab-backup.service
```

## Restoring

Deliberately manual — a restore is rare and destructive, and a confident-but-wrong script is worse than instructions.

```bash
# 1. Stop the app
kubectl scale deploy radarr -n radarr --replicas=0
kubectl wait --for=delete pod -n radarr -l app.kubernetes.io/name=radarr --timeout=120s

# 2. Inspect the archive before extracting
tar -tzf /var/backups/homelab/homelab-YYYYMMDD-HHMMSS.tar.gz | head

# 3. Extract over the original location. tar stripped the leading '/' when
#    archiving, so members are relative (var/lib/...) and -C / re-anchors them.
sudo tar -xzf /var/backups/homelab/homelab-YYYYMMDD-HHMMSS.tar.gz -C /

# 4. Start it again
kubectl scale deploy radarr -n radarr --replicas=1
kubectl rollout status deploy radarr -n radarr
```

Extracting to `/` overwrites the current config for **every** path in the archive. To restore one app, extract to a temporary directory and copy just what you need.

Note the PVC directory name contains the PVC UID. If the PVC was recreated since the backup, the directory in the archive no longer matches the live one — copy the contents into the current directory rather than extracting to `/`.

## Reclaim policy

The existing PVs are set to `reclaimPolicy: Retain`, so deleting a PVC leaves its data directory on disk instead of erasing it. A retained volume goes to `Released` and needs a manual re-bind or file copy to reuse — Retain makes deletion recoverable, not harmless.

`infrastructure/configs/storage-class.yaml` provides `local-path-retain` for new volumes. It is not the default class, so apps opt in with `storageClassName: local-path-retain`; switching an existing app means recreating its PVC, which discards the current contents, so restore from a backup afterwards.

Check what a volume is set to:

```bash
kubectl get pv -o custom-columns=\
  'CLAIM:.spec.claimRef.name,POLICY:.spec.persistentVolumeReclaimPolicy'
```
