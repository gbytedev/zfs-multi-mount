# zfs-multi-mount
Mounts several ZFS datasets while asking for encryption passphrase as rarely as possible. If the same encryption passphrase is used on several datasets, it will ask once. For people who feel very confident about that one passphrase.

I generally do not endorse reusing passwords, but there are edge cases, like splitting up a pool into datasets for the sake of granular control over some of its properties while still needing the convenience of a single passphrase.

This script can be used in a systemd service to unlock encrypted datasets during boot. Practical if using several datasets with the same passphrase.

## Usage
### Load keys of all datasets and mount them
`zfs-multi-mount.sh`

### Load keys for specific datasets and mount them
`zfs-multi-mount.sh pool/dataset1 pool/dataset2 pool/dataset3`

### Load keys without mounting the datasets
`zfs-multi-mount.sh --no-mount`

### Use within systemd context (in a systemd service)
`zfs-multi-mount.sh --systemd`

#### Example of a systemd service file using this script to unlock ZFS datasets
/etc/systemd/system/zfs-load-key.service
```
[Unit]
Description=Import keys for all datasets
DefaultDependencies=no
Before=zfs-mount.service
Before=systemd-user-sessions.service
After=zfs-import.target
OnFailure=emergency.target

[Service]
Type=oneshot
RemainAfterExit=yes

ExecStart=zfs-multi-mount.sh --systemd --no-mount

[Install]
WantedBy=zfs-mount.service
```

## Credit
Created and maintained by Pawel Ginalski (https://gbyte.dev).
