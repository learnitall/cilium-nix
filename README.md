# cilium-nix

Experiment to build cilium-agent docker containers using nix.

The build process for cilium images is very complex and has a lot of layers to it.
This is a minimal starting point for creating an image with the cilium-agent and cilium-dbg binaries.
It probably won't work.

## Building

Runtime image:

```bash
nix build --impure .#containers.x86_64-linux.runtime
```

All cilium binaries:


```bash
nix build --impure .#packages.x86_64-linux.cilium-all
```

A cilium-agent image:

```bash
nix build --impure .#containers.x86_64-linux.agent
```

Importing an image:

```
docker load < result
```

