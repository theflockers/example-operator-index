#!/bin/bash
YQ=bin/yq
set -eu -o pipefail
out=$(cat $1)
while IFS= read -r img; do
	export rendered=$(bin/opm render "$img" -o yaml)
	out=$(echo "$out" | ${YQ} eval-all "(select(.schema == \"olm.bundle\" and .image == \"$img\")) |= env(rendered)" -)
done <<< $(echo "$out" | ${YQ} eval-all "select(.schema == \"olm.bundle\") | [.image][]" -)
echo "$out"
