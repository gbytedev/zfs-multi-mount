#!/bin/bash

PATH=/usr/bin:/sbin:/bin

help() {
    echo "Usage: $(basename "$0") [OPTION]... [SOURCE_POOL/DATASET]..."
    echo
    echo " -s, --systemd        use when within systemd context"
    echo " -n, --no-mount       only load keys, do not mount datasets"
    echo " -h, --help           show this help"
    exit 0
}

for arg in "$@"; do
  case $arg in
  -s | --systemd)
    systemd=1
    shift
    ;;
  -n | --no-mount)
    no_mount=1
    shift
    ;;
  -h | --help) help ;;
  -?*)
    die "Invalid option '$1' Try '$(basename "$0") --help' for more information." ;;
  esac
done

datasets=("$@")
[ ${#datasets[@]} -eq 0 ] && datasets=($(zfs list -H -o name))

function ask_password {
  if [ -v systemd ]; then
    key=$(systemd-ask-password "Enter $dataset passphrase:" --no-tty) # While booting.
  else
    read -srp "Enter $dataset passphrase: " key ; echo # Other places.
  fi
}

function load_key {
  ! zfs list -H -o name | grep -qx "$dataset" && echo "ERROR: Dataset '$dataset' does not exist." && return 1
  [[ ! $(zfs get keystatus "$1" -H -o value) == "unavailable" ]] && return 0
  [ ! -v key ] && ask_password
  if ! echo "$key" | zfs load-key "$1"; then
    unset key
    load_key $1
  fi
  return 0
}

for dataset in "${datasets[@]}"; do
  ! load_key $dataset && exit 1
  
  # Mounting as non-root user on Linux is not possible,
  # see https://github.com/openzfs/zfs/issues/10648.
  [ ! -v no_mount ] && sudo zfs mount "$dataset" && echo "Dataset '$dataset' has been mounted."
done
