let
  pkgs = import <nixpkgs> {};
in
let
  unstable = import
    (builtins.fetchTarball https://github.com/NixOS/nixpkgs/archive/refs/heads/nixpkgs-unstable.tar.gz)
    { config = pkgs.config; };
in
pkgs.mkShell {
  buildInputs = [
  pkgs.erlang
  pkgs.cowsay
  pkgs.elixir
  pkgs.zsh
  pkgs.stdenv
  pkgs.inotify-tools
  pkgs.glibcLocales
  ];
    shellHook =
  ''
  cowsay "IRCHub Development Shell!"
  '';

}
