{
  description = "Nix packages for the storytold (ArtCraft) apps";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    inputs:
    let
      linuxPackages = {
        inherit (inputs.nixpkgs.legacyPackages) x86_64-linux aarch64-linux;
      };
      appNames = builtins.attrNames (removeAttrs (builtins.readDir ./pkgs) [ "build-support" ]);
    in
    {
      overlays.default = import ./overlay.nix;

      packages = builtins.mapAttrs (
        system: pkgs:
        let
          pkgs' = pkgs.extend inputs.self.overlays.default;
        in
        inputs.nixpkgs.lib.genAttrs appNames (name: pkgs'.${name})
      ) linuxPackages;

      checks = inputs.self.packages;

      formatter = builtins.mapAttrs (system: pkgs: pkgs.nixfmt-tree) linuxPackages;
    };
}
