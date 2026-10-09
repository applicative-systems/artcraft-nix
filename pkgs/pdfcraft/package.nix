{
  mkCraftApp,
  cmake,
}:

mkCraftApp {
  pname = "pdfcraft";
  rev = "81a6ca456cb88d1992dfcaa1bfdbd20e1490d63f";
  date = "2026-10-08";
  hash = "sha256-+dam7dYpMm7DdWijsmCZI4K0Wl6M5ol1sORL70OAr48=";
  cargoHash = "sha256-gN16qs6h1QQQEV/rxbHu9eib/7WPvzZ14WjAQTeWkjc=";
  description = "Read, organize, combine, split and secure PDFs";
  extraNativeBuildInputs = [ cmake ];
  # cmake is only for aws-lc-sys' build script, not the top-level build.
  dontUseCmakeConfigure = true;
  vendorPatches."rten-gemm-0.26.0" = [ ./rten-gemm-avx512vnni-inline-asm.patch ];
}
