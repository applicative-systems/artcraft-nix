# Shared builder for the storytold "*craft" apps. They all use the same workspace layout:
#   apps/<name>        the desktop app (winit + wgpu)
#   apps/<name>-cli    the headless CLI / MCP server
#   packaging/linux/   ai.storyteller.<name>.{desktop,mime.xml,metainfo.xml.in}
#   packaging/macos/   Info.plist.in
#   assets/app-icon/   hicolor/ and <name>.icns
# Modelled after lightcraft's own nix/package.nix.
{
  lib,
  stdenv,
  rustPlatform,
  craftSources,
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
  description,
  binaries ? [
    pname
    "${pname}-cli"
  ],
  extraNativeBuildInputs ? [ ],
  extraBuildInputs ? [ ],
  extraRuntimeLibs ? [ ],
  # Name of the macOS app bundle and its executable, e.g. "PdfCraft" for pdfcraft.
  displayName ?
    lib.toUpper (builtins.substring 0 1 pname)
    + lib.removeSuffix "craft" (builtins.substring 1 (-1) pname)
    + "Craft",
  patches ? [ ],
  # Patches for vendored crates.io dependencies: { "<crate>-<version>" = [ patch ... ]; }, applied
  # with -p1 inside the crate directory.
  vendorPatches ? { },
  extraCargoBuildFlags ? [ ],
  ...
}@args:

let
  src = craftSources.${pname};
  inherit (src) rev;
  date =
    let
      d = src.lastModifiedDate;
      year = builtins.substring 0 4 d;
      month = builtins.substring 4 2 d;
      day = builtins.substring 6 2 d;
    in
    "${year}-${month}-${day}";

  cargoVersion = (fromTOML (builtins.readFile (src + "/Cargo.toml"))).workspace.package.version;
  version = "${cargoVersion}-unstable-${date}";

  appId = "ai.storyteller.${pname}";
  envPrefix = lib.toUpper pname;

  inherit (stdenv.hostPlatform) isLinux isDarwin;

  # dlopen()ed at run time by winit / wgpu.
  runtimeLibs =
    lib.optionals isLinux [
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
    "description"
    "binaries"
    "extraNativeBuildInputs"
    "extraBuildInputs"
    "extraRuntimeLibs"
    "displayName"
    "platforms"
    "vendorPatches"
    "extraCargoBuildFlags"
  ]
  // {
    inherit
      pname
      version
      src
      patches
      ;

    cargoLock = {
      lockFile = src + "/Cargo.lock";
      # Git dependencies are all pinned to a rev in Cargo.lock, so no outputHashes are needed.
      allowBuiltinFetchGit = true;
    };

    cargoBuildFlags = [
      "--locked"
    ]
    ++ lib.concatMap (b: [
      "-p"
      b
    ]) binaries
    ++ extraCargoBuildFlags;

    # The full workspace test suites take a long time and partly need a GPU; the upstream CI
    # covers them.
    doCheck = false;

    strictDeps = true;

    nativeBuildInputs = [
      pkg-config
      makeWrapper
    ]
    ++ lib.optionals isLinux [
      wayland-scanner
      desktop-file-utils
      appstream
      autoAddDriverRunpath
    ]
    ++ extraNativeBuildInputs;

    buildInputs =
      lib.optionals isLinux [
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
            patch -p1 -d "$cargoDepsCopy/${crate}" < ${p}
          '')
        ) vendorPatches
      )
      + (args.postPatch or "");

    postInstall = ''
      doc=$out/share/doc/${pname}
      install -Dm644 -t "$doc" README.md LICENSE-MIT LICENSE-APACHE
      for f in NOTICE ATTRIBUTION.md assets/ATTRIBUTION.md; do
        [ -f "$f" ] && install -Dm644 "$f" "$doc/$(basename "$f")"
      done
    ''
    + lib.optionalString isLinux ''
      install -Dm644 packaging/linux/${appId}.desktop $out/share/applications/${appId}.desktop
      install -Dm644 packaging/linux/${appId}.mime.xml $out/share/mime/packages/${appId}.xml
      mkdir -p $out/share/icons
      cp -r assets/app-icon/hicolor $out/share/icons/
      install -d $out/share/metainfo
      substitute packaging/linux/${appId}.metainfo.xml.in \
        $out/share/metainfo/${appId}.metainfo.xml \
        --subst-var-by VERSION ${version} \
        --subst-var-by DATE ${date}

      desktop-file-validate $out/share/applications/${appId}.desktop

      for bin in ${lib.concatMapStringsSep " " (b: "$out/bin/" + b) binaries}; do
        wrapProgram "$bin" --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}"
      done
    ''
    # Like packaging/macos/package.sh, minus the codesigning, notarization and DMG. The binary
    # moves into the bundle (macOS finds Info.plist and the icon relative to the executable) and
    # bin/ links to it.
    + lib.optionalString isDarwin ''
      app="$out/Applications/${displayName}.app/Contents"
      install -Dm755 $out/bin/${pname} "$app/MacOS/${displayName}"
      ln -sf "$app/MacOS/${displayName}" $out/bin/${pname}
      install -Dm644 assets/app-icon/${pname}.icns "$app/Resources/${displayName}.icns"
      substitute packaging/macos/Info.plist.in "$app/Info.plist" \
        --subst-var-by VERSION ${version} \
        --subst-var-by SHORT_VERSION ${cargoVersion} \
        --subst-var-by BUILD_SHA ${rev}
      printf 'APPL????' > "$app/PkgInfo"
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
      platforms = lib.platforms.linux ++ lib.platforms.darwin;
      mainProgram = pname;
    }
    // (args.meta or { });
  }
)
