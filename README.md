# nixpkg-xberg

Reproducible Nix packaging for the [Xberg CLI](https://github.com/xberg-io/xberg), pinned to release **v1.3.10**. The package uses Xberg's Linux x86_64 GNU release artifact and bundles its sidecar libraries and licenses. The smaller upstream musl `binstall` artifact omits Tesseract; this package pins English (`eng`) trained data from `tessdata_fast` for the full release's built-in OCR backend, without requiring an external Tesseract install. Other languages need their own trained data.

## Use

```sh
nix build
./result/bin/xberg --help
# Or run without installing:
nix run -- --help
```

Currently supported: x86_64 Linux. Upstream's other artifacts may have different dynamic-library or platform requirements; this package intentionally only exposes the self-contained x86_64 musl build.
