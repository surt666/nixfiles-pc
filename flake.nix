{

  description = "my flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs"; 
  };

  outputs = { self, nixpkgs, hyprland, home-manager, rust-overlay, ... } @ inputs:
    let
      user = "sla";
      system = "x86_64-linux";
      # pkgs = import nixpkgs {
      #   inherit system;
      #   config.allowUnfree = true;
      # };
      lib = nixpkgs.lib;
      # This is where we sync the versions
      # kernelPackages = pkgs.linuxPackages_latest;
      # nvidiaPackage = kernelPackages.nvidiaPackages.stable;
    in {
      nixosConfigurations = {
        nixos = lib.nixosSystem {
          inherit system;
          specialArgs = { inherit user inputs ; }; #kernelPackages nvidiaPackage
          modules = [ 
            {
              nixpkgs.config.allowUnfree = true;
              nixpkgs.overlays = [ rust-overlay.overlays.default ];
            }
            ./configuration.nix 
            ({ pkgs, ... }: {
            environment.systemPackages = [ pkgs.rust-bin.stable.latest.default ];
            })
            hyprland.nixosModules.default
            {
              programs.hyprland = {
                enable = true;
                xwayland = {
                  enable = true;
                };
                package = inputs.hyprland.packages.${system}.hyprland;
                portalPackage =inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland; 
              };
            }
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";  
              home-manager.extraSpecialArgs = {inherit user inputs;};
              home-manager.users.${user} = import ./home.nix;
            }
          ];
        };
      };
    };
}
