{config, pkgs, lib, user, kernelPackages, nvidiaPackage, ...}:
{
  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.configType = "lua";
  wayland.windowManager.hyprland.extraConfig =
  ''
    -- wlr-randr to find monitors
    -- hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 }) -- Fallback
    -- hl.monitor({ output = "HDMI-A-2", mode = "5120x2160@30", position = "0x0", scale = 1 })
    hl.monitor({ output = "DP-3", mode = "5120x2160@59.98", position = "0x0", scale = 1 })

    local chrome = "google-chrome-stable --enable-features=WebUIDarkMode,UseOzonePlatform --ozone-platform=wayland --force-dark-mode"

    -- waybar is started by its systemd user unit (see waybar.nix)
    hl.on("hyprland.start", function()
        hl.exec_cmd(chrome)
        hl.exec_cmd("~/.nixfiles/scripts/changewallpaper.sh")
        hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
        hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP DBUS_SESSION_BUS_ADDRESS")
        hl.exec_cmd("~/.config/hypr/scripts/move-sharing-popup.sh")
        hl.exec_cmd("~/.nixfiles/scripts/screensharing.sh")
    end)

    hl.env("LIBVA_DRIVER_NAME", "nvidia")
    hl.env("XDG_SESSION_TYPE", "wayland")
    hl.env("GBM_BACKEND", "nvidia-drm")
    hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
    hl.env("WLR_DRM_NO_ATOMIC", "1")
    hl.env("CUDA_CACHE_DISABLE", "1")

    hl.config({
        cursor = {
            no_hardware_cursors = true,
        },

        misc = {
            vrr = 0,
            disable_autoreload = true,
            disable_hyprland_logo = true,
            mouse_move_enables_dpms = true,
            key_press_enables_dpms = true,
        },

        debug = {
            disable_logs = false,
            enable_stdout_logs = true,
        },

        input = {
            kb_layout = "dk,us",
            kb_variant = "nodeadkeys",
            kb_model = "",
            kb_options = "grp:alt_space_toggle",
            kb_rules = "",

            follow_mouse = 1,

            sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.
        },

        general = {
            gaps_in = 3,
            gaps_out = 4,
            border_size = 2,
            col = {
                active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
                inactive_border = "rgba(595959aa)",
            },

            layout = "dwindle",
            allow_tearing = false,
        },

        decoration = {
            rounding = 10,

            blur = {
                enabled = true,
                size = 3,
                passes = 1,
            },
        },

        animations = {
            enabled = true,
        },

        dwindle = {
            preserve_split = true,
        },

        master = {
            new_status = "master",
        },
    })

    hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

    hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "myBezier" })
    hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
    hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
    hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
    hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
    hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })

    local mainMod = "SUPER"

    hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd("ghostty"))
    hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.close())
    hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("GDK_BACKEND=x11 slack"))
    hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("GDK_BACKEND=x11 teams-for-linux"))
    hl.bind(mainMod .. " + M", hl.dsp.exit())
    hl.bind(mainMod .. " + F", hl.dsp.exec_cmd("firefox"))
    hl.bind(mainMod .. " + G", hl.dsp.exec_cmd(chrome))
    hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("kitty ranger"))
    hl.bind(mainMod .. " + P", hl.dsp.exec_cmd('grim -g "$(slurp)" - | swappy -f -'))
    hl.bind(mainMod .. " + SHIFT + V", hl.dsp.window.float({ action = "toggle" }))
    hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("wofi --show drun"))
    hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("obsidian"))
    hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
    hl.bind(mainMod .. " + SHIFT + H", hl.dsp.exec_cmd("systemctl suspend"))
    hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle
    hl.bind(mainMod .. " + C", hl.dsp.window.move({ workspace = "special" }))
    hl.bind(mainMod .. " + SHIFT + C", hl.dsp.workspace.toggle_special())
    hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("systemctl suspend"))

    -- Move focus with mainMod + arrow keys
    hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
    hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
    hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
    hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

    -- Switch workspaces with mainMod + [0-9]; move the window there with SHIFT
    for i = 1, 10 do
        local key = i % 10 -- 10 maps to key 0
        hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
        hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
    end

    -- Scroll through existing workspaces with mainMod + scroll
    hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
    hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

    -- Sound: wpctl lists sinks; `wpctl set-default 59` picks sink 59

    -- Move/resize windows with mainMod + LMB/RMB and dragging
    hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
    hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
  '';
}
