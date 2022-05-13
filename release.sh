#!/usr/bin/env bash
set -eu

nix build .#allImages "${@}"

mkdir -p dist
for f in ./result/*; do
    filename="$(basename "$f")"
    echo "Compressing $filename"
    gzip -c "$f" > "dist/$filename.gz"
done
