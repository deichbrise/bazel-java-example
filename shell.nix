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
    ];

    shellHook = ''

        function setup() {

            alias kubectl='minikube kubectl'
            alias skaffoldx='./.skaffoldx'
            . <(minikube completion bash)
            . <(helm completion bash)

            minikube start -p technilog-platform --kubernetes-version=v1.22.15
            minikube addons enable ingress -p technilog-platform
            kubectl apply -k github.com/zalando/postgres-operator/manifests
            kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/master/bundle.yaml
            kubectl create namespace kafka
            kubectl create -f 'https://strimzi.io/install/latest?namespace=kafka' -n kafka

            git clone https://github.com/keycloak/keycloak-operator.git
            kubectl apply -f keycloak-operator/deploy/crds/
            kubectl create namespace keycloak-operator
            kubectl apply -f keycloak-operator/deploy/role.yaml -n keycloak-operator
            kubectl apply -f keycloak-operator/deploy/role_binding.yaml -n keycloak-operator
            kubectl apply -f keycloak-operator/deploy/service_account.yaml -n keycloak-operator
            kubectl apply -f keycloak-operator/deploy/operator.yaml -n keycloak-operator
            rm -rf keycloak-operator

            git clone https://github.com/rook/rook.git

            kubectl create -f rook/deploy/examples/crds.yaml
            kubectl create -f rook/deploy/examples/common.yaml
            kubectl create -f rook/deploy/examples/operator.yaml
            kubectl create -f rook/deploy/examples/cluster.yaml

            rm -rf rook

            source <(minikube docker-env -p technilog-platform)

            skaffold config set --kube-context technilog-platform local-cluster true
        }
      '';
}
