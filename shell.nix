with import <nixpkgs>{};

stdenv.mkDerivation {
    name = "psc-platform";

    src = fetchurl {
        url = "https://download.garden.io/core/0.12.45/garden-0.12.45-macos-amd64.tar.gz";
        sha256 = "86a1ab4dde75be1f325be05e2c44a5c09ed4192b14597fb80b0cca8b2e8d13f0";
      };

    nativeBuildInputs = [
        bazel_5
        openjdk11
        maven
        awscli
        kubectl
        kubernetes-helm
        k9s
        git
        minikube
        jq
        skaffold
        python3
        terraform
        kube3d
	unrar
    ];
}
