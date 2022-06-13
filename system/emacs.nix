{ pkgs ? import <nixpkgs> { } }:
let
  myEmacs = pkgs.emacsPgtkNativeComp.overrideAttrs (attrs: {
    # I don't want emacs.desktop file because I only use
    # emacsclient.
    postInstall = (attrs.postInstall or "") + ''
      rm $out/share/applications/emacs.desktop
    '';
  });
  emacsWithPackages = (pkgs.emacsPackagesFor myEmacs).emacsWithPackages;
in
emacsWithPackages (epkgs: [ epkgs.vterm ])
