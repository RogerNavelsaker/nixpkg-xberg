#!/usr/bin/env bash
# Sync flake.nix version + CLI tarball hash from the latest xberg-io/xberg release.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
tag=$(gh api repos/xberg-io/xberg/releases/latest --jq .tag_name)
version=${tag#v}
current=$(grep -oE '^\s*version = "[^"]+"' flake.nix | head -n1 | sed -E 's/.*"([^"]+)"/\1/')
[ "$current" != "$version" ] || { echo "already at $version"; exit 0; }
hash=$(nix store prefetch-file --json "https://github.com/xberg-io/xberg/releases/download/$tag/xberg-cli-x86_64-unknown-linux-gnu.tar.gz" | jq -r .hash)
HASH=$hash perl -0pi -e 's/(xberg-cli-x86_64-unknown-linux-gnu\.tar\.gz";\s*hash = ")[^"]+(")/$1$ENV{HASH}$2/' flake.nix
sed -i "s/$current/$version/g" flake.nix
echo "synced xberg $version"
