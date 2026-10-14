final: prev:
let
  inherit (prev) lib;
  appNames = builtins.attrNames (
    lib.filterAttrs (name: type: type == "directory" && name != "build-support") (
      builtins.readDir ./pkgs
    )
  );
in
lib.genAttrs appNames (name: prev.callPackage (./pkgs + "/${name}/package.nix") { })
// {
  mkCraftApp = prev.callPackage ./pkgs/build-support/mk-craft-app.nix { };

  craftSources = import ./nix/tamal {
    inherit (prev.stdenv.hostPlatform) system;
    bootstrap-nixpkgs = prev.path;
  };
}
