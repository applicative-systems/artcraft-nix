{
  description = "Nix packages for the storytold (ArtCraft) apps";

  outputs =
    inputs:
    let
      inherit (import ./nix/tamal { system = "x86_64-linux"; }) nixpkgs;
      lib = import (nixpkgs + "/lib");
      pkgsBySystem = lib.genAttrs (lib.platforms.linux ++ lib.platforms.darwin) (
        system:
        import nixpkgs {
          inherit system;
          overlays = [ inputs.self.overlays.default ];
        }
      );
      appNames = builtins.attrNames (removeAttrs (builtins.readDir ./pkgs) [ "build-support" ]);
    in
    {
      overlays.default = import ./overlay.nix;

      packages = builtins.mapAttrs (
        system: pkgs: lib.genAttrs appNames (name: pkgs.${name})
      ) pkgsBySystem;

      apps = builtins.mapAttrs (system: pkgs: {
        update = {
          type = "app";
          program = toString (
            pkgs.writeShellScript "update" ''
              exec ${lib.getExe pkgs.nixtamal} refresh "$@"
            ''
          );
        };
      }) pkgsBySystem;

      checks = inputs.self.packages;

      formatter = builtins.mapAttrs (system: pkgs: pkgs.nixfmt-tree) pkgsBySystem;

      devShells = builtins.mapAttrs (system: pkgs: {
        default = pkgs.mkShell {
          packages = [
            pkgs.nixtamal
            inputs.self.formatter.${system}
          ];
        };
      }) pkgsBySystem;
    };

  nixConfig = {
    extra-substituters = [ "https://applicative-systems.cachix.org" ];
    extra-trusted-public-keys = [
      "applicative-systems.cachix.org-1:ND41hRBh0ST2abuI/oee3yWVf3n0FsAftyJJ/Tb7KDE="
    ];
  };
}
