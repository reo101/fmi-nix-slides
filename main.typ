
#import "@preview/slydst:0.1.1": *
#show: slides.with(
  title: "Introduction to the Nix Ecosystem",
  subtitle: "Exploring Nix Language, Package Manager, and OS",
  date: "July 28, 2024",
  authors: (
    "Pavel Atanasov (reo101)",
    "Kamen Mladenov (Syndamia)",
  ),
  layout: "medium",
  ratio: 4/3, 
  title-color: none,
)

#import "@preview/codly:1.0.0": *
#show: codly-init.with()
#codly(
  languages: (
    nix: (
      name: "Nix",
      icon: text(font: "FiraCode Nerd Font Mono", " "),
      color: rgb("#CE412B"),
    ),
    rust: (
      name: "Rust",
      icon: text(font: "FiraCode Nerd Font Mono", " "),
      color: rgb("#CE412B"),
    ),
  )
)
#set raw(syntaxes: "./dist/nix.sublime-syntax")

== Outline

#outline()

= Introduction

== What is Nix?

#figure(image("./dist/nixos-artwork/logo/nixos.svg", width: 50%), caption: "Nix Logo")

Pravil mi bil....... prezentaciq

```nix
{
  kek = inputs.flake-parts.lib.mkFlake { inherit inputs; } ({ withSystem, flake-parts-lib, ... }: {
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
    in null;
  };});
}
```

#v(1fr)

#lorem(10)

= The Nix Language

== Functional Package Management

#figure(image("./dist/nixos-artwork/logo/nixos.svg", width: 60%), caption: "Nix Language")

The Nix language provides a purely functional approach to package management, enabling reproducibility and sharing of development environments.

#v(1fr)

#lorem(15)

= Nix Package Manager

== Reliable and Reproducible Builds

#figure(image("./dist/nixos-artwork/logo/nixos.svg", width: 60%), caption: "Nix Package Manager")

The Nix package manager allows users to build and manage packages in a declarative manner, ensuring consistent builds across different systems.

#v(1fr)

#lorem(15)

= NixOS

== The Declarative Linux Distribution

#figure(image("./dist/nixos-artwork/logo/nixos.svg", width: 60%), caption: "NixOS")

NixOS is a Linux distribution built on top of the Nix package manager, featuring a unique approach to configuration management and deployment.

#v(1fr)

#lorem(15)

= Conclusion

== Benefits of Using Nix

#figure(image("./dist/nixos-artwork/logo/nixos.svg", width: 60%), caption: "Benefits of Nix")

Nix provides a versatile and efficient ecosystem for developers looking for reproducible builds, environment management, and system configuration.

#v(1fr)

#lorem(10)
