# artcraft-nix

Nix flake that builds the [ArtCraft](https://getartcraft.com/apps) apps.
ArtCraft is a set of open-source, vibe-coded Rust clones of commercial creative and office apps.
Every app is built for `x86_64-linux` and `aarch64-linux`.
The CI also pushes to [Cachix](https://applicative-systems.cachix.org) so you don't have to compile them for yourself and can instead quickly try them all out.

## Run, install, upgrade

### Run without installing

```sh
nix run github:applicative-systems/artcraft-nix#wordcraft
```

### Install to your profile

```sh
nix profile add github:applicative-systems/artcraft-nix#wordcraft

# Upgrade all installed apps later
nix profile upgrade --all
```

Swap `wordcraft` for any app below. 
Each package also ships a headless `<app>-cli` (CLI / MCP server).
Accept the flake's binary cache when Nix asks (or pass `--accept-flake-config`), otherwise Nix builds from source.

## Apps

| App | Clone of | Source | Homepage | Screenshots |
|---|---|---|---|---|
| `cadcraft` | AutoCAD | [repo](https://github.com/storytold/cadcraft) | [web](https://getartcraft.com/apps/cadcraft) | [📷](https://github.com/storytold/cadcraft#screenshots) |
| `deckcraft` | PowerPoint | [repo](https://github.com/storytold/deckcraft) | [web](https://getartcraft.com/apps/deckcraft) | [📷](https://github.com/storytold/deckcraft/tree/main/docs/images) |
| `designcraft` | InDesign | [repo](https://github.com/storytold/designcraft) | [web](https://getartcraft.com/apps/designcraft) | [📷](https://github.com/storytold/designcraft/tree/main/docs/images) |
| `effectcraft` | After Effects | [repo](https://github.com/storytold/effectcraft) | [web](https://getartcraft.com/apps/effectcraft) | [📷](https://github.com/storytold/effectcraft/tree/main/docs/images) |
| `filmcraft` | Premiere Pro | [repo](https://github.com/storytold/filmcraft) | [web](https://getartcraft.com/apps/filmcraft) | [📷](https://github.com/storytold/filmcraft/tree/main/docs/images) |
| `gridcraft` | Excel | [repo](https://github.com/storytold/gridcraft) | [web](https://getartcraft.com/apps/gridcraft) | [📷](https://github.com/storytold/gridcraft#a-look-around) |
| `lightcraft` | Lightroom | [repo](https://github.com/storytold/lightcraft) | [web](https://getartcraft.com/apps/lightcraft) | [📷](https://github.com/storytold/lightcraft/tree/main/docs/images) |
| `pdfcraft` | Acrobat | [repo](https://github.com/storytold/pdfcraft) | [web](https://getartcraft.com/apps/pdfcraft) | [📷](https://github.com/storytold/pdfcraft/tree/main/docs/images) |
| `photocraft` | Photoshop | [repo](https://github.com/storytold/photocraft) | [web](https://getartcraft.com/apps/photocraft) | [📷](https://github.com/storytold/photocraft/tree/main/docs/images) |
| `soundcraft` | Pro Tools | [repo](https://github.com/storytold/soundcraft) | [web](https://getartcraft.com/apps/soundcraft) | [📷](https://github.com/storytold/soundcraft#feature-tour) |
| `vectorcraft` | Illustrator | [repo](https://github.com/storytold/vectorcraft) | [web](https://getartcraft.com/apps/vectorcraft) | [📷](https://github.com/storytold/vectorcraft#a-look-around) |
| `wordcraft` | Word | [repo](https://github.com/storytold/wordcraft) | [web](https://getartcraft.com/apps/wordcraft) | [📷](https://github.com/storytold/wordcraft#a-tour) |

An overlay is also available as `overlays.default`.

## Updating

All sources (Nixpkgs and app repos) are pinned with [Nixtamal](https://nixtamal.toast.al) in `nix/tamal/`.
`nix run .#update` bumps everything to the latest commits (or pass app names to bump individually).
