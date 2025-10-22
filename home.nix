{config, pkgs, lib, user, home-manager, inputs, ... }:
let
  myGo = pkgs.go;
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
  nix-alien-pkgs = import (
    builtins.fetchTarball "https://github.com/thiagokokada/nix-alien/tarball/master"
  ) { };
  hypridleConf = pkgs.writeText "hypridle.conf" ''
    general {
        lock_cmd = pidof hyprlock || hyprlock       # avoid starting multiple hyprlock instances.
        before_sleep_cmd = loginctl lock-session && systemctl start nvidia-suspend   # lock before suspend.
        after_sleep_cmd = systemctl start nvidia-resume && hyprctl dispatch dpms on  # to avoid having to press a key twice to turn on the display.
    }

    # Screenlock
    listener {
        # HYPRLOCK TIMEOUT
        timeout = 600
        # HYPRLOCK ONTIMEOUT
        on-timeout = loginctl lock-session
    }

    # dpms
    listener {
        # DPMS TIMEOUT
        timeout = 900
        # DPMS ONTIMEOUT
        on-timeout = hyprctl dispatch dpms off
        # DPMS ONRESUME
        on-resume = hyprctl dispatch dpms on
    }

    # Suspend
    listener {
        # SUSPEND TIMEOUT
        timeout = 1800
        #SUSPEND ONTIMEOUT
        on-timeout = systemctl suspend
    }
  '';
  hyprlockConf = pkgs.writeText "hyprlock.conf" ''
    source = ~/.cache/wal/colors-hyprland.conf

    # BACKGROUND
    background {
        monitor =
        path = ~/Pictures/wal.png
        blur_passes = 3
        contrast = 0.8916
        brightness = 0.8172
        vibrancy = 0.1696
        vibrancy_darkness = 0.0
    }

    # GENERAL
    general {
        no_fade_in = false
        grace = 0
        disable_loading_bar = true
    }

    # INPUT FIELD
    input-field {
        monitor =
        size = 250, 60
        outline_thickness = 2
        dots_size = 0.2 # Scale of input-field height, 0.2 - 0.8
        dots_spacing = 0.2 # Scale of dots' absolute size, 0.0 - 1.0
        dots_center = true
        outer_color = rgba(0, 0, 0, 0)
        inner_color = rgba(0, 0, 0, 0.5)
        font_color = rgb(200, 200, 200)
        fade_on_empty = false
        font_family = JetBrains Mono Nerd Font Mono
        placeholder_text = <i><span foreground="##cdd6f4">Input Password...</span></i>
        hide_input = false
        position = 0, -120
        halign = center
        valign = center
    }

    # TIME
    label {
        monitor =
        text = cmd[update:1000] echo "$(date +"%-I:%M%p")"
        color = $foreground
        #color = rgba(255, 255, 255, 0.6)
        font_size = 120
        font_family = JetBrains Mono Nerd Font Mono ExtraBold
        position = 0, -300
        halign = center
        valign = top
    }

    # USER
    label {
        monitor =
        text = Hi there, $USER
        color = $foreground
        #color = rgba(255, 255, 255, 0.6)
        font_size = 25
        font_family = JetBrains Mono Nerd Font Mono
        position = 0, -40
        halign = center
        valign = center
    }

    # CURRENT SONG
    label {
        monitor =
        text = cmd[update:1000] echo "$(~/Documents/Scripts/whatsong.sh)" 
        color = $foreground
        #color = rgba(255, 255, 255, 0.6)
        font_size = 18
        font_family = JetBrainsMono, Font Awesome 6 Free Solid
        position = 0, -50
        halign = center
        valign = bottom
    }
  '';
