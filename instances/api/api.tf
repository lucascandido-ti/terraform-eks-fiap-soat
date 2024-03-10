provider "kubernetes" {
  host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_ca_certificate)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

data "aws_ecr_repository" "repository" {
  name = "tech-challenge-api"
}

data "aws_ecr_image" "image" {
  repository_name = data.aws_ecr_repository.repository.name
  image_tag       = "latest"
}

output "image_uri" {
  value = "${data.aws_ecr_repository.repository.repository_url}@${data.aws_ecr_image.image.image_digest}"
}

data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

resource "kubernetes_namespace" "api" {
  metadata {
    name = "api"
  }
}


resource "kubernetes_config_map" "apiConfigMap" {
  metadata {
    name      = "api-settings"
    namespace = kubernetes_namespace.api.metadata[0].name
  }

  data = {
    "settings.json" : jsondecode({
      api = {
        port   = "3000",
        prefix = "api",
        cache = {
          max = 1000,
          ttl = 60
        },
        throttler = {
          limit = 1000,
          ttl   = 60
        }
      },
      workers = {
        payment = {
          cronTime = "*/1 * * * *"
        }
      },
      db = {
        postgres = {
          type     = "postgres",
          host     = "svc-tech-challenge-db",
          port     = "5432",
          database = "postgres",
          username = "postgres",
          password = "root"
        }
      }
    })
  }
}

resource "kubernetes_deployment" "apiDeployment" {
  metadata {
    name      = "tech-challenge-api-deployment"
    namespace = kubernetes_namespace.api.metadata[0].name
  }

  spec {
    template {
      metadata {
        name = "tech-challenge-api-deployment"
        labels = {
          app = "tech-challenge-api-deployment"
        }
      }
      spec {
        container {
          name  = "tech-challenge-api-deployment"
          image = data.aws_ecr_image.image.image_uri
          port {
            container_port = 3000
          }
          env {
            name = "MY_SETTINGS"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.apiConfigMap.metadata.name
                key  = "settings.json"
              }
            }
          }
          liveness_probe {
            http_get {
              path = "/api/category"
              port = 3000
            }
            period_seconds        = 10
            failure_threshold     = 3
            initial_delay_seconds = 20
          }
          readiness_probe {
            http_get {
              path = "/api/category"
              port = 3000
            }
            period_seconds        = 10
            failure_threshold     = 5
            initial_delay_seconds = 3
          }
          resources {
            limits = {
              memory : "512Mi"
            }
          }
        }
      }
    }
    replicas = 1
    selector {
      match_labels = {
        app : "tech-challenge-api-deployment"
      }
    }
  }
}


resource "kubernetes_horizontal_pod_autoscaler_v2" "apiHpa" {
  metadata {
    name      = "tech-challenge-api-hpa"
    namespace = kubernetes_namespace.api.metadata[0].name
  }

  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.dbDeployment.metadata.name
    }
    min_replicas = 1
    max_replicas = 10
    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 30
        }
      }
    }
  }
}


resource "kubernetes_service" "apiService" {
  metadata {
    name = "svc-tech-challenge-api"
    labels = {
      app : "svc-tech-challenge-api"
    }
    namespace = kubernetes_namespace.api.metadata[0].name
  }
  spec {
    selector = {
      app = kubernetes_deployment.apiDeployment.metadata.name
    }
    type = "LoadBalancer"
    port {
      port        = 80
      protocol    = "TCP"
      target_port = 3000
    }
  }
}
