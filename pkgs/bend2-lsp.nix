# Community Bend 2 LSP (formatting, diagnostics, hover); not in nixpkgs.
{ buildNpmPackage, fetchFromGitHub, nodejs_26, lib }:
buildNpmPackage rec {
  pname = "bend2-lsp";
  version = "0.2.0";
  src = fetchFromGitHub {
    owner = "don2e4";
    repo = "bend2-lsp";
    rev = "v${version}";
    hash = "sha256-G/+j4l8krzar4hN2Hs7i94ylChQyj0alb7zg5uojwwc=";
  };
  npmDepsHash = "sha256-dzm7k/L8rCJyZFZcoGV4aMjSzZcGJ22D2j4azit/ybM=";
  nodejs = nodejs_26;
  meta.mainProgram = "bend2-lsp";
}
