{
  description = "Xberg CLI";

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://rogernavelsaker.cachix.org"
      "https://nacosolutions.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "rogernavelsaker.cachix.org-1:n1DtzMNhA9Rz4Kg3xlXOi/KceULu8VrMbs9WXyMFQNQ="
      "nacosolutions.cachix.org-1:JzCiW2CLcuLXtwOVAg3SlSK/kpqWbfSFEVenyKVUlug="
    ];
  };
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" ];
      eachSystem = f: nixpkgs.lib.genAttrs systems (system: f (import nixpkgs { inherit system; }));
    in {
      packages = eachSystem (pkgs: {
        default =
          let
            tessdataEng = pkgs.fetchurl {
              url = "https://raw.githubusercontent.com/tesseract-ocr/tessdata_fast/87416418657359cb625c412a48b6e1d6d41c29bd/eng.traineddata";
              hash = "sha256-fUMivSp3SXJIeWg/w5EstULxmQbIO8waUhMlVkJxcLI=";
            };
            tessdataLicense = pkgs.fetchurl {
              url = "https://raw.githubusercontent.com/tesseract-ocr/tessdata_fast/87416418657359cb625c412a48b6e1d6d41c29bd/LICENSE";
              hash = "sha256-z8d0m5b2O9McPEK1xHG/dWgUBT6EfBDz6wA0F7xSPTA=";
            };
            tessdata = pkgs.runCommand "xberg-tessdata-eng" {} ''
              mkdir -p $out/share/tessdata $out/share/licenses/xberg
              cp ${tessdataEng} $out/share/tessdata/eng.traineddata
              cp ${tessdataLicense} $out/share/licenses/xberg/tessdata_fast-LICENSE
            '';
          in pkgs.stdenvNoCC.mkDerivation {
            pname = "xberg";
            version = "1.5.4";
            src = pkgs.fetchurl {
              url = "https://github.com/xberg-io/xberg/releases/download/v1.5.4/xberg-cli-x86_64-unknown-linux-gnu.tar.gz";
              hash = "sha256-hsDxPGu76ab6qSa8DgNOf5eTVlkJgonL6vEUFHx6WSE=";
            };
            sourceRoot = "xberg-cli-x86_64-unknown-linux-gnu";
            nativeBuildInputs = [ pkgs.autoPatchelfHook pkgs.gnutar pkgs.gzip pkgs.makeWrapper ];
            buildInputs = [ pkgs.stdenv.cc.cc.lib ];
            installPhase = ''
              runHook preInstall
              mkdir -p $out/libexec/xberg
              cp -a xberg lib*.so* $out/libexec/xberg/
              install -Dm644 LICENSE $out/share/licenses/xberg/LICENSE
              install -Dm644 THIRD_PARTY_LICENSES.md $out/share/licenses/xberg/THIRD_PARTY_LICENSES.md
              makeWrapper $out/libexec/xberg/xberg $out/bin/xberg \
                --set-default TESSDATA_PREFIX ${tessdata}/share/tessdata
              install -Dm644 ${tessdata}/share/licenses/xberg/tessdata_fast-LICENSE $out/share/licenses/xberg/tessdata_fast-LICENSE
              runHook postInstall
            '';
            doCheck = true;
            checkPhase = ''
              test -x xberg
              test -s ${tessdata}/share/tessdata/eng.traineddata
            '';
            meta = with pkgs.lib; {
              description = "Xberg document intelligence CLI";
              homepage = "https://github.com/xberg-io/xberg";
              license = with licenses; [
                mit
                lgpl3Plus
                lgpl3
                lgpl21
                bsd2
                gpl2Plus
                asl20
              ];
              mainProgram = "xberg";
              platforms = [ "x86_64-linux" ];
            };
          };
      });
      apps = eachSystem (pkgs: { default = { type = "app"; program = "${self.packages.${pkgs.system}.default}/bin/xberg"; }; });
    };
}
