#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

bindir=${BIN_DIR:-"./bin"}
tmpdir=${TMP_DIR:-"./tmp"}

# determine os
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    arch="linux_amd64"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    arch="darwin_amd64"
else
    echo "unsupported arch ${OSTYPE}"
    exit
fi

# determine the latest version of indexer
latest_asset=$(curl "https://api.github.com/repos/algorand/indexer/releases" | jq ".[].assets[] | select(.name | contains(\"indexer\") and contains(\"${arch}\"))" | jq -s ".[0]")
latest_asset_id=$(echo ${latest_asset} | jq -r ".id")
latest_asset_name=$(echo ${latest_asset} | jq -r ".name")

echo "fetching latest indexer release asset ${latest_asset_id} - ${latest_asset_name}"

# prepare tmp directory
rm -rf ${tmpdir}/ 2>/dev/null || true
mkdir -p ${tmpdir}/

# fetch indexer
curl \
    -L \
    -H 'accept:application/octet-stream' \
    "https://api.github.com/repos/algorand/indexer/releases/assets/${latest_asset_id}" \
     | tar -xj -C ${tmpdir}

mv ${tmpdir}/algorand-indexer*/algorand-indexer ${bindir}/
rm -rf ${tmpdir}

echo ""
echo "installed ${bindir}/algorand-indexer: $(${bindir}/algorand-indexer -v)"
