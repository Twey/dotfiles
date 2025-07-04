{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    # TODO: integrate
    playerctl
    pulseaudio
  ];

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      main = {
        layer = "top";
        modules-left = ["hyprland/workspaces"];
        # modules-center = ["hyprland/window"];
        modules-right = ["network" "battery" "clock"];
        battery = {
          format = "{icon} {capacity}%";
          format-icons = ["" "" "" "" ""];
        };
        network = {
          format-wifi = "{icon} {essid}";
          format-icons = ["零" "壹" "貳" "參" "肆" "伍"];
        };
        clock = {
          format = " {:%H:%M}";
          format-alt = "{:%A the %dth of %B}";
          tooltip = true;
          tooltip-format = "{:%A the %dth of %B}";
        };
        "hyprland/workspaces".active-only = true;
      };
    };
  };

  services.hyprpaper = let
    trees = "${~/.wallpapers/watercolor-trees.jpeg}";
  in {
    enable = true;
    settings = {
      splash = false;
      preload = [ trees ];
      wallpaper = [ ", ${trees}" ];
    };
  };

  programs.fuzzel.enable = true;

  wayland.windowManager.hyprland = let
    workspaces = [
      { name = "term"; key = "2"; }
      { name = "dev"; key = "3"; }
      { name = "web"; key = "4"; }
      { name = "comms"; key = "comma"; }
      { name = "media"; key = "period"; }
      { name = "misc1"; key = "p"; }
    ];
  in {
    enable = true;

    settings = {
      env = [
          "GDK_BACKEND,wayland,x11,*"
          "QT_QPA_PLATFORM,wayland;xcb"
          "SDL_VIDEODRIVER,wayland"
          "CLUTTER_BACKEND,wayland"
          "NIXOS_OZONE_WL,1"
          "HYPRCURSOR_THEME,rose-pine-hyprcursor"
          "HYPRCURSOR_SIZE,24"
      ];

      monitor = [
        "eDP-1, preferred, auto, 1.333333"
        ", preferred, auto, 1"
      ];

      workspace = [
        "1, name:term"
        "name:dev"
        "name:web"
        "name:comms"
        "name:media"
        "name:misc1"

        "w[tv1], gapsout:0, gapsin:0"
        "f[1], gapsout:0, gapsin:0"
      ];

      "$mod" = "SUPER";

      bind = [
        "$mod, RETURN, exec, ${pkgs.foot}/bin/foot"
        "$mod, BACKSPACE, exec, ${pkgs.kickoff}/bin/kickoff"
        "$mod, L, exec, ${pkgs.hyprlock}/bin/hyprlock"
        "$mod, H, cyclenext, prev"
        "$mod, T, cyclenext, next"
        "$mod, DELETE, killactive,"
      ] ++ lib.concatMap ({key, name}: [
        "$mod, ${key}, workspace, name:${name}"
        "$mod SHIFT, ${key}, movetoworkspace, name:${name}"
      ]) workspaces;

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # Ref https://wiki.hyprland.org/Configuring/Workspace-Rules/
      # "Smart gaps" / "No gaps when only"
      # uncomment all if you wish to use that.
      windowrulev2 = [
        "bordersize 0, floating:0, onworkspace:w[tv1]"
        "rounding 0, floating:0, onworkspace:w[tv1]"
        "bordersize 0, floating:0, onworkspace:f[1]"
        "rounding 0, floating:0, onworkspace:f[1]"
      ];

      input = {
        kb_layout = "us";
        kb_variant = "dvorak";
        kb_options = "compose:caps";
      };

      decoration = {
        dim_inactive = true;
        inactive_opacity = 0.8;
      };

      general = {
        gaps_in = 6;
        gaps_out = 10;
        border_size = 0;
      };
    };
  };
}
