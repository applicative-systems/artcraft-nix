{
  mkCraftApp,
  alsa-lib,
}:

mkCraftApp {
  pname = "effectcraft";
  rev = "d60cb71e297a4bb76851b27b48c0014b56ccab69";
  date = "2026-10-08";
  hash = "sha256-4yP2X3sQj3CjEkc2tQFiW5cFu0sMILcTbp6bmw1fBLo=";
  cargoHash = "sha256-ovareokcWnGDe2GxyZFSfxU/on2Ad3QLnoSTHkswVB4=";
  description = "Motion graphics and visual effects compositor";
  extraBuildInputs = [ alsa-lib ];
}
