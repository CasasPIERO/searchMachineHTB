{ pkgs }: {
  deps = [
    pkgs.unixtools.util-linux
    pkgs.moreutils
    pkgs.jsbeautifier
    pkgs.bashInteractive
    pkgs.nodePackages.bash-language-server
    pkgs.man
  ];
}