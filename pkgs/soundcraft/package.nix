{
  mkCraftApp,
  alsa-lib,
}:

mkCraftApp {
  pname = "soundcraft";
  rev = "c51e5d5ec52f11c6264b72e26661fa712feb5345";
  date = "2026-10-08";
  hash = "sha256-VdTwPoLrLq3XxevWWo06WF16f/6/+x9cQ/kS3swkreE=";
  cargoHash = "sha256-3ujhZk0bkdDuRPX6z6fTliHzjuaVGrdcXCyMu7906Uk=";
  description = "Record, edit and mix audio and MIDI";
  extraBuildInputs = [ alsa-lib ];
}
