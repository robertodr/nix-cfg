# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, options, ... }:
let
  baseConfig = {
    allowUnfree = true;
  };
  unstable = import <nixos-unstable> { config = baseConfig; };
in
{
  imports = [
    # hardware configuration from nixos-hardware
    "${builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; }}/lenovo/thinkpad/x1/7th-gen"
    # flox
    (import (fetchTarball "https://github.com/flox/nixos-module/archive/master.tar.gz"))
    # results of hardware scan
    ./hardware-configuration.nix
    # user configuration
    ./users.nix
    # services
    ./services.nix
    # fonts configuration
    ./fonts.nix
    # machine-specific configuration
    machine/pulsedemon.nix
    # window manager
    wm/i3.nix
  ];

  # Select internationalisation properties.
  console = {
    keyMap = "us";
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  # Home: "Europe/Stockholm";
  time.timeZone = "Europe/Stockholm";
  # Virginia
  #time.timeZone = "America/New_York";
  # Colorado
  #time.timeZone = "America/Denver";

  nix = {
    # automate `nix-store --optimise`
    autoOptimiseStore = true;

    buildCores = 2;

    # required by Cachix to be used as non-root user
    trustedUsers = [
      "root"
      "roberto"
    ];

    # automate garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    nixPath = options.nix.nixPath.default ++ [
      "nixpkgs-overlays=/etc/nixos/overlays-compat/"
    ];
  };

  nixpkgs = {
    config = baseConfig // {
      packageOverrides = pkgs: {
        kbfs = unstable.kbfs;
        keybase = unstable.keybase;
        keybase-gui = unstable.keybase-gui;
        poetry = unstable.poetry;
        virtualbox = unstable.virtualbox;
      };
      permittedInsecurePackages = [
        "openssh-with-gssapi-8.4p1"
      ];
    };
    overlays = [
      (
        post: pre: {
          openssh_gssapi_heimdal = pre.openssh_gssapi.override {
            withKerberos = true;
            libkrb5 = post.heimdalFull;
          };
          borgbackup = pre.borgbackup.override {
            openssh = post.openssh_gssapi_heimdal;
          };
        }
      )
    ];
  };

  environment = {
    systemPackages = with pkgs; [
      acpi
      age
      atool
      binutils
      borgbackup
      brave
      cacert
      coreutils
      cryptsetup
      curl
      dmidecode
      file
      findutils
      gnupg1
      keybase-gui
      neovim
      pass
      patchelf
      pciutils
      poetry
      psmisc
      rsync
      sops
      squashfsTools
      tree
      unrar
      unzip
      usbutils
      wget
      which
      xbindkeys
      xclip
      xdg_utils
      xorg.lndir
      xsel
      zip
    ];
  };

  programs = {
    browserpass.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    singularity.enable = true;
    ssh.package = pkgs.openssh_gssapi_heimdal;
    light.enable = true;
  };

  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = false;
    };
    virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };
  };

  system.stateVersion = "21.05";

  krb5 = {
    enable = true;
    kerberos = pkgs.heimdalFull;
    domain_realm = {
      ".pdc.kth.se" = "NADA.KTH.SE";
    };
    appdefaults = {
      forwardable = "yes";
      forward = "yes";
      krb4_get_tickets = "no";
    };
    libdefaults = {
      default_realm = "NADA.KTH.SE";
      dns_lookup_realm = true;
      dns_lookup_kdc = true;
    };
  };
}
