{
  description = "A Typst project";

  nixConfig = {
    extra-substituters = [
      "https://typst-nix.cachix.org"
    ];
    extra-trusted-public-keys = [
      "typst-nix.cachix.org-1:OzDUMt0nd4wlI1AHucBPnchl4utWXeFTtUFt8XZ3DbA="
    ];
  };

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };

    typix = {
      url = "github:loqusion/typix/0.1.5";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    typst-packages = {
      url = "github:typst/packages";
      flake = false;
    };

    nixos-artwork = {
      url = "github:NixOS/nixos-artwork";
      flake = false;
    };

    ruby-nix = {
      url = "github:inscapist/ruby-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sublime-nix = {
      url = "github:wmertens/sublime-nix";
      flake = false;
    };

    # Example of downloading icons from a non-flake source
    # font-awesome = {
    #   url = "github:FortAwesome/Font-Awesome";
    #   flake = false;
    # };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } ({ withSystem, flake-parts-lib, ... }: {
      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      perSystem = { lib, pkgs, system, ... }:
        let
          typixLib = inputs.typix.lib.${system};

          typstPackagesSrc = pkgs.symlinkJoin {
            name = "typst-packages-src";
            paths = [
              "${inputs.typst-packages}/packages"
              # "${inputs.typst-slydst}"
            ];
          };

          typstPackagesCache = pkgs.stdenv.mkDerivation {
            name = "typst-packages-cache";
            src = typstPackagesSrc;
            dontBuild = true;
            installPhase = ''
              mkdir -p "$out/typst/packages"
              cp -LR --reflink=auto --no-preserve=mode -t "$out/typst/packages" "$src"/*
            '';
          };

          src = typixLib.cleanTypstSource ./.;
          commonArgs = {
            typstSource = "main.typ";

            fontPaths = [
              # Add paths to fonts here
              # "${pkgs.roboto}/share/fonts/truetype"
            ];

            virtualPaths = let
              # nixos-artwork = pkgs.callPackage (import inputs.nixos-artwork) { };
            in [
              # Add paths that must be locally accessible to typst here
              # {
              #   dest = "icons";
              #   src = "${inputs.font-awesome}/svgs/regular";
              # }
              {
                dest = "./dist/chad.jpeg";
                src = pkgs.fetchurl {
                  name = "chad.jpeg";
                  url = "https://syndamia.com/img/face.jpeg";
                  hash = "sha256-9RBlJfmegIyZGBiHIo+/E6z2RXqSDmDi5Bxd6/nCoYc=";
                };
              }
              {
                dest = "./dist/nixos-artwork/";
                src = "${inputs.nixos-artwork}";
              }
              {
                dest = "./dist/sublime-nix";
                src = "${inputs.sublime-nix}";
              }
              {
                dest = "./dist/nix.sublime-syntax";
                src = ./nix.sublime-syntax;
                # src = pkgs.runCommand "nix.sublime-syntax" {
                #   buildInputs = [
                #     (pkgs.callPackage ./nix/sublime_syntax_convertor.nix { })
                #   ];
                # } ''
                #   cp "${inputs.sublime-nix}/nix.tmLanguage" .
                #   sublime_syntax_convertor .
                #   cp nix.sublime-syntax $out
                # '';
              }
            ];
          };

          # Compile a Typst project, *without* copying the result
          # to the current directory
          build-drv = typixLib.buildTypstProject (commonArgs // {
            XDG_CACHE_HOME = typstPackagesCache;
            inherit src;
          });

          # Compile a Typst project, and then copy the result
          # to the current directory
          build-script = typixLib.buildTypstProjectLocal (commonArgs // {
            # FIXME: this is NOT used on `darwin`
            XDG_CACHE_HOME = typstPackagesCache;
            inherit src;
          });

          # Watch a project and recompile on changes
          watch-script = typixLib.watchTypstProject commonArgs;
        in {
          checks = {
            inherit build-drv build-script watch-script;
          };

          packages = {
            default = build-drv;
          };

          apps = rec {
            default = watch;
            build = {
              type = "app";
              program = "${build-script}/bin/typst-build";
            };
            watch = {
              type = "app";
              program = "${watch-script}/bin/typst-watch";
            };
          };

          devShells = {
            default = typixLib.devShell {
              inherit (commonArgs) fontPaths virtualPaths;
              packages = [
                # HACK: `nix-monitored` doesn't work with `apps`
                pkgs.nixVersions.latest

                # WARNING: Don't run `typst-build` directly, instead use `nix run .#build`
                # See https://github.com/loqusion/typix/issues/2
                # build-script
                watch-script
                # More packages can be added here, like typstfmt
                pkgs.typstfmt
                # pkgs.typst-lsp
                pkgs.tinymist
              ];
            };
            sublime_syntax_convertor = let
              sublime_syntax_convertor = (pkgs.callPackage ./nix/sublime_syntax_convertor.nix {
                inherit (inputs) ruby-nix;
              });
            in pkgs.mkShell {
                buildInputs = [];
            };
          };
        };
    });
}
