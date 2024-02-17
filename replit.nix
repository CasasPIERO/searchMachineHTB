{ pkgs }: {
  deps = [
    pkgs.moreutils
    pkgs.jsbeautifier
    pkgs.bashInteractive
    pkgs.nodePackages.bash-language-server
    pkgs.man
  ];
}