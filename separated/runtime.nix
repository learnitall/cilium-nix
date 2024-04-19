{
  pkgs,
  tag
}:
let
  iptablesWrapper = builtins.readFile "/home/rydrew/Documents/cilium-nix/iptables-wrapper-installer.sh";
in
pkgs.dockerTools.buildImage {
  inherit tag;

  name = "cilium-runtime";
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
    #!${pkgs.runtimeShell}
    set -x
    ${iptablesWrapper}
  '';
}
