{
  mkCraftApp,
  alsa-lib,
}:

mkCraftApp {
  pname = "deckcraft";
  description = "Create and present slide decks";
  extraBuildInputs = [ alsa-lib ];
}
