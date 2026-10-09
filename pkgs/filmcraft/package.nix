{
  mkCraftApp,
  alsa-lib,
  gtk3,
}:

mkCraftApp {
  pname = "filmcraft";
  rev = "5231852443363f001c3f6b396dd9b1e6461ae2be";
  date = "2026-10-08";
  hash = "sha256-qM8o8rSiiGBif0UePQpn6aAEzqbjIMx3ZRoE3wA1yFI=";
  cargoHash = "sha256-uzDeo+94RAK/flnYgTic167BeYfk2zqwwf/ODbwnok0=";
  description = "Edit video, color and sound";
  extraBuildInputs = [
    alsa-lib
    gtk3
  ];
}
