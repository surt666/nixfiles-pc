{

  description = "my flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # rust-overlay.url = "github:oxalica/rust-overlay";
    # Pin to stable commit from Dec 18 before --watchdog-fd breakage
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?rev=315806f59816aacdbf7c66aaeaa0e49d3a33a66d&submodules=1";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, hyprland, home-manager, ... } @ inputs:
    let
      user = "sla";
      system = "x86_64-linux";
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
              nixpkgs.overlays = [
                # rust-overlay.overlays.default
                # Fix aws-sam-cli: skip tests and runtime dep checks
                (final: prev: {
                  aws-sam-cli = prev.aws-sam-cli.overridePythonAttrs (old: {
                    doCheck = false;
                    dontCheckRuntimeDeps = true;
                  });
                })
              ];
            }
            ./configuration.nix
            # ({ pkgs, ... }: {
            # environment.systemPackages = [ pkgs.rust-bin.stable.latest.default ];
            # })
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
