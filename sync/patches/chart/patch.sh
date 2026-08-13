#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

repo_dir=$(git rev-parse --show-toplevel) ; readonly repo_dir
script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ) ; readonly script_dir
CHART_DIR="${repo_dir}/helm/cloud-provider-proxmox" ; readonly CHART_DIR

cd "${repo_dir}"

echo "Patching chart metadata"

# we need to get the current version of the chart in order to
# reset it after copying Chart.yaml over.

CURRENT_CHART_VERSION=$(curl -s https://api.github.com/repos/giantswarm/cloud-provider-proxmox-app/releases/latest | jq -r .name)
# remove leading 'v' if present
CURRENT_CHART_VERSION="${CURRENT_CHART_VERSION#v}"

# we need to set the appVersion field in Chart.yaml to match the
# version being synced from upstream.

# get the upstream sync version from vendir.yml
UPSTREAM_SYNC_VERSION=$(yq -r .directories[0].contents[0].git.ref ${repo_dir}/vendir.yml)
# strip leading 'v' if present
UPSTREAM_SYNC_VERSION_STRIPPED="${UPSTREAM_SYNC_VERSION#v}"

# copy default Chart.yaml to the helm chart directory
cp "${script_dir}"/manifests/Chart.yaml "${CHART_DIR}/Chart.yaml"

# set the upstream version in Chart.yaml (for appVersion field and upstream version annotation)
sed -i -E "s/APP_VERSION_PLACEHOLDER/${UPSTREAM_SYNC_VERSION_STRIPPED}/" "${CHART_DIR}/Chart.yaml"

# set the chart version in Chart.yaml
sed -i -E "s/^version: VERSION_PLACEHOLDER/version: ${CURRENT_CHART_VERSION}/" "${CHART_DIR}/Chart.yaml"
