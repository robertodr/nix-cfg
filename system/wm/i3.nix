{ config, lib, pkgs, ... }:

{
  programs.dconf.enable = true;

  services = {
    gnome.gnome-keyring.enable = true;

    dbus = {
      enable = true;
      packages = [ pkgs.gnome3.dconf ];
    };

    xserver = {
      enable = true;

      # keyboard
      autoRepeatDelay = 200;
      autoRepeatInterval = 25;
      enableCtrlAltBackspace = true;
      exportConfiguration = true;
      layout = "it(us),no";
      xkbModel = "pc105";
      xkbOptions = "grp:alt_shift_toggle";

      # mouse and touchpad
      libinput = {
        enable = true;
        mouse = {
          naturalScrolling = true;
        };
        touchpad = {
          disableWhileTyping = true;
          naturalScrolling = true;
          scrollMethod = "twofinger";
          clickMethod = "clickfinger";
        };
      };

      serverLayoutSection = ''
        Option "StandbyTime" "0"
        Option "SuspendTime" "0"
        Option "OffTime"     "0"
      '';

      desktopManager = {
        xterm.enable = false;
      };

      displayManager = {
        defaultSession = "none+i3";
        lightdm = {
          enable = true;
          # FIXME
          #background = ;
          greeters.enso.enable = true;
        };
      };

      windowManager.i3 = {
        enable = true;
        package = pkgs.i3-gaps;
        extraPackages = with pkgs; [ multilockscreen ];
      };
    };
  };

  services.blueman.enable = true;

  upower.enable = true;
  systemd.services.upower.enable = true;
}
