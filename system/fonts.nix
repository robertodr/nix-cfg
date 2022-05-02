{ pkgs, ... }:

{
  fonts = {
    enableGhostscriptFonts = true;
    fontconfig = {
      enable = true;
      antialias = true;
    };
    fonts = with pkgs; [
      comfortaa
      corefonts # Microsoft free fonts
      dejavu_fonts
      fira
      fira-code
      fira-code-symbols
      gyre-fonts
      latinmodern-math
      material-design-icons
      material-icons
      nerdfonts
      open-sans
      tex-gyre-bonum-math
      tex-gyre-pagella-math
      tex-gyre-schola-math
      tex-gyre-termes-math
      ubuntu_font_family # Ubuntu fonts
      unifont # some international languages
      xits-math
    ];
  };
}
