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

  nixpkgs.overlays = [
    (self: super: {
      xdg-desktop-portal-gtk = super.xdg-desktop-portal-gtk.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          substituteInPlace $out/share/xdg-desktop-portal/portals/gtk.portal \
            --replace-fail "UseIn=gnome" "UseIn=gnome;Hyprland"
        '';
      });

      # Upstream nixpkgs has a stale pnpmDeps hash for 6.0.2. Drop once fixed.
      typescript-language-server = super.typescript-language-server.overrideAttrs (finalAttrs: old: {
        pnpmDeps = super.fetchPnpmDeps {
          inherit (finalAttrs) pname version src;
          pnpm = super.pnpm_12;
          fetcherVersion = 4;
          hash = "sha256-xR/EF60lVBsITKgH7wCM2wHM46PFQevD51KfCENSUH4=";
        };
      });
    })
  ];

  # nixpkgs.config = {
  #   allowBroken = true;
  #   permittedInsecurePackages = [
  #     "electron-29.4.6"
  #   ];
  # };
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.blacklistedKernelModules = [ "amdgpu" ];
  boot.kernelPackages = pkgs.linuxPackages;  #_latest; #pkgs.linuxPackages_6_10;pkgs.linuxPackages;   
  boot.kernelParams = ["nvidia-drm.modeset=1" "nvidia-drm.fbdev=1" "usbcore.autosuspend=-1" "usb-storage.delay_use=0" "mem_sleep_default=s2idle" ];

  # Drop "bpf" from the LSM stack (NixOS default is [ "landlock" "yama" "bpf" ]).
  # The bpf LSM lets systemd confine user-service cgroups such that processes
  # inside them get EACCES following the /proc/<pid>/root magic symlink (a
  # systemd 260 / kernel 6.18 regression). xdg-desktop-portal runs as a
  # systemd --user service and needs /proc/<caller>/root to identify the calling
  # app; with bpf active it couldn't, so it rejected EVERY portal request
  # ("AccessDenied: Unable to open /proc/<pid>/root") and Chrome's Google Drive /
  # file-upload picker never appeared. (capability and ima stay enabled by the
  # kernel regardless of this list.)
  # mkForce: the NixOS default ([ "landlock" "yama" "bpf" ]) is a plain list
  # definition, so a normal assignment would *concatenate* (re-adding bpf).
  security.lsm = lib.mkForce [ "landlock" "yama" ];

  # Strip CAP_SYS_NICE from the Hyprland wrapper. The hyprland module wraps the
  # binary with `capabilities = "cap_sys_nice+ep"` (plus an implicit cap_setpcap),
  # and Hyprland 0.52+ raises CAP_SYS_NICE into its *ambient* set so it leaks to
  # EVERY app the compositor spawns (Chrome included). xdg-desktop-portal runs
  # under user@.service with no caps; the capability LSM's cap_ptrace_access_check
  # then forbids it from following /proc/<caller>/root for any caller holding a
  # capability it lacks, so the portal rejected requests with
  # "AccessDenied: Unable to open /proc/<pid>/root" and Chrome's file/upload picker
  # never appeared. Proven: dropping the caller's ambient caps makes OpenFile work.
  # With no caps the wrapper is pointless, so disable it outright (Hyprland just
  # loses RT scheduling). The session runs start-hyprland, which finds Hyprland on
  # PATH. It can't stay enabled anyway: nixpkgs' ensure-wrapper-integrity check
  # rejects non-ELF sources, and the flake's bin/Hyprland is a makeWrapper script.
  security.wrappers.Hyprland.enable = false;
  # boot.kernelParams = ["nvidia-drm.modeset=1" "nvidia-drm.fbdev=1" "usbcore.autosuspend=-1" "resume=UUID=1a8f7a0b-3d89-42b6-98bb-550e8fc1d6ba" "resume_offset=21792768" "pm_freeze_timeout=30000"];
  # boot.resumeDevice = "/dev/disk/by-uuid/1a8f7a0b-3d89-42b6-98bb-550e8fc1d6ba";
  #Boot entries limit
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.kernelModules = [ "nvidia"];
  # boot.kernelModules = [ "nvidia" "nvidia_uvm" ];
  # boot.extraModprobeConfig = ''
  #   options nvidia NVreg_PreserveVideoMemoryAllocations=1
  # '';
 
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.hostName = "nixos"; # Define your hostname.
  # Enable networking
  networking.networkmanager.enable = true;

  networking.extraHosts = ''
    # 127.0.0.1 me2-staging.cdebroewy8nl.eu-central-1.rds.amazonaws.com apps-db01-staging.cdebroewy8nl.eu-central-1.rds.amazonaws.com kong-db-staging.cdebroewy8nl.eu-central-1.rds.amazonaws.com
    # 18.196.43.109 cvpn-endpoint-055b8f04189000449.prod.clientvpn.eu-central-1.amazonaws.com
    127.0.0.1 meter.ed-staging
  '';

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # Select internationalisation properties.
  i18n.extraLocales = [ "en_US.UTF-8/UTF-8" "da_DK.UTF-8/UTF-8" ];

  i18n.defaultLocale = "da_DK.UTF-8";

  # swapDevices = [
  #   { device = "/swapfile"; }
  # ];

  services.acpid.enable = true;
  hardware.acpilight.enable = true;
  # Configure keymap in X11

  services.mullvad-vpn.enable = true;

  # networking.wg-quick.interfaces = {
  #   wg-mullvad = {
  #     address = ["10.70.251.138/32" "fc00:bbbb:bbbb:bb01::7:fb89/128" ];
  #     dns = [ "100.64.0.23" ]; # mullvad public dns
  #     privateKeyFile = "/root/wireguard-keys/mullvad/wg-mullvad";
  #     peers = [
  #       {
  #         publicKey = "0qSP0VxoIhEhRK+fAHVvmfRdjPs2DmmpOCNLFP/7cGw=";
  #         allowedIPs = ["0.0.0.0/0" ]; # Only send communication through mullvad if it is in the range of the given ips, allows for split tunneling
  #         endpoint = "193.32.248.66:51820"; # my selected mullvad enpoint
  #       }
  #     ];
  #   };
  # };

  # Enable Ollama service
  # Temporarily disabled: pkgs.ollama-cuda fails to build in the current
  # nixpkgs snapshot — its CUDA (ggml-cuda) backend can't locate `nvcc`
  # ("CUDA Toolkit not found" / "Could not find nvcc executable in path
  # specified by CUDAToolkit_ROOT"), which broke the whole system build.
  # Re-enable once nixpkgs fixes the ollama-cuda CUDAToolkit_ROOT packaging,
  # or switch to `package = pkgs.ollama;` for a CPU-only build. Note that
  # "gemma4:31b" is not a real model tag (likely meant "gemma3").
  # services.ollama = {
  #   enable = true;
  #   # Use pkgs.ollama-cuda or pkgs.ollama-rocm depending on your GPU
  #   package = pkgs.ollama-cuda;
  #   loadModels = [ "gemma4:31b" ]; # Pulls the 31B desktop variant
  # };

  services = {
    libinput.enable = true;
    displayManager = {
      defaultSession = "hyprland";
      autoLogin.enable = true;
      autoLogin.user = "sla";
      sddm = {
        enable = true;
        wayland.enable = true;  # For Hyprland
      };
    };

  # X server configuration for i3
    xserver = {
      enable = true;
      xkb.layout = "eu";
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
  # console.keyMap = "dk-latin1";
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

  # This will only run AFTER the system has fully resumed
  powerManagement.resumeCommands = ''
    ${pkgs.systemd}/bin/systemctl restart display-manager.service
  '';

  # Enable thermald (only necessary if on Intel CPUs)
  services.thermald.enable = true;

  #upower
  services.upower.enable = true;

  xdg.portal = {
    enable = true;
    # config.common.default = "*";
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
    config = {
      common = {
        default = [ "hyprland" "gtk" ];
        "org.freedesktop.impl.portal.Settings" = [ "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      };
      hyprland = {
        default = [ "hyprland" "gtk" ];
        "org.freedesktop.impl.portal.Settings" = [ "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      };
    };
    # wlr.enable = true;
    # extraPortals = [
    #   pkgs.xdg-desktop-portal
    #   pkgs.xdg-desktop-portal-gtk
    #   pkgs.xdg-desktop-portal-wlr
    #   # pkgs.xdg-desktop-portal-hyprland
    # ];
  };

  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;
  # systemd.services.hibernate-wifi-fix = {
  #   description = "Unload WiFi driver before sleep";
  #   before = [ "systemd-hibernate.service" "systemd-suspend.service" ];
  #   wantedBy = [ "systemd-hibernate.service" "systemd-suspend.service" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = "${pkgs.kmod}/bin/modprobe -r mt7925e";
  #     ExecStop = "${pkgs.kmod}/bin/modprobe mt7925e";
  #     RemainAfterExit = true;
  #   };
  # };
  # systemd.services.set-resume-device = {
  #   description = "Set resume device for hibernation";
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "local-fs.target" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = "${pkgs.bash}/bin/bash -c 'echo 259:5 > /sys/power/resume'";
  #     RemainAfterExit = true;
  #   };
  # };
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
    extraGroups = [ "plugdev" "networkmanager" "wheel" "audio" "video" "input" "lp" "dialout" "docker"];
    shell = pkgs.fish;
    ignoreShellProgramCheck = true;
    # User services (the GitHub runners) start at boot, without a login.
    linger = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0wB57IuMIfGAGoyTNbem2VVn5UZEB1a4AYQ9uetPF/ sla@nixos"
    ];
  };

  # TRYX Panorama display: runtime user service and its udev rules
  systemd.packages = [ pkgs.tryx-panorama-manager ];
  systemd.user.services.tryx-panorama.wantedBy = [ "graphical-session.target" ];

  services.udev = {
    enable = true;
    # TRYX Panorama SE (legacy cm01_se) resets its USB link after libmtp's
    # probe; must sort before 69-libmtp.rules, so not in extraRules (99-local)
    packages = [
      pkgs.tryx-panorama-manager
      (pkgs.writeTextDir "lib/udev/rules.d/60-tryx-nomtp.rules" ''
        ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="2d04", ENV{MTP_NO_PROBE}="1"
      '')
    ];
    extraRules = ''
      # Voyager - WebUSB access (this is the critical part)
      SUBSYSTEM=="usb", ATTRS{idVendor}=="3297", ATTRS{idProduct}=="1977", MODE="0666", TAG+="uaccess"
    
      # Voyager - HID access
      KERNEL=="hidraw*", ATTRS{idVendor}=="3297", MODE="0666", TAG+="uaccess"
    
      # Additional Voyager rules
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", MODE="0666", TAG+="uaccess"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="3297", MODE:="0666", SYMLINK+="ignition_dfu"

    '';
  };
    
  services.plex = {
    enable = false;
    openFirewall = true;  # Opens required ports in firewall
    
    # Optional: specify user/group
    user = "plex";
    group = "plex";
    
    # Optional: configure data directory
    dataDir = "/var/lib/plex";
  };

   services.qbittorrent = {
    enable = true;
    openFirewall = true;
    webuiPort = 8080;
  };

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
    noto-fonts-color-emoji
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
      TERMINAL = "ghostty";
      EDITOR = "hx";
      VISUAL = "hx";
      MOZ_ENABLE_WAYLAND = 1;
      HYPRLAND_CURSOR_SIZE = "48";
      PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
    };
    etc."tsocks.conf".text = ''
      server = 127.0.0.1
      server_port = 1080
      server_type = 5
    '';
    systemPackages = with pkgs; [
      tryx-panorama-manager
      # winboat  # Temporarily disabled: Go 1.26.1 mingw cross-compilation broken
      freerdp
      pkg-config
      vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      wget
      v4l-utils    # provides v4l2-ctl
      ffmpeg
      bubblewrap
      worktrunk
      socat
      # roc  # Temporarily disabled: failing tests
      claude-code
      pnpm
      obs-studio
      kdePackages.kdenlive
      antigravity-cli
      bun
      coreutils
      busybox
      # biglybt  # Temporarily disabled: swt dependency is broken
      gnugrep
      gawk
      nix-ld
      sqlcmd
      tree
      openconnect
      dbeaver-bin
      openvpn
      gnumake
      uv
      marp-cli
      gtk3
      qt5.qtbase
      qt5.qtwayland
      terraform-ls
      adwaita-qt
      (maven.override { jdk_headless = jdk25_headless; })
      google-chrome
      # (google-chrome.override {
      #   commandLineArgs = [
      #     "--disable-webusb-security"
      #   ];
      # })
      valkey
      clickhouse
      beam28Packages.elixir_1_20
      beam28Packages.elixir-ls
      lxappearance
      php
      herdr
      aws-sam-cli
      (clojure.override { jdk = jdk25; })
      clojure-lsp
      clj-kondo
      postgresql
      tsocks
      fwupd
      terraform
      ssm-session-manager-plugin
      jq
      libz
      libxext
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
      privoxy
      dig
      scala
      metals
      sbt
      bun
      qemu
      lldb
      firefox
      wireguard-tools
      vista-fonts
      corefonts
      helix
      openssl
      openssl.dev
      waylock
      hypridle
      hyprlock
      file
      obsidian
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
      (python314.withPackages (ps: with ps; [ marimo numpy polars scikit-learn ]))
      # python311Packages.pip
      # python311Packages.python-lsp-server
      # python311Packages.python-lsp-ruff
      # python311Packages.pylsp-mypy
      # (python311.withPackages (ps: with ps; [ numpy boto3 awsiotpythonsdk ]))
      pyright
      black
      ruff
      rustup
      # cargo
      # # ARM64 standard library for cross-compilation
      # pkgsCross.aarch64-multiplatform.stdenv.cc
      # # Cross-compilation support for Rust
      # pkgsCross.aarch64-multiplatform.rustc
      mosquitto
      expressvpn
      julia-bin
      ghc
      ocaml
      opam
      kdePackages.sddm
      awww
      # xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
      xdg-desktop-portal
      xdg-desktop-portal-wlr
      xdg-utils
      ssm-session-manager-plugin
      pavucontrol
      pipewire
      lshw
      hyprcursor
      zig_0_17
      zls
      mesa-demos
      brightnessctl
      pulseaudio
      pamixer
      playerctl
      cava
      xev
      evtest
      gcc13
      stdenv.cc.cc.lib
      jdk25
      # kdePackages.xwaylandvideobridge
      marksman
      zoom-us
      tailwindcss
      tailwindcss-language-server
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
      # cargo-nextest
      # cargo-spellcheck
      # cargo-modules
      # cargo-bloat
      # cargo-unused-features
      # cargo-lambda
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
      typescript-language-server
      # nodePackages.eslint
      typescript
      # vscode-langservers-extracted
      # nodePackages.webpack  # Removed: should be imported in JS projects, not as system package
      bash-language-server
      awscli2
      aws-cdk-cli
      man
      zip
      # Add all the libraries Playwright needs
      glib
      nss
      nspr
      dbus
      atk
      at-spi2-atk
      cups
      expat
      libxcb
      libxkbcommon
      libx11
      libxcomposite
      libxdamage
      libxext
      libxfixes
      libxrandr
      mesa
      cairo
      pango
      systemd
      alsa-lib
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
      icu
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
      powerManagement.enable = true;
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
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Tailscale: reach this machine (herdr --remote) from work without port-forwarding
  services.tailscale.enable = true;

  # Enable Redis server
  systemd.services.valkey = {
    description = "Valkey Server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    
    serviceConfig = {
      Type = "notify";
      ExecStart = "${pkgs.valkey}/bin/valkey-server /etc/valkey/valkey.conf";
      Restart = "always";
      User = "valkey";
      Group = "valkey";
      RuntimeDirectory = "valkey";
      StateDirectory = "valkey";
      WorkingDirectory = "/var/lib/valkey";
    };
  };

  users.users.valkey = {
    isSystemUser = true;
    group = "valkey";
    description = "Valkey server user";
  };

  users.groups.valkey = {};

  environment.etc."valkey/valkey.conf".text = ''
    bind 127.0.0.1
    port 6379
    dir /var/lib/valkey

    # The unit above is Type=notify, so valkey must send READY=1 over
    # NOTIFY_SOCKET or systemd times out the start job and restarts forever.
    supervised systemd
    
    # Add any other config you need:
    # requirepass yourpassword
    # maxmemory 256mb
    # maxmemory-policy allkeys-lru
  '';
  # services.valkey = {
  #   servers."".enable = true;
  # };

  # Enable QuestDB
  systemd.services.questdb = {
    description = "QuestDB Time Series Database";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      # questdb.jar is built for class file version 69 (Java 25); jdk17/jdk21
      # fail with UnsupportedClassVersionError. Keep in sync with the JDK the
      # nixpkgs questdb wrapper uses.
      ExecStart = "${pkgs.jdk25}/bin/java -jar ${pkgs.questdb}/share/java/questdb.jar -d /var/lib/questdb";
      Restart = "on-failure";
      User = "questdb";
      Group = "questdb";
      StateDirectory = "questdb";
      WorkingDirectory = "/var/lib/questdb";
    };
  };

  users.users.questdb = {
    isSystemUser = true;
    group = "questdb";
    description = "QuestDB service user";
  };

  users.groups.questdb = {};

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
