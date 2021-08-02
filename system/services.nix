{ config, pkgs, ... }:

{
  services = {
    flox.substituterAdded = true;

    borgbackup.jobs = {
      roberto = rec {
        user = "roberto";
        paths = [
          "/home/${user}/Documents"
          "/home/${user}/Downloads"
          "/home/${user}/Pictures"
        ];
        #exclude = [ "/nix" "'**/.cache'" ];
        doInit = false;
        repo = "yc4l17r5@yc4l17r5.repo.borgbase.com:repo";
        encryption = {
          mode = "repokey-blake2";
          passCommand = "${pkgs.pass}/bin/pass show yc4l17r5.repo.borgbase.com";
        };
        environment = { BORG_RSH = "${pkgs.openssh_gssapi_heimdal}/bin/ssh"; };
        compression = "auto,lzma";
        startAt = "Thu *-*-* 14:00:00";
      };
    };

    emacs = {
      defaultEditor = true;
      enable = true;
      install = true;
      package = pkgs.callPackage ./emacs.nix { };
    };

    fwupd.enable = true;
    kbfs.enable = true;
    keybase.enable = true;
    printing.enable = true;
    thermald.enable = true;
  };

  systemd = {
    tmpfiles.rules = [ "d /tmp 1777 root root 10d" ];
  };
}
