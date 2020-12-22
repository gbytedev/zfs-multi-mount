#!/usr/bin/env bash

PATH=/usr/bin:/sbin:/bin

help() {
    echo "Usage: $(basename "$0") DATASET [DATASET]..."
    echo "Usage: $(basename "$0") pool/dataset1 pool/dataset2"
    echo
    echo " -h, --help                     show this help"
    exit 0
}

for arg in "$@"; do
  case $arg in
  -h | --help) help ;;
  -?*)
    echo "Unknown option: $1"
    exit 1
    ;;
  esac
done

[[ $# == 0 ]] && echo "ERROR: Datasets are needed as arguments." && exit 1

for dataset in "$@"; do
  if ! zfs list -H -o name | grep -qx "$dataset"; then
    echo "ERROR: Dataset '$dataset' does not exist."
    continue
  fi

  if [[ $(zfs get keystatus "$dataset" -H -o value) == "unavailable" ]]; then
    [ ! -v key ] && read -srp "Enter passphrase: " key ; echo
    ! echo "$key" | zfs load-key "$dataset" && echo "ERROR: Incorrect key provided." && exit 1
  fi

  # Mounting as non-root user on Linux is not possible,
  # see https://github.com/openzfs/zfs/issues/10648.
  sudo zfs mount "$dataset" && echo "Dataset '$dataset' has been mounted."
done
unset key
