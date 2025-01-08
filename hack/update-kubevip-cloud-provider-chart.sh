#!/bin/bash

set -euo pipefail
set -x 

base_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
chart_dir="./helm/cloud-provider-proxmox/charts/kube-vip-cloud-provider"

cd "$base_dir"

# The goal here is to control versions only from Chart.yaml overrides with Renovate and grab that version here.
VERSION=$(yq e '.version' "config/kube-vip-cloud-provider/overwrites/Chart.yaml")

"./hack/clone-git-repo.sh" \
  "kube-vip/helm-charts" \
  "kube-vip-cloud-provider-$VERSION" \
  "kube-vip-cloud-provider"

rm -Rf "$chart_dir"

cp -R \
  "./tmp/kube-vip/charts/kube-vip-cloud-provider" \
  "$chart_dir"

# Customizations

cp -R \
  "./config/kube-vip-cloud-provider/overwrites/." \
  "$chart_dir/"

# Remove default values to match kube-vip chart behaviour and rely on appVersion.
# Won't be needed anymore if this PR gets merged: https://github.com/kube-vip/helm-charts/pull/35
yq e 'del(.image.tag)' -i "helm/cloud-provider-proxmox/charts/kube-vip-cloud-provider/values.yaml"
