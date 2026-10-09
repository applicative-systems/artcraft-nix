# Shared builder for the storytold "*craft" apps. They all use the same workspace layout:
#   apps/<name>        the desktop app (winit + wgpu)
#   apps/<name>-cli    the headless CLI / MCP server
#   packaging/linux/   ai.storyteller.<name>.{desktop,mime.xml,metainfo.xml.in}
#   assets/app-icon/hicolor
# Modelled after lightcraft's own nix/package.nix.
{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  makeWrapper,
  wayland,
  wayland-scanner,
  libxkbcommon,
  libx11,
  libxcb,
  libxcursor,
  libxi,
  libxrandr,
  vulkan-loader,
  libGL,
  desktop-file-utils,
  appstream,
  autoAddDriverRunpath,
  craft-fonts,
}:

{
  pname,
  rev,
  hash,
  cargoHash,
  description,
  # Release date of the pinned commit, for the AppStream metadata.
  date,
  binaries ? [
    pname
    "${pname}-cli"
  ],
  extraNativeBuildInputs ? [ ],
  extraBuildInputs ? [ ],
  extraRuntimeLibs ? [ ],
  patches ? [ ],
  # Patches for vendored crates.io dependencies: { "<crate>-<version>" = [ patch ... ]; }, applied
  # with -p1 inside the crate directory.
  vendorPatches ? { },
  ...
}@args:

let
  src = fetchFromGitHub {
    owner = "storytold";
    repo = pname;
    inherit rev hash;
  };

  version =
    (fromTOML (builtins.readFile (src + "/Cargo.toml"))).workspace.package.version
    + "-unstable-${date}";

  appId = "ai.storyteller.${pname}";
  envPrefix = lib.toUpper pname;

  # dlopen()ed at run time by winit / wgpu.
  runtimeLibs = [
    libxkbcommon
    wayland
    libx11
    libxcb
    libxcursor
    libxi
    libxrandr
    vulkan-loader
    libGL
  ]
  ++ extraRuntimeLibs;
in
rustPlatform.buildRustPackage (
  removeAttrs args [
    "rev"
    "hash"
    "date"
    "description"
    "binaries"
    "extraNativeBuildInputs"
    "extraBuildInputs"
    "extraRuntimeLibs"
    "vendorPatches"
  ]
  // {
    inherit
      pname
      version
      src
      cargoHash
      patches
      ;

    cargoBuildFlags = [
      "--locked"
    ]
    ++ lib.concatMap (b: [
      "-p"
      b
    ]) binaries;

    # The full workspace test suites take a long time and partly need a GPU; the upstream CI
    # covers them.
    doCheck = false;

    strictDeps = true;

    nativeBuildInputs = [
      pkg-config
      makeWrapper
      wayland-scanner
      desktop-file-utils
      appstream
      autoAddDriverRunpath
    ]
    ++ extraNativeBuildInputs;

    buildInputs = [
      wayland
      libxkbcommon
      libx11
      libxcb
      libxcursor
      libxi
      libxrandr
    ]
    ++ extraBuildInputs;

    env = {
      # Embeds the CJK fonts (official release builds do the same).
      CRAFT_FONTS_DIR = toString craft-fonts;
      CRAFT_FONTS_REQUIRED = "1";
      "${envPrefix}_BUILD_SHA" = rev;
      "${envPrefix}_BUILD_DATE" = date;
    }
    // (args.env or { });

    postPatch =
      lib.concatStrings (
        lib.mapAttrsToList (
          crate:
          lib.concatMapStrings (p: ''
            patch -p1 -d "$cargoDepsCopy/source-registry-0/${crate}" < ${p}
          '')
        ) vendorPatches
      )
      + (args.postPatch or "");

    postInstall = ''
      install -Dm644 packaging/linux/${appId}.desktop $out/share/applications/${appId}.desktop
      install -Dm644 packaging/linux/${appId}.mime.xml $out/share/mime/packages/${appId}.xml
      mkdir -p $out/share/icons
      cp -r assets/app-icon/hicolor $out/share/icons/
      install -d $out/share/metainfo
      substitute packaging/linux/${appId}.metainfo.xml.in \
        $out/share/metainfo/${appId}.metainfo.xml \
        --subst-var-by VERSION ${version} \
        --subst-var-by DATE ${date}

      doc=$out/share/doc/${pname}
      install -Dm644 -t "$doc" README.md LICENSE-MIT LICENSE-APACHE
      for f in NOTICE ATTRIBUTION.md assets/ATTRIBUTION.md; do
        [ -f "$f" ] && install -Dm644 "$f" "$doc/$(basename "$f")"
      done

      desktop-file-validate $out/share/applications/${appId}.desktop

      for bin in ${lib.concatMapStringsSep " " (b: "$out/bin/" + b) binaries}; do
        wrapProgram "$bin" --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}"
      done
    ''
    + (args.postInstall or "");

    passthru = {
      inherit runtimeLibs;
    }
    // (args.passthru or { });

    meta = {
      inherit description;
      homepage = "https://github.com/storytold/${pname}";
      license = [
        lib.licenses.mit
        lib.licenses.asl20
      ];
      sourceProvenance = [ lib.sourceTypes.fromSource ];
      platforms = lib.platforms.linux;
      mainProgram = pname;
    }
    // (args.meta or { });
  }
)
