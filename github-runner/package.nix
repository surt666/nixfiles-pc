# github-runner 2.338.0: its internal node (hashFiles) is node24; nixpkgs is still on 2.337.0, which wants node20.
# Drop this once nixpkgs has >= 2.338.0. deps.json: build passthru.fetch-deps and run it on this file.
{ pkgs }:
pkgs.github-runner.override {
  # nugetDeps is consumed when buildDotnetModule is called, so overrideAttrs cannot change it.
  buildDotnetModule =
    f:
    pkgs.buildDotnetModule (
      finalAttrs:
      let
        old = f finalAttrs;
      in
      old
      // {
        version = "2.338.0";
        src = old.src.override { hash = "sha256-AUbJ/nB6vuaY5/KMIv09cfLVvPqSF4ca168r2M7UJ8Q="; };
        nugetDeps = ./deps.json;
        doCheck = false;
      }
    );
}
