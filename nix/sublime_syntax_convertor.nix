{ lib, bundlerApp, makeWrapper, fetchFromGitHub, ... }:

bundlerApp {
  pname = "SublimeSyntaxConvertor";
  gemdir = fetchFromGitHub {
    owner = "aziz";
    repo = "SublimeSyntaxConvertor";
    rev = "8af296b42c7497455bb495bcc43bcbe60b1c464f";
    hash = "sha256-2Mvd7H1EyxTgMP3IhoxXIKw5D3UyMzIGHnBzkiVBmDk=";
  };
  exes = [ "sublime_syntax_convertor" ];

  nativeBuildInputs = [
    makeWrapper
  ];

  postBuild = ''
    wrapProgram $out/bin/sublime_syntax_convertor --prefix PATH : ${lib.makeBinPath [ ]}
  '';
}
