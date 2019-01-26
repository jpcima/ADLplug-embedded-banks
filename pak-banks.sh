#!/bin/bash
set -e
shopt -s nullglob

if test ! "$#" -eq 1; then
    echo "Usage: pak-banks <directory>"
    exit 1
fi

declare -a banks=()
declare -a names=()
for bank in "$1"/*.{wopl,wopn}; do
    banks+=("$bank")
    names+=("$(basename "${bank: : -5}" | sed -r 's/^[0-9]{3} //')")
done

cleanup() {
    rm -f _all.wopl.gz _all.wopl
}
trap cleanup INT TERM EXIT

if test -t 1; then
  echo "Not writing binary data to the terminal."
  exit 1
fi

# Compress
cat "${banks[@]}" > _all.wopl
zopfli _all.wopl

# Write dictionary
offset=0
for i in "${!banks[@]}"; do
    size=`stat -c '%s' "${banks[$i]}"`
    printf '%.8x' "$size" | xxd -r -p
    printf '%.8x' "$offset" | xxd -r -p
    printf '%s' "${names[$i]}"
    printf '%.2x' 0 | xxd -r -p
    offset=$((offset+size))
done
printf '%.8x' 0 | xxd -r -p

# Write file data
cat _all.wopl.gz
