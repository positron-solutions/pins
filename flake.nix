{
  description = "Centrally pinned inputs for our projects.";
  inputs  = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    systems.url = "github:nix-systems/default";
    crane.url = "github:ipetkov/crane";

    # TODO vendor this.  Upstream is tracking nixpkgs master.  This leads to
    # dispersion between our nixpkgs and the lib version used by flake-parts.
    # At least it is pinned.
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
    flake-parts = {
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
      url = "github:hercules-ci/flake-parts";
    };
  };

  # Most of this flake is used by referencing the inputs above rather than
  # declaring any real outputs.  However, the outputs can be used, as below, to
  # expose things like overlays for downstream projects.
  outputs = inputs: {
    # You can use overlays within pinning to gather up overrides of packages.
    # Just pass in the overlays when instantiating the nixpkgs for a project and
    # it will have the packages available.
    overlays.default = final: prev: {
      # cargo leptos versions and wasm bindgen versions must upgrade
      # together.  This override can be used in individual project shells to
      # temporarilly decouple that project
      cargo-leptos-2-28 = prev.rustPlatform.buildRustPackage rec {
        pname = "cargo-leptos";
        version = "0.2.28";

        src = prev.fetchFromGitHub {
          owner = "leptos-rs";
          repo = "cargo-leptos";
          rev = "v${version}";
          hash = "sha256-SjpfM963Zux+H5QhK8prvDLuI56fP5PqX5gcVbthRx4=";
        };

        cargoHash = if prev.stdenv.isDarwin
        then "sha256-Da9ei4yAOfhSQmQgrUDZCmMeJXTfGnYhI1+L0JT/ECs="
        else "sha256-7nFDftc468mB3TbnKbEb5xEYEQzTtgFaX6uWodmLwRI=";

        buildInputs = prev.lib.optionals prev.stdenv.isDarwin [
          prev.darwin.apple_sdk.frameworks.SystemConfiguration
          prev.darwin.apple_sdk.frameworks.Security
          prev.darwin.apple_sdk.frameworks.CoreServices
        ];

        buildFeatures = [ "no_downloads" ];
        doCheck = false;

        meta = with prev.lib; {
          description = "Build tool for the Leptos web framework";
          mainProgram = "cargo-leptos";
          homepage = "https://github.com/leptos-rs/cargo-leptos";
          license = [ licenses.mit ];
        };
      };
    };
  };
}
