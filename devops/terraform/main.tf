provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "my-kubernetes-dashboard" {

  name = "my-kubernetes-dashboard"

  repository = "https://kubernetes.github.io/dashboard/"
  chart      = "kubernetes-dashboard"
  namespace  = "default"

  set {
    name  = "service.type"
    value = "NodePort"
  }

  set {
    name  = "protocolHttp"
    value = "true"
  }

  set {
    name  = "service.externalPort"
    value = 80
  }

  set {
    name  = "replicaCount"
    value = 2
  }

  set {
    name  = "rbac.clusterReadOnlyRole"
    value = "true"
  }
}
