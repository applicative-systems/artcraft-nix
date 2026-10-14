{
  mkCraftApp,
  alsa-lib,
}:

mkCraftApp {
  pname = "effectcraft";
  description = "Motion graphics and visual effects compositor";
  extraBuildInputs = [ alsa-lib ];
}
