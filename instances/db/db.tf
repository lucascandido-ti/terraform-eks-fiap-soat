provider "kubernetes" {
  host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_ca_certificate)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

data "aws_ecr_repository" "repository" {
  name = "tech-challenge-db"
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

resource "kubernetes_namespace" "db" {
  metadata {
    name = "db"
  }
}

resource "kubernetes_config_map" "dbConfigMap" {
  metadata {
    name      = "db-configmap"
    namespace = kubernetes_namespace.db.metadata[0].name
  }

  data = {
    POSTGRES_DB       = "postgres"
    POSTGRES_USER     = "postgres"
    POSTGRES_PASSWORD = "root"
  }
}

resource "kubernetes_persistent_volume" "dbPV" {
  metadata {
    name = "local-storage"
  }

  spec {
    storage_class_name = "manual"
    capacity = {
      storage = "1Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      host_path {
        path = "/opt/data/postgres"
        type = "DirectoryOrCreate"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "dbPVC" {
  metadata {
    name      = "postgres-pvc"
    namespace = kubernetes_namespace.db.metadata[0].name
  }

  spec {
    storage_class_name = "manual"
    access_modes       = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "dbDeployment" {
  metadata {
    name      = "tech-challenge-db-deployment"
    namespace = kubernetes_namespace.db.metadata[0].name
  }

  spec {
    template {
      metadata {
        name = "tech-challenge-db-deployment"
        labels = {
          app = "tech-challenge-db-deployment"
        }
      }
      spec {
        container {
          name              = "tech-challenge-db-deployment"
          image             = data.aws_ecr_image.image.image_uri
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 5432
          }
          volume_mount {
            mount_path = "/var/lib/postgresql/data"
            name       = "postgresdb"
          }
          env_from {
            config_map_ref {
              name = kubernetes_config_map.dbConfigMap.metadata.name
            }
          }
          resources {
            limits = {
              memory : "512Mi"
            }
          }
        }
        volume {
          name = "postgresdb"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.dbPVC.metadata.name
          }
        }
      }
    }
    replicas = 1
    selector {
      match_labels = {
        app : "tech-challenge-db-deployment"
      }
    }
  }
}

resource "kubernetes_service" "dbService" {
  metadata {
    name = "svc-tech-challenge-db"
    labels = {
      app : "svc-tech-challenge-db"
    }
    namespace = kubernetes_namespace.db.metadata[0].name
  }
  spec {
    port {
      port        = 5432
      target_port = 5432
    }
    selector = kubernetes_deployment.dbDeployment.metadata.name
  }
}


