{ config, pkgs, lib, user, ... }:
{
  programs.waybar = {
    enable = true;
    # systemd.enable = true;
    package =pkgs.waybar;
    style = ''
      ${builtins.readFile "${pkgs.waybar}/etc/xdg/waybar/style.css"}

      * {
          font-size: 17px;
      }

      /*
      window#waybar {
        background: transparent;
        border-bottom: none;
      }
      */
    
      window#waybar {
          background-color: #0e0e0e;
          color: #dbdbdb;
          transition-property: background-color;
          transition-duration: .5s;
      }

      window#waybar.hidden {
          opacity: 0.2;
      }

      window#waybar.termite {
          background-color: #3f3f3f;
      }

      window#waybar.chromium {
          background-color: #000000;
          border: none;
      }

      button {
          box-shadow: inset 0 -3px transparent;
          border: none;
          border-radius: 0;
          color: #dbdbdb;
      }

      button:hover {
      }

      #workspaces button {
          padding: 0;
          margin-top: 0.2rem;
          margin-bottom: 0.4rem;
          margin-right: 0.5rem;
          background-color: #262525;
          border: none;
          border-radius: 50%;
      }

      #workspaces button:hover {
          background: rgba(0, 0, 0, 0.2);
      }

      #workspaces button.active {
          background-color: #e0c520;
          color: #000000;
      }

      #workspaces button.urgent {
          background-color: #f17528;
          color: #000000;
      }

      #mode {
          background-color: #64727D;
          border-bottom: 3px solid #ffffff;
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #disk,
      #temperature,
      #backlight,
      #network,
      #pulseaudio,
      #wireplumber,
      #custom-media,
      #tray,
      #mode,
      #idle_inhibitor,
      #scratchpad,
      #mpd {
          padding: 0 0.625rem;
          color: #dbdbdb;
      }

      #window,
      #workspaces {
          margin: 0 0.2rem;
      }

      .modules-left{
          margin-left: 0.2rem;
      }

      .modules-right{
          margin-right: 0.2rem;
      }

      .modules-right > widget > *{
          border-radius: 0.8rem;
          margin-top: 0.3rem;
          margin-bottom: 0.3rem;
      }

      #clock {
          background-color: #262525;
          color: #dbdbdb;
          border-radius: 1rem;
          margin-top: 0.3rem;
          margin-bottom: 0.3rem;
      }

      #battery {
          background-color: #262525;
          color: #dbdbdb;
      }

      #battery.charging, #battery.plugged {
          color: #dbdbdb;
          background-color: #262525;
      }

      #battery.critical:not(.charging) {
          background-color: #363535;
          color: #dbdbdb;
      }

      label:focus {
          background-color: #262525;
      }

      #cpu {
          background-color: #262525;
          color: #dbdbdb;
      }

      #memory {
          background-color: #262525;
          color: #dbdbdb;
      }

      #disk {
          background-color: #262525;
          color: #dbdbdb;
      }

      #backlight {
          background-color: #90b1b1;
      }

      #network {
          background-color: #262525;
          color: #dbdbdb;
      }

      #network.disconnected {
          background-color: #262525;
          color: #dbdbdb;
      }

      #pulseaudio {
          background-color: #262525;
          color: #dbdbdb;
      }

      #pulseaudio.muted {
          background-color: #262525;
          color: #dbdbdb;
      }

      #wireplumber {
          background-color: #262525;
          color: #dbdbdb;
      }

      #wireplumber.muted {
          background-color: #262525;
          color: #dbdbdb;
      }

      #custom-media {
          background-color: #66cc99;
          color: #2a5c45;
          min-width: 100px;
      }

      #custom-media.custom-spotify {
          background-color: #66cc99;
      }

      #custom-media.custom-vlc {
          background-color: #ffa000;
      }

      #temperature {
          background-color: #f0932b;
      }

      #temperature.critical {
          background-color: #eb4d4b;
      }

      #tray {
          background-color: #262525;
          color: #dbdbdb;
      }

      #tray > .passive {
          -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
          -gtk-icon-effect: highlight;
          background-color: #eb4d4b;
      }

      #idle_inhibitor {
          background-color: #2d3436;
      }

      #idle_inhibitor.activated {
          background-color: #ecf0f1;
          color: #2d3436;
      }

      #mpd {
          background-color: #66cc99;
          color: #2a5c45;
      }

      #mpd.disconnected {
          background-color: #f53c3c;
      }

      #mpd.stopped {
          background-color: #90b1b1;
      }

      #mpd.paused {
          background-color: #51a37a;
      }

      #language {
          background: #00b093;
          color: #740864;
          padding: 0 5px;
          margin: 0 5px;
          min-width: 16px;
      }

      #keyboard-state {
          background: #97e1ad;
          color: #dbdbdb;
          padding: 0 0px;
          margin: 0 5px;
          min-width: 16px;
      }

      #keyboard-state > label {
          padding: 0 5px;
      }

      #keyboard-state > label.locked {
          background: rgba(0, 0, 0, 0.2);
      }

      #scratchpad {
          background: rgba(0, 0, 0, 0.2);
      }

      #scratchpad.empty {
              background-color: transparent;
      }
    '';
    settings = [{
      height = 40;
      layer = "top";
      position = "top";
      modules-left = ["cpu" "memory" "custom/weather" "hyprland/workspaces"];
      modules-center = [ "mpris" ];
      modules-right = [
        "pulseaudio"
        "network"
        "backlight"
        "temperature"
        "battery"
        "clock"
        "tray"
        "hyprland/language"
        "custom/wallpaper"
        "custom/power-menu"
      ];
      "hyprland/workspaces" = {
        format = "{name}";
        all-outputs = true;
        on-click = "activate";
        format-icons = {
          active = " 󱎴";
          default = "󰍹";
        };
        persistent-workspaces = {
          "1" = [];
          "2" = [];
          "3" = [];
          "4" = [];
          "5" = [];
          "6" = [];
          "7" = [];
          "8" = [];
          "9" = [];
        };
      };
      "hyprland/language" = {
        format = "{short}";
      };
       "backlight" = {
        device = "intel_backlight";
        format = "{icon}";
        tooltip = true;
        format-alt = "<small>{percent}%</small>";
        format-icons = ["󱩎" "󱩏" "󱩐" "󱩑" "󱩒" "󱩓" "󱩔" "󱩕" "󱩖" "󰛨"];
        on-scroll-up = "brightnessctl set 1%+";
        on-scroll-down = "brightnessctl set 1%-";
        smooth-scrolling-threshold = "2400";
        tooltip-format = "Brightness {percent}%";
      };
      "mpris" = {
        format = "{player_icon} {title}";
        format-paused = " {status_icon} <i>{title}</i>";
        max-length = 80;
        player-icons = {
          default = "▶";
          mpv = "🎵";
        };
        status-icons = {
          paused = "⏸";
        };
      };
      tray = { 
        # spacing = 10; 
        icon-size = 30; 
      };
      battery = {
        format = "{capacity}% {icon}";
        format-warning = "{icon}";
        format-critical = "{icon}";
        format-alt = "{time} {icon}";
        format-charging = "{capacity}% ";
        format-icons = [ "" "" "" "" "" ];
        format-plugged = "{capacity}% ";
        states = {
          critical = 15;
          warning = 30;
        };
      };
      clock = {
        format-alt = "{:%Y-%m-%d}";
        tooltip-format = "{:%Y-%m-%d | %H:%M}";
      };
      cpu = {
        format = "{usage}% ";
        tooltip = true;
      };
      memory = { format = "{}% "; };
      network = {
        interval = 1;
        min-length = 10;
        fixed-width = 10;
        format-alt = "{ifname}: {ipaddr}/{cidr}";
        format-disconnected = "Disconnected ⚠";
        format-ethernet = "{ifname}: {ipaddr}/{cidr}   up: {bandwidthUpBits} down: {bandwidthDownBits}";
        format-linked = "{ifname} (No IP) ";
        format-wifi = "{essid} ({signalStrength}%) ";
        # on-click = "~/.nixfiles/scripts/rofi-network-manager.sh";
      };
      pulseaudio = {
        format = "{volume}% {icon} {format_source}";
        format-bluetooth = "{volume}% {icon} {format_source}";
        format-bluetooth-muted = " {icon} {format_source}";
        format-icons = {
          car = "";
          default = [ "" "" "" ];
          handsfree = "";
          headphones = "";
          headset = "";
          phone = "";
          portable = "";
        };
        format-muted = " {format_source}";
        format-source = "{volume}% ";
        format-source-muted = "";
        on-click = "pavucontrol";
      };
      # "sway/mode" = { format = ''<span style="italic">{}</span>''; };
      temperature = {
        critical-threshold = 80;
        format = "{temperatureC}°C {icon}";
        format-icons = [ "" "" "" ];
      };
      "custom/weather" = {
        exec = "nix-shell ~/.nixfiles/scripts/weather.py";
        restart-interval = 300;
        return-type = "json";
      };
      "custom/wallpaper" = {
        format = "";
        # interval = 60;
        on-click = "~/.nixfiles/scripts/changewallpaper.sh";
        # exec = "~/.nixfiles/scripts/changewallpaper.sh";
        # format-alt = "~/.nixfiles/scripts/changewallpaper.sh";
      };
      "custom/power-menu" = {
        format = "{percentage}Hz";
        on-click = "~/.nixfiles/scripts/screenHz.sh";
        return-type = "json";
        exec = "cat ~/.nixfiles/scripts/hz.json";
        interval = 1;
        tooltip = true;
      };
    }];
  };
}
