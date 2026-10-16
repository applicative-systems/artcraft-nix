{
  lib,
  stdenv,
  mkCraftApp,
  alsa-lib,
}:

mkCraftApp {
  pname = "deckcraft";
  description = "Create and present slide decks";
  extraBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ alsa-lib ];
}
