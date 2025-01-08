#!/bin/bash

set -euo pipefail
set -x 

base_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
chart_dir="./helm/cloud-provider-proxmox/charts/kube-vip"

cd "$base_dir"

# The goal here is to control versions only from Chart.yaml overrides with Renovate and grab that version here.
VERSION=$(yq e '.version' "config/kube-vip/overwrites/Chart.yaml")

"./hack/clone-git-repo.sh" \
  "kube-vip/helm-charts" \
  "kube-vip-$VERSION" \
  "kube-vip"

rm -Rf "$chart_dir"

cp -R \
  "./tmp/kube-vip/charts/kube-vip" \
  "$chart_dir"

# Customizations

cp -R \
  "./config/kube-vip/overwrites/." \
  "$chart_dir/"
