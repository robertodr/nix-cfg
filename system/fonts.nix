{ pkgs, ... }:

{
  fonts = {
    enableGhostscriptFonts = true;
    fontconfig = {
      enable = true;
      antialias = true;
    };
    fonts = with pkgs; [
      corefonts # Microsoft free fonts
      dejavu_fonts
      fira-code
      fira-code-symbols
      font-awesome-ttf
      google-fonts
      gyre-fonts
      hack-font
      hasklig
      inconsolata # monospaced
      latinmodern-math
      lato
      material-design-icons
      material-icons
      nerdfonts
      open-sans
      source-code-pro
      source-sans-pro
      source-serif-pro
      symbola
      terminus_font
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
