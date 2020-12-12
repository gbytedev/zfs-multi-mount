#!/bin/bash

if [[ $# == 0 ]]; then
    echo "ERROR: Datasets are needed as arguments."
    exit 1
fi

for dataset in "$@"; do
  if ! zfs list -H -o name | grep -qx "$dataset"; then
    echo "ERROR: Dataset '$dataset' does not exist."
    continue
  fi

  if [[ $(zfs get keystatus "$dataset" -H -o value) == "unavailable" ]] ; then
    if [ ! -v key ]; then
      read -srp "Enter passphrase: " key ; echo
    fi
  fi

  if sudo zfs mount "$dataset"; then # Mounting as non-root user on Linux is not possible, see https://github.com/openzfs/zfs/issues/10648
    echo "Dataset '$dataset' has been mounted."
  fi
done
unset key