in
{
  # imports = [
  #   (import ./hyprland.nix { inherit config pkgs lib user kernelPackages nvidiaPackage; })
  #   (import ./waybar.nix { inherit config pkgs lib user; })
  # ];
  imports = [
  	./hyprland.nix
  	./waybar.nix
	];

 # Home Manager needs a bit of information about you and the
  # paths it should manage.
  programs.home-manager.enable = true;
  home.username = "${user}";
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "25.05";
  home.packages = with pkgs; [ 
    htop 
    starship
    # teams-for-linux
    cups-brother-hll3230cdw
    vlc
    # go_1_23
    myGo
    gopls
    viewnior
    swaybg
    grim
    swappy
    slurp
    swayidle
    fzf
    libnotify
    libcanberra-gtk3
    (pkgs.writeShellScriptBin "set_monitor.sh" ''
      # export XDG_RUNTIME_DIR=/run/user/$(id -u)
      wlr-randr --output DP-2 --custom-mode 5120x2160@60Hz --pos -2560,0
    '')
  ] ++ (with nix-alien-pkgs; [
    nix-alien
  ]);
  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 32;
  };
  #Session variables
  home.sessionVariables = {
    BROWSER = "google-chrome";
    GOROOT = lib.mkForce "${myGo}/share/go";
    GOPATH = lib.mkForce "$HOME/go";
    PATH = lib.mkForce "$PATH:${myGo}/bin:$HOME/go/bin";
    # GOPATH = lib.mkForce "$HOME/go";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    # XCURSOR_THEME = "Breeze_Snow"; # Change this to your preferred cursor theme
    # XCURSOR_SIZE = "32"; 
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_QPA_PLATFORM = "wayland";
    # QT_QPA_PLATFORMTHEME = "gtk3";
    QT_SCALE_FACTOR = "2.6";
    # MOZ_ENABLE_WAYLAND = "0";
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    # QT_QPA_PLATFORM = "wayland-egl";
    # QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    ELM_SCALE = "2.6";
    # WLR_NO_HARDWARE_CURSORS = "1";
    WLR_DRM_DEVICES = "/dev/dri/card1:/dev/dri/card0";
    GBM_BACKEND = "nvidia-drm";
    CLUTTER_BACKEND = "wayland";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    # LIBVA_DRIVER_NAME = "nvidia";
    # WLR_RENDERER = "vulkan";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    GTK_USE_PORTAL = "1";
    XDG_CACHE_HOME = "\${HOME}/.cache";
    XDG_CONFIG_HOME = "\${HOME}/.config";
    #XDG_BIN_HOME = "\${HOME}/.local/bin";
    XDG_DATA_HOME = "\${HOME}/.local/share";
    GDK_BACKEND = "wayland";
    # HANDLER = "copilot";
    ANTHROPIC_API_KEY = "$(cat /home/sla/sla-claude-key)";
  };

  home.sessionPath = [
    "$GOPATH/bin"
  ];
  home.file = {
    ".go-env.nu".text = ''
      $env.GOPATH = $"($env.HOME)/go"
      $env.PATH = ($env.PATH | split row (char esep) | append $"($env.GOPATH)/bin" | uniq)
    '';
    ".config/hypr/hypridle.conf".source = hypridleConf;
    ".config/hypr/hyprlock.conf".source = hyprlockConf;
    ".config/rofi/nord-oneline.rasi".text = ''
    /*******************************************************************************
     * ROFI ONELINE THEME USING THE NORD COLOR PALETTE 
     * User                 : LR-Tech               
     * Theme Repo           : https://github.com/lr-tech/rofi-themes-collection
     * Nord Project Repo    : https://github.com/arcticicestudio/nord
     *******************************************************************************/

    * {
        font:   "Unifont 14";

        nord0:     #2e3440;
        nord1:     #3b4252;
        nord2:     #434c5e;
        nord3:     #4c566a;

        nord4:     #d8dee9;
        nord5:     #e5e9f0;
        nord6:     #eceff4;

        nord7:     #8fbcbb;
        nord8:     #88c0d0;
        nord9:     #81a1c1;
        nord10:    #5e81ac;
        nord11:    #bf616a;

        nord12:    #d08770;
        nord13:    #ebcb8b;
        nord14:    #a3be8c;
        nord15:    #b48ead;

        background-color:   transparent;
        text-color:         @nord4;
        accent-color:       @nord8;

        margin:     0px;
        padding:    0px;
        spacing:    0px;
    }

    window {
        location:           south;
        width:              100%;
        background-color:   @nord0;
        children:           [ mainbox,message ];
    }

    mainbox {
        orientation:    horizontal;
        children:       [ inputbar,listview ];
    }

    inputbar {
        width:      15%;
        padding:    1px 8px;
        spacing:    8px;
        children:   [ icon-search, entry ];
    }

    icon-search {
        expand:     false;
        filename:   "search";
        size: 16px;
    }

    prompt, element-icon ,entry, element-text,{
        vertical-align: 0.5;
    }

    prompt {
        text-color: @accent-color;
    }

    listview {
        layout: horizontal;
    }

    element {
        padding:    1px 8px;
        spacing:    4px;
    }

    element normal urgent {
        text-color: @nord13;
    }

    element normal active {
        text-color: @accent-color;
    }

    element selected {
        text-color: @nord0;
    }

    element selected normal {
        background-color:   @accent-color;
    }

    element selected urgent {
        background-color:   @nord13;
    }

    element selected active {
        background-color:   @nord8;
    }

    element-icon {
        size:   0.75em;
    }

    element-text {
        text-color: inherit;
    }
    '';
    ".config/kitty/kitty.conf".text = ''
      font_size 15.0
      font_family      Source Code Pro
      bold_font        Source Code Proi Bold
      italic_font      Source Code Pro Italic
      bold_italic_font Source Code Pro Bold Italic
      background_opacity 0.6

      # window settings
      initial_window_width 95c
      initial_window_height 35c
      window_padding_width 20
      confirm_os_window_close 0

      # Upstream colors {{{

      # Special
      background #14151e 
      foreground #98b0d3 

      # Black
      color0 #151720
      color8 #4f5572 

      # Red
      color1 #dd6777
      color9 #e26c7c

      # Green
      color2  #90ceaa
      color10 #95d3af

      # Yellow
      color3  #ecd3a0
      color11 #f1d8a5

      # Blue
      color4  #86aaec
      color12 #8baff1

      # Magenta
      color5  #c296eb
      color13 #c79bf0

      # Cyan
      color6  #93cee9
      color14 #98d3ee

      # White
      color7  #cbced3
      color15 #d0d3d8

      # Cursor
      cursor #cbced3
      cursor_text_color #a5b6cf

      # Selection highlight
      selection_foreground #a5b6cf
      selection_background #1c1e27


      # The color for highlighting URLs on mouse-over
      # url_color #9ece6a
      url color #5de4c7

      # Window borders
      active_border_color #3d59a1
      inactive_border_color #101014
      bell_border_color #fffac2

      # Tab bar
      tab_bar_style fade
      tab_fade 1
      active_tab_foreground   #3d59a1
      active_tab_background   #16161e
      active_tab_font_style   bold
      inactive_tab_foreground #787c99
      inactive_tab_background #16161e
      inactive_tab_font_style bold
      tab_bar_background #101014

      # Title bar
      # macos_titlebar_color #16161e
    '';
    ".config/light/targets/sysfs/backlight/auto/minimum".text = ''
    10
    '';
    ".config/helix/languages.toml".text = ''
      # Core language configurations
      [[language]]
      name = "rust"
      language-id = "rust"
      scope = "source.rust"
      injection-regex = "rust"
      file-types = ["rs"]
      roots = ["Cargo.toml", "Cargo.lock"]
      auto-format = true
      indent = { tab-width = 4, unit = "    " }
      diagnostic-severity = "info"
      language-servers = ["rust"]

      
      [[language]]
      name = "python"
      scope = "source.python"
      injection-regex = "python"
      file-types = ["py", "pyi", "py3", "pyw"]
      roots = ["pyproject.toml", "setup.py", "requirements.txt"]
      language-servers = ["pyright", "ruff"]
      indent = { tab-width = 4, unit = "    " }
      auto-format = true
      formatter = { command = "black", args = ["--quiet", "-"] }

      [[language]]
      name = "javascript"
      formatter = { command = 'prettier', args = ["--parser", "typescript"] }
      auto-format = true
      language-servers = ["typescript-language-server", "tailwindcss", "emmet-ls", "scls"]

      [[language]]
      name = "typescript"
      language-servers = ["typescript-language-server", "tailwindcss", "emmet-ls", "scls"]
      formatter = { command = 'npx', args = ["prettier", "--parser", "typescript"] }
      indent = { tab-width = 4, unit = "\t" }
      auto-format = true

      [[language]]
      name = "html"
      file-types = ["html", "htm", "astro"]
      formatter = { command = 'prettier', args = ["--parser", "html"] }
      language-servers = ["html"]

      [[language]]
      name = "css"
      formatter = { command = 'prettier', args = ["--parser", "css"] }
      language-servers = ["css"]

      [[language]]
      name = "json"
      formatter = { command = 'prettier', args = ["--parser", "json"] }

      [[language]]
      name = "markdown"
      file-types = ["md"]
      formatter = { command = 'prettier', args = ["--parser", "markdown"] }
      auto-format = true
      language-servers = ["md"]

      [[language]]
      name = "go"
      file-types = ["go"]
      language-servers = ["go", "lsp-ai"]

      [[language]]
      name = "dockerfile"
      file-types = ["Dockerfile", "Containerfile"]
      comment-token = "#"
      indent = { tab-width = 4, unit = "    " }
      language-servers = ["docker-langserver"]

      [[language]]
      name = "tailwindcss"
      scope = "source.css"
      injection-regex = "(postcss|css|html)"
      file-types = ["css", "html", "astro"]
      roots = ["tailwind.config.js", "tailwind.config.cjs"]
      indent = { tab-width = 2, unit = "  " }
      language-servers = ["tailwindcss"]

      [[language]]
      name = "haskell"
      file-types = ["hs"]
      language-servers = ["hls"]

      [[language]]
      name = "julia"
      scope = "source.julia"
      injection-regex = "julia"
      file-types = ["jl"]
      roots = ["Project.toml", "Manifest.toml", "JuliaProject.toml"]
      indent = { tab-width = 4, unit = "    " }
      language-servers = ["julia"]

      [[language]]
      name = "astro"
      scope = "source.astro"
      injection-regex = "astro"
      file-types = ["astro"]
      language-servers = ["astro-ls"]
      formatter = { command = "prettier", args = ["--plugin", "prettier-plugin-astro", "--parser", "astro"] }
      auto-format = true

      [[language]]
      name = "ocaml"
      formatter = { command = "ocamlformat", args = ["-", "--impl"] }
      language-servers = ["ocaml"]

      # Elixir Language Configuration
      [[language]]
      name = "elixir"
      scope = "source.elixir"
      injection-regex = "elixir"
      file-types = ["ex", "exs"]
      shebangs = ["elixir"]
      roots = ["mix.exs"]
      comment-token = "#"
      language-servers = ["elixir-ls"]
      indent = { tab-width = 2, unit = "  " }
      auto-format = true

      # HEEx (HTML+EEx) Templates
      [[language]]
      name = "heex"
      scope = "source.heex"
      injection-regex = "heex"
      file-types = ["heex"]
      roots = ["mix.exs"]
      comment-token = "<!--"
      language-servers = ["elixir-ls"]
      indent = { tab-width = 2, unit = "  " }
      auto-format = true

      # Surface Templates (Phoenix LiveView component library)
      [[language]]
      name = "surface"
      scope = "source.surface"
      injection-regex = "surface"
      file-types = ["sface"]
      roots = ["mix.exs"]
      comment-token = "<!--"
      language-servers = ["elixir-ls"]
      indent = { tab-width = 2, unit = "  " }
      auto-format = true

      # EEx Templates (Embedded Elixir)
      [[language]]
      name = "eex"
      scope = "text.html.elixir"
      injection-regex = "eex"
      file-types = ["eex", "leex"]
      roots = ["mix.exs"]
      comment-token = "<!--"
      language-servers = ["elixir-ls"]
      indent = { tab-width = 2, unit = "  " }
      auto-format = true

      # Livebook (Elixir notebooks)
      [[language]]
      name = "livebook"
      scope = "source.livebook"
      injection-regex = "livebook"
      file-types = ["livemd"]
      roots = ["mix.exs"]
      comment-token = "<!--"
      language-servers = ["elixir-ls"]
      indent = { tab-width = 2, unit = "  " }

      [[language]]
      name = "clojure"
      scope = "source.clojure"
      injection-regex = "(clojure|clj|edn)"
      file-types = ["clj", "cljs", "cljc", "edn"]
      roots = ["project.clj", "deps.edn", "build.boot", "shadow-cljs.edn", "bb.edn"]
      comment-token = ";"
      language-servers = ["clojure-lsp"]
      indent = { tab-width = 2, unit = "  " }
      auto-format = true

      # ClojureScript support
      [[language]]
      name = "clojurescript"
      scope = "source.clojurescript"
      injection-regex = "(clojurescript|cljs)"
      file-types = ["cljs"]
      roots = ["project.clj", "deps.edn", "build.boot", "shadow-cljs.edn", "bb.edn"]
      comment-token = ";"
      language-servers = ["clojure-lsp"]
      indent = { tab-width = 2, unit = "  " }
      auto-format = true

      # EDN support
      [[language]]
      name = "edn"
      scope = "source.clojure"
      injection-regex = "edn"
      file-types = ["edn"]
      comment-token = ";"
      language-servers = ["clojure-lsp"]
      indent = { tab-width = 2, unit = "  " }
      auto-format = true
      grammar = "clojure"

      [[language]]
      name = "roc"
      scope = "source.roc"
      injection-regex = "roc"
      file-types = ["roc"]
      shebangs = ["roc"]
      roots = []
      comment-token = "#"
      language-servers = ["roc-ls"]
      indent = { tab-width = 2, unit = "  " }
      auto-format = true
      formatter = { command = "roc", args =[ "format", "--stdin", "--stdout"]}

      [language.auto-pairs]
      '(' = ')'
      '{' = '}'
      '[' = ']'
      '"' = '"'

      # Language server configurations

      [[grammar]]
      name = "roc"
      source = { git = "https://github.com/faldor20/tree-sitter-roc.git", rev = "40e52f343f1b1f270d6ecb2ca898ca9b8cba6936" }

      [language-server.roc-ls]
      command = "roc_language_server"

      [language-server.rust]
      command = "rust-analyzer"

      [language-server.rust.config]
      check.command = "clippy" 
      cargo.features = "all" 
      completion.addCallParenthesis = true 

      [language-server.clojure-lsp]
      command = "clojure-lsp"

      [language-server.pyright]
      command = "pyright-langserver"
      args = ["--stdio"]

      [language-server.pyright.config.analysis]
      typecheckingmode = "basic"
      autoimportcompletions = true

      [language-server.pyright.config.analysis.inlayhints]
      functionreturntypes = true
      variabletypes = true

      [language-server.ruff]
      command = "ruff"
      args = ["server"]

      [language-server.typescript-language-server]
      command = "typescript-language-server"
      args = ["--stdio"]

      [language-server.typescript-language-server.config]
      documentFormatting = false
      hostInfo = "helix"

      [language-server.typescript-language-server.config.typescript.inlayHints]
      includeInlayEnumMemberValueHints = true
      includeInlayFunctionLikeReturnTypeHints = true
      includeInlayFunctionParameterTypeHints = true
      includeInlayParameterNameHints = "all"
      includeInlayParameterNameHintsWhenArgumentMatchesName = true
      includeInlayPropertyDeclarationTypeHints = true
      includeInlayVariableTypeHints = true

      [language-server.typescript-language-server.config.javascript.inlayHints]
      includeInlayEnumMemberValueHints = true
      includeInlayFunctionLikeReturnTypeHints = true
      includeInlayFunctionParameterTypeHints = true
      includeInlayParameterNameHints = "all"
      includeInlayParameterNameHintsWhenArgumentMatchesName = true
      includeInlayPropertyDeclarationTypeHints = true
      includeInlayVariableTypeHints = true

      [language-server.typescript-language-server.config.completions]
      completeFunctionCalls = true

      [language-server.html]
      command = "vscode-html-language-server"
      args = ["--stdio"]

      [language-server.css]
      command = "css-languageserver"
      args = ["--stdio"]

      [language-server.md]
      command = "marksman"

      [language-server.go]
      command = "gopls"

      [language-server.docker-langserver]
      command = "docker-langserver"
      args = ["--stdio"]

      [language-server.tailwindcss]
      command = "tailwindcss-language-server"
      args = ["--stdio"]

      [language-server.astro-ls]
      command = "astro-ls"
      args = ["--stdio"]
      config = { typescript = { tsdk = "/home/sla/.npm/lib/node_modules/typescript/lib" }}

      [language-server.eslint]
      command = "vscode-eslint-language-server"
      args = ["--stdio"]

      # Improve ESLint config to handle missing config files better
      [language-server.eslint.config]
      format = true
      nodePath = ""
      onIgnoredFiles = "off"
      packageManager = "npm"
      quiet = false
      run = "onType"
      useESLintClass = false
      validate = "on"
      workingDirectory = { mode = "auto" }
      probe = "false"  # Add this to avoid errors in projects without ESLint config

      [language-server.emmet-ls]
      command = "emmet-language-server"
      args = ["--stdio"]

      [language-server.hls]
      command = "hls"

      [language-server.julia]
      command = "julia"
      args = [
          "--startup-file=no",
          "--history-file=no",
          "--quiet",
          "--project",
          "-e",
          "using LanguageServer; runserver()"
      ]

      [language-server.ocaml]
      command = "ocamllsp"

      [language-server.scls]
      command = "simple-completion-language-server"

      [language-server.scls.config]
      max_completion_items = 20
      snippets_first = true
      feature_words = true
      feature_snippets = true
      feature_unicode_input = false

      [language-server.elixir-ls]
      command = "elixir-ls"
      config = { elixirLS = { dialyzerEnabled = true, fetchDeps = false, suggestSpecs = true } }
  '';
  };
  xdg = {
    configFile = {
      "gtk-3.0/settings.ini".text = ''
        [Settings]
        gtk-cursor-theme-name = Adwaita
        gtk-cursor-theme-size = 48
      '';

      "gtk-4.0/settings.ini".text = ''
        [Settings]
        gtk-cursor-theme-name = Adwaita
        gtk-cursor-theme-size = 48
      '';
    };
  };
  gtk = {
    enable = true;
    theme = {
      name = "Dracula";
      package = pkgs.dracula-theme;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    font = {
      name = "FiraCode Nerd Font Mono Medium";
    };
  };
  programs = {
    gitui.enable = true;
    go = {
      enable = true;
      package = myGo;
      goPath = "go";
    };
    alacritty = {
      enable = true;
      settings = {
        window = {
          opacity = 0.7;
        };
        mouse = {
          bindings = [
            { mouse = "Middle"; action = "Paste"; }
            { mouse = "Left"; action = "Copy"; }
          ];
        };
        scrolling = {
          history = 5000;
          multiplier = 3;
        };
        font = {
          normal = {
            family = "FiraCode Nerd Font";
            style = "Regular";
          };
          bold = {
            family = "FiraCode Nerd Font";
            style = "Bold";
          };
          italic = {
            family = "FiraCode Nerd Font";
            style = "Italic";
          };
          size = 15.0;
          offset = {
            x = 1;
            y = 1;
          };
        };
        colors = {
          primary = {
            background = "#14151e"; 
            foreground = "#98b0d3"; 
            # background = "0x002b36";
            # foreground = "0x93a1a1";
          };

          # Colors the cursor will use if `custom_cursor_colors` is true
          cursor = {
            text = "0x002b36";
            cursor = "0x93a1a1";
          };

          # Normal colors
          normal = {
            black =   "0x002b36";
            red =     "0xdc322f";
            green =   "0x859900";
            yellow =  "0xb58900";
            blue =    "0x268bd2";
            magenta = "0x6c71c4";
            cyan =    "0x2aa198";
            white =   "0x93a1a1";
          };

          # Bright colors
          bright = {
            black =   "0x657b83";
            red =     "0xdc322f";
            green =   "0x859900";
            yellow =  "0xb58900";
            blue =    "0x268bd2";
            magenta = "0x6c71c4";
            cyan =    "0x2aa198";
            white =   "0xfdf6e3";
          };

          indexed_colors = [
            { index = 16; color = "0xcb4b16"; }
            { index = 17; color = "0xd33682"; }
            { index = 18; color = "0x073642"; }
            { index = 19; color = "0x586e75"; }
            { index = 20; color = "0x839496"; }
            { index = 21; color = "0xeee8d5"; }
          ];
        };
      };
    };
    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
      options = ["--cmd cd"];
    };
    zellij = {
      enable = true;
      settings = {
        theme = "dracula";
        themes.dracula = {
            fg = "#F8F8F2";
            bg = "#282A36";
            black = "#000000";
            red = "#FF5555";
            green = "#50FA7B";
            yellow = "#F1FA8C";
            blue = "#6272A4";
            magenta = "#FF79C6";
            cyan = "#8BE9FD";
            white = "#FFFFFF";
            orange = "#FFB86C";
        };
      };
    };
    nushell = {
      enable = true;
      # configFile.source = ./.../config.nu;
      # for editing directly to config.nu 
      configFile.text = ''
        def start_zellij [] {
          if 'ZELLIJ' not-in ($env | columns) {
            if 'ZELLIJ_AUTO_ATTACH' in ($env | columns) and $env.ZELLIJ_AUTO_ATTACH == 'true' {
              zellij attach -c
            } else {
              zellij
            }

            if 'ZELLIJ_AUTO_EXIT' in ($env | columns) and $env.ZELLIJ_AUTO_EXIT == 'true' {
              exit
            }
          }
        }
        start_zellij
        # Load Go environment
        source ~/.go-env.nu
        '';
      extraConfig = ''
        let carapace_completer = {|spans|
          carapace $spans.0 nushell ...$spans | from json
        }
        def --env cbp [] { wl-paste | lines | parse "export {name}=\"{value}\"" | transpose --ignore-titles -r -d | load-env }
        $env.config = {
          show_banner: false,
          completions: {
            case_sensitive: false # case-sensitive completions
            quick: true    # set to false to prevent auto-selecting completions
            partial: true    # set to false to prevent partial filling of the prompt
            algorithm: "fuzzy"    # prefix or fuzzy
            external: {
            # set to false to prevent nushell looking into $env.PATH to find more suggestions
              enable: true 
            # set to lower can improve completion performance at the cost of omitting some options
              max_results: 100 
              completer: $carapace_completer # check 'carapace_completer' 
            }
          }
        } 
        $env.PATH = ($env.PATH | 
          split row (char esep) |
          prepend /home/${user}/.apps |
          prepend /home/${user}/.npm  |
          prepend /home/${user}/.npm/bin |
          prepend /home/${user}/.npm/lib |
          prepend /home/${user}/.local/bin |
          prepend /home/${user}/.cargo/bin |
          append /usr/bin/env
        )
      '';
      shellAliases = {
        vi = "hx";
        vim = "hx";
        nano = "hx";
        ll = "ls -al";
        switchhypr = "sudo nixos-rebuild switch --impure --flake .";
        switchuhypr = "sudo nixos-rebuild switch --impure --upgrade --flake .";
        zl = "zellij list-sessions";
        za = "zellij attach";
        pj="npx projen";
        # ssmssdev = "aws ssm start-session --target i-0cad1bdfd1e0c7da7 --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters '{\"host\":[\"database-1.cluster-clcgcc8gmisl.eu-central-1.rds.amazonaws.com\"],\"portNumber\":[\"5432\"],\"localPortNumber\":[\"1033\"]}' --region eu-central-1";
      };
    };  
    fish = {
      enable = true;
      
    };

    bash = {
      enable = true;
      historyControl = [ "ignoredups" ];
      historySize = 1000000;
      historyFileSize = 1000000;

      # TODO source from file (e.g., .bashrc)
      initExtra = ''
        # If not running interactively, don't do anything
        # ... aaand what the hell this check means and why
        #     it matters.
        # http://unix.stackexchange.com/questions/257571/why-does-bashrc-check-whether-the-current-shell-is-interactive
        case $- in
            *i*) ;;
              *) return;;
        esac

        # ==============================================================
        # prompt =======================================================
        # ==============================================================

        if [ ! -f ~/git-prompt.sh ]; then
          curl -O https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
        fi
        source /home/${user}/git-prompt.sh

        # + for staged, * if unstaged.
        GIT_PS1_SHOWDIRTYSTATE=1¬
        # $ if something is stashed.
        GIT_PS1_SHOWSTASHSTATE=1¬
        # % if there are untracked files.
        GIT_PS1_SHOWUNTRACKEDFILES=1¬
        # <,>,<> behind, ahead, or diverged from upstream.
        GIT_PS1_SHOWUPSTREAM=1
        # "She's saying ... a bunch of stuff. Look, have you tried drugs?"
        PS1='\[\e[33m\]$(__git_ps1 "%s") \[\e[m\]\[\e[32m\]\u@\h \[\e[m\] \[\e[01;30m\][\w]\[\033[0m\]\n\j \[\e[01;30m\][\t]\[\033[0m\] '
        # ==============================================================
        # history ======================================================
        # ==============================================================
        HISTCONTROL=ignoredups # no duplicate lines in history
        HISTSIZE=200000
        HISTFILESIZE=200000
        HISTTIMEFORMAT='%Y/%m/%d-%H:%M	'
        # ==============================================================
        # miscellaneous ================================================
        # ==============================================================
        # Make sure that tmux uses the right variable in order to
        # display vim colors correctly.
        TERM="screen-256color"
        EDITOR=$(which hx)
        MANWIDTH=80
        ERL_AFLAGS="-kernel shell_history enabled"
      '';
    };
    #rofi
    rofi = {
      package = pkgs.rofi;
      enable = true;
      plugins = [pkgs.rofi-emoji];
      configPath = ".config/rofi/config.rasi";
      theme = "nord-oneline.rasi"; 
    };

    carapace.enable = true;
    carapace.enableNushellIntegration = true;

    starship = { 
      enable = true;
      enableNushellIntegration = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      settings = {
        # Increase timeout for commands
        command_timeout = 1000;
    
        # Basic prompt format
        format = builtins.concatStringsSep "" [
          "$username"
          "$hostname"
          "$directory"
          "$git_branch"
          "$git_status"
          "$cmd_duration"
          "$line_break"
          "$character"
        ];
    
        add_newline = true;
    
        # Show directory even outside git repos
        directory = {
          truncation_length = 3;
          truncate_to_repo = false;
          style = "blue bold";
          read_only = " 🔒";
        };
    
        # Show system info
        hostname = {
          ssh_only = false;
          format = "[$hostname](bold red) ";
          disabled = false;
        };
    
        # Show username
        username = {
          style_user = "white bold";
          style_root = "red bold";
          format = "[$user]($style) ";
          disabled = false;
        };
    
        # Show OS symbol
        os = {
          format = "[$symbol](bold white) ";
          disabled = false;
        };
    
        # Git settings
        git_branch = {
          format = "[$branch]($style) ";
          style = "bright-black";
        };
        git_status = {
          format = "([$all_status$ahead_behind]($style) )";
          style = "red";
          disabled = false;
        };
    
        # Command duration
        cmd_duration = {
          min_time = 500;
          format = "took [$duration](yellow) ";
        };
    
        # Prompt character
        character = { 
          success_symbol = "[➜](bold green) ";
          error_symbol = "[➜](bold red) ";
        };
    
        # Disable modules that might cause slowdown
        golang = {
          disabled = true;
        };
      };
    };
    helix = {
      enable = true;
      defaultEditor = true;
      settings = {
        theme = "catppuccin_mocha";
        editor = {
          line-number = "relative";
          mouse = true;
          auto-completion = true;
          cursorline = true;
          color-modes = true;
          auto-info = true;
          bufferline = "multiple";
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
          lsp ={
            display-messages = true;
          };
          indent-guides = {
            render = true;
          };
          file-picker = {
            hidden = false;
          };
          soft-wrap = {
            enable = true;
            max-wrap = 25; # increase value to reduce forced mid-word wrapping
            max-indent-retain = 0;
            wrap-indicator = "";  # set wrap-indicator to "" to hide it
          };
          statusline = {
            left = ["mode" "spinner" "file-name" "version-control"];
            center = [];
            right = ["diagnostics" "selections" "position" "file-encoding" "file-line-ending" "file-type"];
          };
        };
        keys.normal = {
          C-s = ":w"; # Maps the Control-s to the typable command :w which is an alias for :write (save file)
          esc = ["collapse_selection" "keep_primary_selection"];
          H = ":toggle lsp.display-inlay-hints";
          C-j = ["goto_next_paragraph"];
          C-k = ["goto_prev_paragraph"];
          C-f = [":new" ":insert-output lf-pick" "split_selection_on_newline" "goto_file" "goto_last_modification" "goto_last_modified_file" ":buffer-close!" ":theme nord" ":theme default"];
          C-h = [":new" ":insert-output gitui" ":buffer-close!" ":redraw"];
        };
        keys.select = {
          C-j = ["goto_next_paragraph"];
          C-k = ["goto_prev_paragraph"];
        };
      };
    };
  };
}
