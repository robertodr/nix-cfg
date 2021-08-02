{ pkgs, ... }:

{
  users = {
    # Define a user account. Don't forget to set a password with ‘passwd’.
    extraUsers.roberto = {
      description = "Roberto Di Remigio";
      extraGroups = [
        "adm"
        "audio"
        "cdrom"
        "disk"
        "docker"
        "networkmanager"
        "root"
        "systemd-journal"
        "users"
        "vboxusers"
        "video"
        "wheel"
      ];
      home = "/home/roberto";
      createHome = true;
      isNormalUser = true;
      uid = 1000;
      shell = pkgs.fish;
    };
  };
}
