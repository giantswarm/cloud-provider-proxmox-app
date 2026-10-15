#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

repo_dir=$(git rev-parse --show-toplevel) ; readonly repo_dir
script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ) ; readonly script_dir
CHART_DIR="${repo_dir}/helm/cloud-provider-proxmox" ; readonly CHART_DIR

cd "${repo_dir}"

readonly script_dir_rel=".${script_dir#"${repo_dir}"}"

set -x
git apply "${script_dir_rel}/_values.yaml.patch"

# set the image tag in the values file
# get the upstream sync version from vendir.yml
UPSTREAM_SYNC_VERSION=$(yq -r .directories[0].contents[0].git.ref ${repo_dir}/vendir.yml)

# set the tag
sed -i -E "s/tag: \"\"/tag: \"${UPSTREAM_SYNC_VERSION}\"/" "${CHART_DIR}/values.yaml"

{ set +x; } 2>/dev/null
