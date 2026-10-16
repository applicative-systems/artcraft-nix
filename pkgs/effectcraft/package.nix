{
  lib,
  stdenv,
  mkCraftApp,
  alsa-lib,
}:

mkCraftApp {
  pname = "effectcraft";
  description = "Motion graphics and visual effects compositor";
  extraBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ alsa-lib ];
}
