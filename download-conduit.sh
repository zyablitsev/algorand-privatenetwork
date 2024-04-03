#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

bindir=${BIN_DIR:-"./bin"}
tmpdir=${TMP_DIR:-"./tmp"}

# determine os
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    arch="linux_x86_64"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    arch="darwin_all"
else
    echo "unsupported arch ${OSTYPE}"
    exit
fi

# determine the latest version of conduit
latest_asset=$(curl "https://api.github.com/repos/algorand/conduit/releases" | jq ".[].assets[] | select(.name | ascii_downcase | contains(\"conduit\") and contains(\"${arch}\"))" | jq -s ".[0]")
latest_asset_id=$(echo ${latest_asset} | jq -r ".id")
latest_asset_name=$(echo ${latest_asset} | jq -r ".name")

echo "fetching latest conduit release asset ${latest_asset_id} - ${latest_asset_name}"

# prepare tmp directory
rm -rf ${tmpdir}/ 2>/dev/null || true
mkdir -p ${tmpdir}/

# fetch conduit
curl \
    -L \
    -H 'accept:application/octet-stream' \
    "https://api.github.com/repos/algorand/conduit/releases/assets/${latest_asset_id}" \
     | tar -xz -C ${tmpdir}

mv ${tmpdir}/conduit ${bindir}/
rm -rf ${tmpdir}

echo ""
echo "installed ${bindir}/conduit: $(${bindir}/conduit -v)"
