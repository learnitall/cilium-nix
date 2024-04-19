{
  cilium,
  runtime,
  pkgs,
}:
pkgs.dockerTools.buildImage {
  name = "cilium-agent";
  tag = "latest";

  fromImage = runtime;
  copyToRoot = pkgs.buildEnv {
    name = "image-root";
    path = [
      "${cilium}/bin/cilium"
    ];
    pathsToLink = [ "/bin" ];
  };
}
