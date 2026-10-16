{
  lib,
  stdenv,
  mkCraftApp,
  alsa-lib,
  gtk3,
}:

mkCraftApp {
  pname = "filmcraft";
  description = "Edit video, color and sound";
  extraBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    gtk3
  ];
}
