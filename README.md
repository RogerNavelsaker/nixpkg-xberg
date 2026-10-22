# nixpkg-xberg

Reproducible Nix packaging for the [Xberg CLI](https://github.com/xberg-io/xberg), pinned to release **v1.3.10**. The package uses Xberg's statically linked Linux x86_64 musl CLI artifact; its SHA-256 is pinned and the upstream MIT license is installed alongside the binary.

## Use

```sh
nix build
./result/bin/xberg --help
# Or run without installing:
nix run -- --help
```

Currently supported: x86_64 Linux. Upstream's other artifacts may have different dynamic-library or platform requirements; this package intentionally only exposes the self-contained x86_64 musl build.
