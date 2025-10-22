{config, pkgs, lib, user, kernelPackages, nvidiaPackage, ...}:
{
  wayland.windowManager.hyprland.enable = true;
  # wlr-randr to find monitors
  wayland.windowManager.hyprland.extraConfig = 
  ''
    # Builtin monitor
    # monitor=,preferred,auto,1 # Fallback
    # monitor=eDP-1,2560x1600@60,5120x0,1.25
    # monitor=Unknown-1,1920x1600@60,auto,1
    monitor=HDMI-A-2,5120x2160@60,0x0,1
    # monitor=DP-1,5120x2160@60,0x0,1
    # monitor=DP-2,5120x2160@60,0x0,1
    # monitor=DP-2,preferred,0x0,1,mirror,eDP-1
    # Mirroring can't scale resolution
    # monitor=HDMI-A-1,2560x1600@30.0,auto,1,mirror,eDP-1
    # monitor=HDMI-A-1,preferred,auto,1,mirror,eDP-1
    # monitor=HDMI-A-1,preferred,0x0,1,mirror,eDP-1
    # Display port monitor to the left of edp-1
    # Add for HDMI too
    #unknown set to preferred resolution 
    # monitor=,preferred,auto,1
    #unknown set to highest resolution 
    #monitor=,highres,auto,1

    # See https://wiki.hyprland.org/Configuring/Keywords/ for more

    # Execute your favorite apps at launch
    exec-once = waybar & firefox #& hyprpaper 
    exec-once = hypridle
    # exec-once = waybar & google-chrome-stable #& firefox #& hyprpaper
    # exec-once = ~/.config/hypr/scripts/suspend.sh
    # exec-once = wl-clipboard-history -t
    # Notification 
    # exec-once = poweralertd
    # exec-once = syncthing
    # exec-once = sleep 4; qsyncthingtray
    # Wallpaper
    exec-once = ~/.nixfiles/scripts/changewallpaper.sh
    # exec-once= bash ~/.config/waybar/scripts/changewallpaper.sh
    # Bluetooth
    # exec-once=blueman-applet # Make sure you have installed blueman + blueman-utils

    exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP 
    exec-once = systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DBUS_SESSION_BUS_ADDRESS

    # Screen Sharing
    exec-once = ~/.nixfiles/scripts/screensharing.sh

    env_cursor_theme=Hyprcursor
    env_cursor_size=48

    # Source a file (multi-file configs)
    # source = ~/.config/hypr/myColors.conf

    # Some default env vars.
    # env = XCURSOR_SIZE,28
    # env = XCURSOR_THEME,Bibata-cursors

    env = LIBVA_DRIVER_NAME,nvidia
    env = XDG_SESSION_TYPE,wayland
    env = GBM_BACKEND,nvidia-drm
    env = __GLX_VENDOR_LIBRARY_NAME,nvidia
    env = WLR_DRM_NO_ATOMIC,1
    env = CUDA_CACHE_DISABLE,1

    cursor {
        no_hardware_cursors = true
    }

    animations {
        enabled = false
    }

    misc {
        vrr = 0
        disable_autoreload = true
        disable_hyprland_logo = true
        mouse_move_enables_dpms = true
        key_press_enables_dpms = true
    }

    workspace = 1, monitor:HDMI-A-2, default:true
    workspace = 2, monitor:HDMI-A-2, default:true
    workspace = 3, monitor:HDMI-A-2, default:true
    workspace = 4, monitor:HDMI-A-2, default:true
    workspace = 5, monitor:HDMI-A-2, default:true
    workspace = 9, monitor:HDMI-A-2, default:true
    
    debug {
        disable_logs = false
        enable_stdout_logs = true
    }
    
    # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
    input {
        kb_layout = us,dk
        kb_variant = 
        kb_model =
        kb_options = grp:alt_space_toggle 
        kb_rules =

        follow_mouse = 1

        touchpad {
            natural_scroll = no
        }
        # epic-mouse-v1 {
        #     sensitivity = -0.5
        # }
        sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
    }

    general {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more

        gaps_in = 3 
        gaps_out = 4
        border_size = 2
        col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
        col.inactive_border = rgba(595959aa)

        layout = dwindle
        allow_tearing = false
    }

    decoration {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more

        rounding = 10

        blur {
            enabled = true
            size = 3
            passes = 1
        }

        # drop_shadow {
        #     enabled = yes
        #     range = 4
        #     render_power = 3
        #     color = rgba(1a1a1aee)
        # }
    }

    animations {
        enabled = yes

        # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

        bezier = myBezier, 0.05, 0.9, 0.1, 1.05

        animation = windows, 1, 7, myBezier
        animation = windowsOut, 1, 7, default, popin 80%
        animation = border, 1, 10, default
        animation = borderangle, 1, 8, default
        animation = fade, 1, 7, default
        animation = workspaces, 1, 6, default
    }

    dwindle {
        # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
        pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
        preserve_split = yes # you probably want this
    }

    master {
        # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
        new_status = master
    }


    # Example per-device config
    # See https://wiki.hyprland.org/Configuring/Keywords/#executing for more
    # device ={
    #     name = epic-mouse-v1 # logitech-advanced-corded-mouse-m500s
    #     sensitivity = -0.5
    # }

    # Example windowrule v1
    # windowrule = float, ^(kitty)$
    # Example windowrule v2
    # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
    # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more


    # See https://wiki.hyprland.org/Configuring/Keywords/ for more
    $mainMod = SUPER

    # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
    bind = $mainMod, Q, exec, alacritty  
    bind = $mainMod SHIFT, K, killactive,
    bind = $mainMod, S, exec, GDK_BACKEND=x11 slack 
    bind = $mainMod, T, exec, GDK_BACKEND=x11 teams-for-linux
    bind = $mainMod, M, exit, 
    bind = $mainMod, F, exec, firefox 
    bind = $mainMod, G, exec, google-chrome-stable --enable-features=WebUIDarkMode,UseOzonePlatform --ozone-platform=wayland --force-dark-mode
    bind = $mainMod, R, exec, kitty ranger
    bind = $mainMod, P, exec, grim -g "$(slurp)" - | swappy -f -
    bind = $mainMod SHIFT, V, togglefloating, 
    bind = $mainMod, W, exec, wofi --show drun
    bind = $mainMod, O, exec, obsidian
    bind = $mainMod, L, exec, hyprlock
    bind = $mainMod, J, togglesplit, # dwindle
    bind = $mainMod, C, movetoworkspace, special
    bind = $mainMod SHIFT, C, togglespecialworkspace,
    bind = $mainMod SHIFT, S, exec, systemctl suspend


    # Move focus with mainMod + arrow keys
    bind = $mainMod, left, movefocus, l
    bind = $mainMod, right, movefocus, r
    bind = $mainMod, up, movefocus, u
    bind = $mainMod, down, movefocus, d

    # Switch workspaces with mainMod + [0-9]
    bind = $mainMod, 1, workspace, 1
    bind = $mainMod, 2, workspace, 2
    bind = $mainMod, 3, workspace, 3
    bind = $mainMod, 4, workspace, 4
    bind = $mainMod, 5, workspace, 5
    bind = $mainMod, 6, workspace, 6
    bind = $mainMod, 7, workspace, 7
    bind = $mainMod, 8, workspace, 8
    bind = $mainMod, 9, workspace, 9
    bind = $mainMod, 0, workspace, 10

    # Move active window to a workspace with mainMod + SHIFT + [0-9]
    bind = $mainMod SHIFT, 1, movetoworkspace, 1
    bind = $mainMod SHIFT, 2, movetoworkspace, 2
    bind = $mainMod SHIFT, 3, movetoworkspace, 3
    bind = $mainMod SHIFT, 4, movetoworkspace, 4
    bind = $mainMod SHIFT, 5, movetoworkspace, 5
    bind = $mainMod SHIFT, 6, movetoworkspace, 6
    bind = $mainMod SHIFT, 7, movetoworkspace, 7
    bind = $mainMod SHIFT, 8, movetoworkspace, 8
    bind = $mainMod SHIFT, 9, movetoworkspace, 9
    bind = $mainMod SHIFT, 0, movetoworkspace, 10

    # Scroll through existing workspaces with mainMod + scroll
    bind = $mainMod, mouse_down, workspace, e+1
    bind = $mainMod, mouse_up, workspace, e-1

    # Screen brightness
    bind = , XF86MonBrightnessUp, exec, brightnessctl s +5%
    bind = , XF86MonBrightnessDown, exec, brightnessctl s 5%-

    # Keyboard backlight
    # bind = , xf86KbdBrightnessUp, exec, brightnessctl -d *::kbd_backlight set +33%
    # bind = , xf86KbdBrightnessDown, exec, brightnessctl -d *::kbd_backlight set 33%-

    # Sound
    # wpctl set-default 59 to set default sink to 59
    # use wpctl to see sinks
    bind = , XF86AudioMute, exec, pamixer -t
    bind = , XF86AudioRaiseVolume, exec, pamixer -i 5
    bind = , XF86AudioLowerVolume, exec, pamixer -d 5
    bind = , XF86AudioMicMute, exec, pamixer --default-source -m

    # Move/resize windows with mainMod + LMB/RMB and dragging
    bindm = $mainMod, mouse:272, movewindow
    bindm = $mainMod, mouse:273, resizewindow
  '';
}
