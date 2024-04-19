{ buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "cilium-agent";
  version = "main";

  src = fetchFromGitHub {
    owner = "cilium";
    repo = "cilium";
    rev = "main";
    githubBase = "github.com";
    sha256 = "sha256-pYQQ5fL8zXdEd4+QwdKeraNOb5koKIs12dNueIiI5f8=";
  };

  doCheck = false;
  vendorHash = null;
  
}
