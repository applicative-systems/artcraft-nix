{
  mkCraftApp,
  alsa-lib,
}:

mkCraftApp {
  pname = "deckcraft";
  rev = "d0e57d7e25f9852179cc66be12dd6188f1c05535";
  date = "2026-10-08";
  hash = "sha256-mJTA41rZMHwrK8o/Yw2TcGfWSfz7MreX9SliFVAoDMc=";
  cargoHash = "sha256-apWpS5qjLkXMXfzR21NEt7EyuoMk489DVS1rKp9rVcA=";
  description = "Create and present slide decks";
  extraBuildInputs = [ alsa-lib ];
}
