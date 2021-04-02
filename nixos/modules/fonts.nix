{ lib, pkgs, ... }:

{ fonts =
  { fontDir.enable = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs;
    [ andagii
      anonymousPro
      aurulent-sans
      bakoma_ttf
      cantarell_fonts
      clearlyU
      cm_unicode
      # corefonts # non-free
      dejavu_fonts
      dosemu_fonts
      eb-garamond
      emojione
      twemoji-color-font
      freefont_ttf
      gentium
      ibm-plex
      inconsolata
      iosevka-bin
      ipafont
      junicode
      # kochi-substitute-naga10 # non-free
      kochi-substitute
      liberation_ttf
      libertine
      libre-baskerville
      # lmodern # too tall
      mph_2b_damase
      nafees
      oldstandard
      poly
      roboto
      roboto-mono
      roboto-slab
      sarasa-gothic
      tempora_lgc
      terminus_font
      theano
      tipa
      ttf_bitstream_vera
      ubuntu_font_family
      ucsFonts
      unifont
      vistafonts
      wqy_microhei
      wqy_zenhei ] ++
    (with lohit-fonts;
    [ assamese
      bengali
      devanagari
      gujarati
      gurmukhi
      kannada
      malayalam
      marathi
      nepali
      odia
      tamil-classical
      tamil
      telugu
      kashmiri
      konkani
      maithili
      sindhi ]); }; }
