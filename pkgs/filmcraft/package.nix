{
  mkCraftApp,
  alsa-lib,
  gtk3,
}:

mkCraftApp {
  pname = "filmcraft";
  description = "Edit video, color and sound";
  extraBuildInputs = [
    alsa-lib
    gtk3
  ];
}
