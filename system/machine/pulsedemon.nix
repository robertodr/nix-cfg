{ config, pkgs, ... }:

{
  # Use the systemd-boot EFI boot loader.
  boot = {
    kernel = {
      sysctl = {
        "kernel.perf_event_paranoid" = 0;
      };
    };
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      grub.device = "/dev/nvme0n1";
    };
    initrd.luks.devices = {
      root = {
        device = "/dev/nvme0n1p3";
        preLVM = true;
      };
    };
  };

  hardware = {
    pulseaudio = {
      enable = true;
      extraModules = [ pkgs.pulseaudio-modules-bt ];
      package = pkgs.pulseaudioFull;
      extraConfig = "load-module module-switch-on-connect";
      configFile = pkgs.writeText "default.pa" ''
        load-module module-bluetooth-policy
        load-module module-bluetooth-discover
        ## module fails to load with
        ##   module-bluez5-device.c: Failed to get device path from module arguments
        ##   module.c: Failed to load module "module-bluez5-device" (argument: ""): initialization failed.
        # load-module module-bluez5-device
        # load-module module-bluez5-discover
      '';
    };

    bluetooth = {
      enable = true;
      hsphfpd.enable = true;
      settings = { General = { Enable = "Source,Sink,Media,Socket"; }; };
    };
  };

  networking = {
    hostName = "pulsedemon";
    networkmanager.enable = true;
    useDHCP = false;
    interfaces = {
      enp0s31f6.useDHCP = true;
      wlp0s20f3.useDHCP = true;
    };
  };

  services = {
    hardware = {
      bolt.enable = true;
    };

    thermald.enable = true;

    thinkfan.enable = true;

    tlp = {
      enable = false;
      #extraConfig = ''
      #  START_CHARGE_THRESH_BAT0=75
      #  STOP_CHARGE_THRESH_BAT0=80

      #  CPU_SCALING_GOVERNOR_ON_AC=schedutil
      #  CPU_SCALING_GOVERNOR_ON_BAT=schedutil

      #  CPU_SCALING_MIN_FREQ_ON_AC=800000
      #  CPU_SCALING_MAX_FREQ_ON_AC=3500000
      #  CPU_SCALING_MIN_FREQ_ON_BAT=800000
      #  CPU_SCALING_MAX_FREQ_ON_BAT=2300000

      #  # Enable audio power saving for Intel HDA, AC97 devices (timeout in secs).
      #  # A value of 0 disables, >=1 enables power saving (recommended: 1).
      #  # Default: 0 (AC), 1 (BAT)
      #  SOUND_POWER_SAVE_ON_AC=0
      #  SOUND_POWER_SAVE_ON_BAT=1

      #  # Runtime Power Management for PCI(e) bus devices: on=disable, auto=enable.
      #  # Default: on (AC), auto (BAT)
      #  RUNTIME_PM_ON_AC=on
      #  RUNTIME_PM_ON_BAT=auto

      #  # Battery feature drivers: 0=disable, 1=enable
      #  # Default: 1 (all)
      #  NATACPI_ENABLE=1
      #  TPACPI_ENABLE=1
      #  TPSMAPI_ENABLE=1
      #'';
    };
  };
}
