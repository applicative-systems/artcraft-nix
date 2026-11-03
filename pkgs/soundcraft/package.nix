{
  lib,
  stdenv,
  mkCraftApp,
  alsa-lib,
}:

mkCraftApp {
  pname = "soundcraft";
  description = "Record, edit and mix audio and MIDI";
  extraBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ alsa-lib ];
}
