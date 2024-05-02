{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    # TIP: Replace 'nixos' with hostname
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit system; };
      modules = [
        ./hosts/thinkpaw/configuration.nix
        ./modules/video-acceleration.nix
        ./modules/desktop.nix
        ./modules/docker.nix
      ];
    };
    homeConfigurations.yonei = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ ./home-manager/default.nix ];
    };
  };
}
