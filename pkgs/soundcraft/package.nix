{
  mkCraftApp,
  alsa-lib,
}:

mkCraftApp {
  pname = "soundcraft";
  description = "Record, edit and mix audio and MIDI";
  extraBuildInputs = [ alsa-lib ];
}
