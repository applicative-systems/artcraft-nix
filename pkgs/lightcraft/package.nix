{
  lib,
  stdenv,
  mkCraftApp,
}:

mkCraftApp {
  pname = "lightcraft";
  description = "Organise photos and develop raw files, non-destructively";

  # At opt-level 3, LLVM's AArch64 instruction selection never finishes on
  # `lightcraft_engine::camera_preview::starting_colour` (the DAG combiner loops); at 2 the crate
  # builds in seconds.
  extraCargoBuildFlags = lib.optionals stdenv.hostPlatform.isAarch64 [
    "--config"
    "profile.release.package.lightcraft-engine.opt-level=2"
  ];
}
