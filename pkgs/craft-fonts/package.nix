# Source tree of storytold/craft-fonts. The craft apps embed the CJK fonts from it at build time
# via CRAFT_FONTS_DIR.
{ fetchFromGitHub }:

fetchFromGitHub {
  owner = "storytold";
  repo = "craft-fonts";
  rev = "8dcdacd5153e64560d109541a47d806f26f048c0";
  hash = "sha256-4E9OrthE5z39xFXpvpwn4Fn6RH3wX2sF56rZZejZT+I=";
}
