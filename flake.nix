{
  description = "Xberg CLI";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" ];
      eachSystem = f: nixpkgs.lib.genAttrs systems (system: f (import nixpkgs { inherit system; }));
    in {
      packages = eachSystem (pkgs: {
        default = pkgs.stdenvNoCC.mkDerivation {
          pname = "xberg";
          version = "1.3.10";
          src = pkgs.fetchurl {
            url = "https://github.com/xberg-io/xberg/releases/download/v1.3.10/xberg-cli-binstall-x86_64-unknown-linux-musl.tar.gz";
            hash = "sha256-EuMORRSxNqh8VGSUEVU8Qae7UXATB7RRXg+wWItcgUg=";
          };
          sourceRoot = "xberg-cli-binstall-x86_64-unknown-linux-musl";
          nativeBuildInputs = [ pkgs.gnutar pkgs.gzip ];
          installPhase = ''
            runHook preInstall
            install -Dm755 xberg $out/bin/xberg
            install -Dm644 LICENSE $out/share/licenses/xberg/LICENSE
            runHook postInstall
          '';
          doCheck = true;
          checkPhase = ''
            test -x xberg
          '';
          meta = with pkgs.lib; {
            description = "Xberg document intelligence CLI";
            homepage = "https://github.com/xberg-io/xberg";
            license = licenses.mit;
            mainProgram = "xberg";
            platforms = [ "x86_64-linux" ];
          };
        };
      });
      apps = eachSystem (pkgs: { default = { type = "app"; program = "${self.packages.${pkgs.system}.default}/bin/xberg"; }; });
    };
}
