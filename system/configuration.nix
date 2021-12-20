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
    "${builtins.fetchTarball "https://github.com/NixOS/nixos-hardware/archive/master.tar.gz"}/lenovo/thinkpad/x1/7th-gen"
    # flox
    #(import (fetchTarball "https://github.com/flox/nixos-module/archive/master.tar.gz"))
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

    binaryCaches = [ "https://nix-community.cachix.org/" ];

    binaryCachePublicKeys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    buildCores = 2;

    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      experimental-features = nix-command flakes
    '';

    # automate garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    nixPath = options.nix.nixPath.default ++ [
      "nixpkgs-overlays=/etc/nixos/overlays-compat/"
    ];

    package = pkgs.nix_2_4;

    # required by Cachix to be used as non-root user
    trustedUsers = [
      "root"
      "roberto"
    ];
  };

  nixpkgs = {
    config = baseConfig // {
      packageOverrides = pkgs: {
        betterlockscreen = unstable.betterlockscreen;
        google-fonts = unstable.google-fonts;
        kbfs = unstable.kbfs;
        keybase = unstable.keybase;
        keybase-gui = unstable.keybase-gui;
        poetry = unstable.poetry;
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
      (import (builtins.fetchGit {
        url = "https://github.com/nix-community/emacs-overlay.git";
        ref = "master";
        rev = "18a1276506aedee059671415cce1a87381fceaec";
      }))
    ];
  };

  environment = {
    # TODO clean up this list, i.e. move stuff to home-manager
    systemPackages = with pkgs; [
      acpi # show battery status and other ACPI information
      age # modern encryption tool with small explicit keys
      atool # archive command line helper
      binutils # tools for manipulating binaries (linker, assembler, etc.)
      borgbackup # deduplicating archiver with compression and encryption
      cacert # a bundle of X.509 certificates of public Certificate Authorities (CA)
      coreutils # the basic file, shell and text manipulation utilities of the GNU operating system
      cryptsetup # LUKS for dm-crypt
      curl # a command line tool for transferring files with URL syntax
      dmidecode # a tool that reads information about your system's hardware from the BIOS according to the SMBIOS/DMI standard
      file # a program that shows the type of files
      findutils # GNU Find Utilities, the basic directory searching utilities of the GNU operating system
      gnupg1 # modern (2.1) release of the GNU Privacy Guard, a GPL OpenPGP implementation with symbolic links for gpg and gpgv
      keybase-gui # the Keybase official GUI
      libseccomp # High level library for the Linux Kernel seccomp filter
      neovim # vim text editor fork focused on extensibility and agility
      pass # stores, retrieves, generates, and synchronizes passwords securely
      patchelf # a small utility to modify the dynamic linker and RPATH of ELF executables
      pciutils # a collection of programs for inspecting and manipulating configuration of PCI devices
      poetry # python dependency management and packaging made easy
      psmisc # a set of small useful utilities that use the proc filesystem (such as fuser, killall and pstree)
      rsync # a fast incremental file transfer utility
      squashfsTools # tool for creating and unpacking squashfs filesystems
      tree # command to produce a depth indented directory listing
      unrar # utility for RAR archives
      unzip # an extraction utility for archives compressed in .zip format
      usbutils # tools for working with USB devices, such as lsusb
      wget # tool for retrieving files using HTTP, HTTPS, and FTP
      which # shows the full path of (shell) commands
      xbindkeys # launch shell commands with your keyboard or your mouse under X Window
      xclip # tool to access the X clipboard from a console application
      xdg-utils # a set of command line tools that assist applications with a variety of desktop integration tasks
      xorg.lndir # create a shadow directory of symbolic links to another directory tree
      xsel # command-line program for getting and setting the contents of the X selection
      zip # compressor/archiver for creating and modifying zipfiles
    ];
  };

  programs = {
    light.enable = true;
    singularity.enable = true;
    ssh.package = pkgs.openssh_gssapi_heimdal;
    weylus = {
      enable = true;
      users = [ "roberto" ];
      openFirewall = true;
    };
  };

  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = false;
    };
    virtualbox.host = {
      enable = true;
    };
  };

  system.stateVersion = "21.11";

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
