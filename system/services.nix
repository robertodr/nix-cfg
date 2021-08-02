{ config, pkgs, ... }:

{
  hardware = {
    pulseaudio = {
      enable = true;
      extraModules = [ pkgs.pulseaudio-modules-bt ];
      package = pkgs.pulseaudioFull;
      extraConfig = "load-module module-switch-on-connect";
    };

    bluetooth = {
      enable = true;
      settings = { General = { Enable = "Source,Sink,Media,Socket"; }; };
    };
  };

  services = {
    blueman.enable = true;

    flox.substituterAdded = true;

    gnome.gnome-keyring.enable = true;

    upower.enable = true;

    dbus = {
      enable = true;
      packages = [ pkgs.gnome3.dconf ];
    };

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

    hardware = {
      bolt.enable = true;
    };

    fwupd.enable = true;
    kbfs.enable = true;
    keybase.enable = true;
    printing.enable = true;
    thermald.enable = true;
    thinkfan.enable = true;

    # Enable the X11 windowing system.
    xserver = {
      enable = true;
      autoRepeatDelay = 200;
      autoRepeatInterval = 25;
      enableCtrlAltBackspace = true;
      exportConfiguration = true;
      layout = "it(us),no";
      xkbModel = "pc105";
      xkbOptions = "grp:alt_shift_toggle";
      # Enable touchpad support.
      libinput = {
        enable = true;
        mouse = {
          naturalScrolling = true;
        };
        touchpad = {
          naturalScrolling = true;
          scrollMethod = "twofinger";
          clickMethod = "clickfinger";
        };
      };
      # Desktop manager
      desktopManager = {
        # maybe remove?
        gnome.enable = true;
        xterm.enable = false;
      };
      # Display manager
      displayManager = {
        defaultSession = "none+i3";
        gdm.enable = true;
        # LightDM?
        # no Wayland, just X11
        gdm.wayland = false;
      };
      windowManager = {
        i3 = {
          enable = true;
          package = pkgs.i3-gaps;
          extraPackages = with pkgs; [
            multilockscreen
          ];
        };
      };
    };
  };

  systemd = {
    services.upower.enable = true;

    tmpfiles.rules = [ "d /tmp 1777 root root 10d" ];
  };
}
