{
  description = "ROS overlay for the Nix package manager";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    livox-sdk.url = "github:purepani/Livox-SDK";
    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay";
    nixpkgs.url = "github:lopsided98/nixpkgs/nix-ros";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    nix-ros-overlay,
    livox-sdk,
  }: let
    system = "x86_64-linux";
    livox_distro_overaly = final: prev: {
      livox-driver = prev.callPackage ./package.nix {
        livox_sdk = livox-sdk.packages.${system}.default;
      };
    };
    ros-overlay = self: super: {
      rosPackages =
        super.rosPackages
        // {
          noetic = super.rosPackages.noetic.overrideScope livox_distro_overaly;
        };
    };
    pkgs = import nix-ros-overlay.inputs.nixpkgs {
      inherit system;
      overlays = [
        nix-ros-overlay.overlays.default
        ros-overlay
      ];
    };
  in {
    #nixpkgs.overlays = [nix-ros-overlay.overlay];
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs;
      with rosPackages.noetic;
      with pythonPackages; [
        glibcLocales
        (buildEnv
          {
            paths = [
              rosbash
              livox-driver
            ];
          })
      ];
      ROS_HOSTNAME = "localhost";
      ROS_MASTER_URI = "http://localhost:11311";
    };
    overlays.${system}.default = ros-overlay;
    packages.${system}.default = pkgs.rosPackages.noetic.livox-driver;

    nixConfig = {
      extra-substituters = ["https://cache.nixos.org" "https://ros.cachix.org"];
      extra-trusted-public-keys = ["cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo="];
    };
  };
}
