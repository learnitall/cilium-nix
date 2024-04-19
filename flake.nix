{
  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs-stable, nixpkgs-unstable }:
  let
    system = "x86_64-linux";
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
    };
    pkgs = import nixpkgs-stable {
      inherit system;
      overlays = [
        (final: prev: {
          # Grab latest version of go from unstable.
          buildGoModule = pkgs-unstable.buildGoModule;
        })
      ];
    };

    cilium-all = pkgs.buildGoModule {
      pname = "cilium";
      version = "main";
      src = pkgs.fetchFromGitHub {
        owner = "cilium";
        repo = "cilium";
        rev = "v1.15.4";
        githubBase = "github.com";
        sha256 = "sha256-dHdpVXTHLh7UjBXgKMeM0l8Dl555zY8IN65nEtbtycA=";
      };
      doCheck = false;
      vendorHash = null;
    };

    pwd = builtins.getEnv "PWD";
    iptablesWrapper = builtins.readFile "${pwd}/iptables-wrapper-installer.sh";

    runtime = pkgs.dockerTools.buildImage {
      name = "cilium-runtime";
      tag = "latest";
      copyToRoot = pkgs.buildEnv {
        name = "image-root";
        paths = with pkgs; [
          bpftool
          clang
          cni-plugins
          gops
          iptables
          llvmPackages.libllvm
        ];
        pathsToLink = [ "/bin" "/sbin" ];
      };
      runAsRoot = ''
        #!{pkgs.runtimeShell}
        set -x
        ${iptablesWrapper}
      '';
    };

    agent = pkgs.dockerTools.buildImage {
      name = "cilium-agent";
      tag = "latest";
      fromImage = runtime;
      runAsRoot = ''
        #!{pkgs.runtimeShell}
        set -x
        cp ${cilium-all}/bin/daemon /bin/cilium-agent
        cp ${cilium-all}/bin/cilium-dbg /bin/cilium-dbg
      '';

      diskSize = 4096;
    };
  in {
    containers."${system}" = {
      inherit runtime agent;
    };
    packages."${system}" = {
      inherit cilium-all;
    };
  };
}


