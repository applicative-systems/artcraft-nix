# Source tree of storytold/craft-fonts, pinned in nix/tamal. The craft apps embed the CJK fonts
# from it at build time via CRAFT_FONTS_DIR.
{ craftSources }:

craftSources.craft-fonts
