{
  description = "PhotoCraft Rust development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs, ... }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          vectorcraft-cli = pkgs.rustPlatform.buildRustPackage {
            pname = "vectorcraft-cli";
            version = "0.8.2";
            src = self;
            cargoLock = {
              lockFile = ./Cargo.lock;
              outputHashes."craft-print-0.1.0" = "sha256-J/EJJeDDWXc+QQtpUqnAKKA4piOdPRbH3uG1ms2BRgY=";
              outputHashes."craft-ui-0.1.0" = "sha256-VhLeT7VLdZAIz6gR9PdFI34IJxHsGF8NE0uzFCN2vIU=";
            };
            cargoBuildFlags = [ "-p" "vectorcraft-cli" ];
            doCheck = false;
            installPhase = ''
              runHook preInstall
              install -Dm755 target/${pkgs.stdenv.hostPlatform.rust.rustcTarget}/release/vectorcraft-cli $out/bin/vectorcraft-cli
              runHook postInstall
            '';
          };
          photocraft = pkgs.rustPlatform.buildRustPackage {
            pname = "photocraft";
            version = "0.8.2";
            src = self;
            cargoLock = {
              lockFile = ./Cargo.lock;
              outputHashes."craft-print-0.1.0" = "sha256-J/EJJeDDWXc+QQtpUqnAKKA4piOdPRbH3uG1ms2BRgY=";
              outputHashes."craft-ui-0.1.0" = "sha256-VhLeT7VLdZAIz6gR9PdFI34IJxHsGF8NE0uzFCN2vIU=";
            };
            cargoBuildFlags = [ "-p" "photocraft" ];
            doCheck = false;
            installPhase = ''
              runHook preInstall
              install -Dm755 target/${pkgs.stdenv.hostPlatform.rust.rustcTarget}/release/photocraft $out/bin/photocraft
              runHook postInstall
            '';
          };
          default = self.packages.${system}.vectorcraft-cli;
        });

      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          linuxPackages = with pkgs; lib.optionals stdenv.isLinux [
            alsa-lib
            libGL
            libX11
            libXcursor
            libXi
            libXrandr
            libxkbcommon
            wayland
          ];
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              cargo
              clippy
              pkg-config
              rust-analyzer
              rustc
              rustfmt
            ] ++ linuxPackages;
          };
        });
    };
}
