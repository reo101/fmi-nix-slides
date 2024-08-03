{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , ...
    } @ inputs : flake-utils.lib.eachDefaultSystem (system:
      let
        inherit (nixpkgs) lib;
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
          ];
        };
      in
      with pkgs; {
        devShell = mkShell {
          buildInputs = [
            ### Main

            typst
            typst-lsp
            (pkgs.writeShellScriptBin "mimeopen" ''
              open -a Firefox "''${@}"
            '')
          ];
        };
    });
}
