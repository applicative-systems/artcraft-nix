{
  mkCraftApp,
  cmake,
}:

mkCraftApp {
  pname = "pdfcraft";
  description = "Read, organize, combine, split and secure PDFs";
  extraNativeBuildInputs = [ cmake ];
  # cmake is only for aws-lc-sys' build script, not the top-level build.
  dontUseCmakeConfigure = true;
  vendorPatches."rten-gemm-0.26.0" = [ ./rten-gemm-avx512vnni-inline-asm.patch ];
}
