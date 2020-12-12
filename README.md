# zfs-multi-mount
Mounts several datasets with only one passphrase prompt. For people who feel very confident about that one passphrase.

I generally do not endorse reusing passwords, but there are edge cases, like splitting up a pool into datasets for the sake of granular control over some of its properties while still needing the convenience of a single passphrase.

## Usage
`zfs-multi-mount.sh pool/dataset1 pool/dataset2 pool/dataset3`

## Credit
Created and maintained by Pawel Ginalski (https://gbyte.dev).
