{
  description = "Nix packages for the storytold (ArtCraft) apps";

  outputs =
    inputs:
    let
      inherit (import ./nix/tamal { system = "x86_64-linux"; }) nixpkgs;
      lib = import (nixpkgs + "/lib");
      linuxPackages = lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (
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
      ) linuxPackages;

      apps = builtins.mapAttrs (system: pkgs: {
        update = {
          type = "app";
          program = toString (
            pkgs.writeShellScript "update" ''
              exec ${lib.getExe pkgs.nixtamal} refresh "$@"
            ''
          );
        };
      }) linuxPackages;

      checks = inputs.self.packages;

      formatter = builtins.mapAttrs (system: pkgs: pkgs.nixfmt-tree) linuxPackages;
    };

  nixConfig = {
    extra-substituters = [ "https://applicative-systems.cachix.org" ];
    extra-trusted-public-keys = [
      "applicative-systems.cachix.org-1:ND41hRBh0ST2abuI/oee3yWVf3n0FsAftyJJ/Tb7KDE="
    ];
  };
}
