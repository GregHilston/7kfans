{
  description = "Seven Kingdoms: Ancient Adversaries - C++ game build environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
        # Build dependencies for Seven Kingdoms
        buildDeps = [
          pkgs.gcc
          pkgs.gnumake
          pkgs.autoconf
          pkgs.automake
          pkgs.libtool
          pkgs.pkg-config
          pkgs.SDL2
          pkgs.SDL2.dev
          pkgs.enet
          pkgs.openal
          pkgs.curl.dev
          pkgs.gettext
        ];
        # Common development tools
        commonTools = [
          pkgs.git
          pkgs.curl
          pkgs.wget
          pkgs.direnv
          pkgs.nix-direnv
        ];
      in {
        devShells = {
          # Default devshell with C++ build environment
          default = pkgs.mkShell {
            packages = buildDeps ++ commonTools;
            shellHook = ''
              export PKG_CONFIG_PATH="${pkgs.SDL2.dev}/lib/pkgconfig:${pkgs.curl.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"
              export SDL2_CONFIG="${pkgs.SDL2.dev}/bin/sdl2-config"
              echo "🏰 Seven Kingdoms: Ancient Adversaries build environment ready! 🏰"
              echo "🛠️ Build tools: gcc, make, autotools, SDL2, enet, openal 🛠️"
              echo ""
              echo "To build the game:"
              echo "  ./configure"
              echo "  make"
              echo ""
              echo "To run from build directory:"
              echo "  SKDATA=data src/7kaa"
            '';
          };
        };
      }
    );
}