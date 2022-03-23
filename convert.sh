#!/bin/bash
SCRIPTDIR=$(dirname $(type -p $0))
YQ=$SCRIPTDIR/bin/yq
OPM=$SCRIPTDIR/bin/opm

# this process fails when the output bytes we attempt to set in an env var exceed ARG_MAX.
# until/unless we solve or obviate the shell interaction issue (for e.g. by implementing in go)

set -eu -o pipefail
out=$(cat $1)

while IFS= read -r img; do
	export rendered=$(${OPM} render "$img" -o yaml)
	out=$(echo "$out" | ${YQ} eval-all "(select(.schema == \"olm.bundle\" and .image == \"$img\")) |= env(rendered)" -)
done <<< $(echo "$out" | ${YQ} eval-all "select(.schema == \"olm.bundle\") | [.image][]" -)
echo "$out"
