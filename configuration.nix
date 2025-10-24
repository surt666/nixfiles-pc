# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, lib, modulesPath, ... }:

  # Enable Intel iGPU early in the boot process
  # boot.initrd.kernelModules = [ "i915" ];
let  # Define cross-compilation targets
  aarch64-linux-musl = pkgs.pkgsCross.aarch64-multiplatform-musl;
  aarch64-linux = pkgs.pkgsCross.aarch64-multiplatform;
  
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # ./suspend-and-hibernate.nix 
      # <home-manager/nixos>
    ];

  # nixpkgs.overlays = [
  #   (self: super: {
  #     obsidian-wayland = super.obsidian.override { electron = self.electron_38; };
  #   })
  # ];

  # nixpkgs.config = {
  #   allowBroken = true;
  #   permittedInsecurePackages = [
  #     "electron-29.4.6"
  #   ];
  # };
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages;  #_latest; #pkgs.linuxPackages_6_10;pkgs.linuxPackages;   
  boot.kernelParams = ["nvidia-drm.modeset=1" "nvidia-drm.fbdev=1" "usbcore.autosuspend=-1" ];
  #Boot entries limit
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.kernelModules = [ "nvidia"];
  # boot.kernelModules = [ "nvidia" "nvidia_uvm" ];
  boot.extraModprobeConfig = ''
    options nvidia NVreg_PreserveVideoMemoryAllocations=1
  '';
 
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.hostName = "nixos"; # Define your hostname.
  # Enable networking
  networking.networkmanager.enable = true;

  networking.extraHosts = ''
    127.0.0.1 me2-staging.cdebroewy8nl.eu-central-1.rds.amazonaws.com apps-db01-staging.cdebroewy8nl.eu-central-1.rds.amazonaws.com kong-db-staging.cdebroewy8nl.eu-central-1.rds.amazonaws.com
    # 18.196.43.109 cvpn-endpoint-055b8f04189000449.prod.clientvpn.eu-central-1.amazonaws.com
  '';

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # Select internationalisation properties.
  i18n.extraLocales = [ "en_US.UTF-8/UTF-8" "da_DK.UTF-8/UTF-8" ];

  i18n.defaultLocale = "en_US.UTF-8"; # "da_DK.UTF-8";

  swapDevices = [
    { device = "/swapfile"; size = 34816; }
  ];

  services.acpid.enable = true;
  hardware.acpilight.enable = true;
  # Configure keymap in X11
  services = {
    libinput.enable = true;
    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;  # For Hyprland
    # autoLogin.enable = true;
    # autoLogin.user = "sla";
      };
    };

  # X server configuration for i3
    xserver = {
      enable = true;
      xkb.layout = "dk";
      # xkbVariant = "dvorak";
      # xkbOptions = "grp:alt_shift_toggle";
      videoDrivers = [ "nvidia" ];
      windowManager.i3 = {
        enable = true;
        package = pkgs.i3;
        extraPackages = with pkgs; [
          dmenu
          i3status
          i3lock
          i3blocks
        ];
      };
    };
  };

  # Configure console keymap
  # console.keyMap = "dvorak";
  console.keyMap = "dk-latin1";
  # console.useXkbConfig = true;

  services.gnome.gnome-keyring.enable = true;
  services.printing.enable = true;
  services.flatpak.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;
  services.avahi.openFirewall = true;
  # sound.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    wireplumber.enable = true;
    pulse.enable = true;
    jack.enable = true;
  }; 

  # Better scheduling for CPU cycles - thanks System76!!!
  services.system76-scheduler.settings.cfsProfiles.enable = true;

  # Enable TLP (better than gnomes internal power manager)
  services.tlp = {
    enable = true;
    settings = {
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    };
  };
  
  # Do nothing if AC on
  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";

  # Disable GNOMEs power management
  services.power-profiles-daemon.enable = false;

  # Enable powertop
  powerManagement.powertop.enable = true;

  # Enable thermald (only necessary if on Intel CPUs)
  services.thermald.enable = true;

  #upower
  services.upower.enable = true;

  xdg.portal = {
    enable = true;
    config.common.default = "*";
    # wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr
      # pkgs.xdg-desktop-portal-hyprland
    ];
  };

  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
  # systemd.services = {
  #   nvidia-suspend.serviceConfig = lib.mkForce {
  #     Type = "oneshot";
  #     ExecStart = "${config.hardware.nvidia.package}/bin/nvidia-sleep.sh suspend";
  #   };

  #   nvidia-resume.serviceConfig = lib.mkForce {
  #     Type = "oneshot";
  #     ExecStart = "${config.hardware.nvidia.package}/bin/nvidia-sleep.sh resume";
  #   };

  #   nvidia-hibernate.serviceConfig = lib.mkForce {
  #     Type = "oneshot";
  #     ExecStart = "${config.hardware.nvidia.package}/bin/nvidia-sleep.sh hibernate";
  #   };
  # };
  users.groups.plugdev = {};

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sla = {
    isNormalUser = true;
    description = "Steen Larsen";
    extraGroups = [ "plugdev" "networkmanager" "wheel" "audio" "video" "input" "lp" "docker"];
    shell = pkgs.nushell;
  };

  # services.udev = {
  #   enable = true;
  #   extraRules = ''
  #       KERNEL=="hidraw*", ATTRS{idVendor}=="16c0", MODE="0664", GROUP="plugdev"
  #       KERNEL=="hidraw*", ATTRS{idVendor}=="3297", MODE="0664", GROUP="plugdev"
  #       SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", MODE:="0666", SYMLINK+="ignition_dfu"
  #       SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1977", MODE="0666", SYMLINK+="ignition_dfu"
  #       SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="c093", MODE="0666", SYMLINK+="ignition_dfu"
  #       ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1977", TEST=="power/control", ATTR{power/control}="on"
  #   '';
  # };
  
  # services.plex = {
  #   enable = true;
  #   openFirewall = true;  # Opens required ports in firewall
    
  #   # Optional: specify user/group
  #   user = "plex";
  #   group = "plex";
    
  #   # Optional: configure data directory
  #   dataDir = "/var/lib/plex";
  # };

  # Create persistent directory for Plex data
  systemd.tmpfiles.rules = [
    "d /var/lib/media 0755 plex plex -"
    "d /var/lib/media/movies 0755 plex plex -"
    "d /var/lib/plex 0755 plex plex -"
  ];

  security = {
    sudo.wheelNeedsPassword = false;
    rtkit.enable = true;
    pam.loginLimits = [
      {
        domain = "*";
        type = "soft";
        item = "nofile";
        value = "65535";
      }
      {
        domain = "*";
        type = "hard";
        item = "nofile";
        value = "65535";
      }
    ];
    pam.services.waylock = {
      text = ''
        auth include login
      '';
    };
  };
  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs; [
    source-code-pro
    font-awesome
    corefonts
    noto-fonts-emoji
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.iosevka
  ];

  # emojis
  services.gollum.emoji = true;
  
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    # shellInit = ''
    #   export PATH=$HOME/.npm:$HOME/.npm/bin:$PATH
    # '';
    variables = {
      TERMINAL = "alacritty";
      EDITOR = "hx";
      VISUAL = "hx";
      MOZ_ENABLE_WAYLAND = 1;
      HYPRLAND_CURSOR_SIZE = "48";
    };
    systemPackages = with pkgs; [
      vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      wget
      roc
      claude-code
      gemini-cli
      bun
      coreutils
      busybox
      biglybt
      gnugrep
      gawk
      nix-ld
      tree
      openconnect
      openvpn
      zed-editor
      gnumake
      uv
      rye
      gtk3
      qt5.qtbase
      qt5.qtwayland
      libsForQt5.qt5.qtwayland
      terraform-ls
      adwaita-qt
      maven
      google-chrome
      lxappearance
      postgresql
      fwupd
      terraform
      ssm-session-manager-plugin
      jq
      libz
      xorg.libXext
      appimage-run
      rdesktop
      git
      libsecret
      git-credential-manager
      github-runner
      gh
      unzip
      alsa-utils
      bibata-cursors
      dig
      bun
      qemu
      lldb
      firefox
      vistafonts
      corefonts
      helix
      openssl
      waylock
      hypridle
      hyprlock
      file
      # obsidian-wayland
      wofi
      rofi
      networkmanagerapplet
      kitty
      nmap
      meson
      inetutils
      wayland-protocols
      wayland-utils
      wl-clipboard
      wlroots
      dunst
      nvtopPackages.nvidia
      # cudatoolkit
      glibc
      gtk3
      ranger
      usbutils
      dotnet-sdk
      python313
      # python311Packages.pip
      # python311Packages.python-lsp-server
      # python311Packages.python-lsp-ruff
      # python311Packages.pylsp-mypy
      # (python311.withPackages (ps: with ps; [ numpy boto3 awsiotpythonsdk ]))
      pyright
      black
      ruff
      rustup
      mosquitto
      expressvpn
      julia-bin
      ghc
      ocaml
      kdePackages.sddm
      swww
      # xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
      xdg-desktop-portal
      xdg-desktop-portal-wlr
      xdg-utils
      pavucontrol
      pipewire
      lshw
      hyprcursor
      zig
      glxinfo
      brightnessctl
      pulseaudio
      pamixer
      playerctl
      cava
      xorg.xev
      evtest
      gcc13
      stdenv.cc.cc.lib
      jdk
      # kdePackages.xwaylandvideobridge
      marksman
      zoom-us
      tailwindcss
      tailwindcss-language-server
      # (rust-bin.fromRustupToolchainFile ./rust-toolchain.toml)
      aarch64-linux-musl.buildPackages.stdenv.cc
      aarch64-linux.buildPackages.stdenv.cc
      evcxr #rust repl
      taplo #toml formatter & lsp
      # cargo-deny
      # cargo-audit
      # cargo-update
      # cargo-edit
      # cargo-outdated
      # cargo-license
      # cargo-tarpaulin
      # cargo-cross
      # cargo-zigbuild
      cargo-nextest
      # cargo-spellcheck
      # cargo-modules
      cargo-bloat
      # cargo-unused-features
      cargo-lambda
      bacon
      grim
      slurp
      ghc
      cabal2nix
      cabal-install
      stack
      wlr-randr
      slack
      nodejs
      # ruff
      # ruff-lsp
      eslint_d
      emmet-language-server
      nodePackages.typescript-language-server
      # nodePackages.eslint
      nodePackages.typescript
      # vscode-langservers-extracted
      nodePackages.webpack 
      nodePackages.bash-language-server
      awscli2
      poetry
      man
      zip
    ];
  };

  # Docker
  virtualisation = {
    docker = {
      enable = true;
      # enableNvidia = true;
      extraOptions = "--experimental";
      enableOnBoot = true;
    };
    podman = {
      enable = true;
      # enableNvidia = true;
      dockerCompat = false;
    };
  };
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    dconf.enable = true; 
    nix-ld.enable = true;
    browserpass.enable = true;
    direnv.enable = true;
    traceroute.enable = true;
    ssh.askPassword = "";
    npm.enable = true;
    nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages
      libgcc
      stdenv.cc.cc
      openssl
    ];
  };
  
  environment.sessionVariables = {
    # WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "48";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true";
  };
  
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  # List services that you want to enable:

  services.locate = {
    enable = true;
  };
  services.dbus.enable = true;
  
  # USB Automounting
  services.gvfs.enable = true;
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leavecatenate(variables, "bootdev", bootdev)
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

  # Nix Configuration
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];    
    auto-optimise-store = true;
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

 # Optimize storage and automatic scheduled GC running
  # If you want to run GC manually, use commands:
  # `nix-store --optimize` for finding and eliminating redundant copies of identical store paths
  # `nix-store --gc` for optimizing the nix store and removing unreferenced and obsolete store paths
  # `nix-collect-garbage -d` for deleting old generations of user profiles
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 60d";
  };

  # Enable Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;
  services.blueman.enable = true; 
}
