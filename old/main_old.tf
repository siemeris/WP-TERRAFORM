provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# Crear una VPC
resource "google_compute_network" "vpc_network" {
  name = "my-vpc" 
  auto_create_subnetworks = false 
}

# Crear la subred dentro de la VPC
resource "google_compute_subnetwork" "vpc_subnet" {
  name          = "my-subnet"
  network       = google_compute_network.vpc_network.self_link
  ip_cidr_range = "10.0.0.0/24"
}

# Habilitar la API de VPC Access
resource "google_project_service" "vpcaccess-api" {
  project = var.project_id
  service = "vpcaccess.googleapis.com"
}

# Crear el conector de Acceso a VPC sin servidores
module "serverless-connector" {
  source     = "terraform-google-modules/network/google//modules/vpc-serverless-connector-beta"
  version    = "~> 9.0"
  project_id = var.project_id
  vpc_connectors = [{
    name          = "central-serverless"
    region        = var.region
    subnet_name   = google_compute_subnetwork.vpc_subnet.name
    machine_type  = "e2-standard-4"
    min_instances = 2
    max_instances = 7
  }]
  depends_on = [
    google_project_service.vpcaccess-api
  ]
}

# Cloud Run service
resource "google_cloud_run_v2_service" "wordpress" {
  project     = var.project_id
  name        = "wordpress-service"
  location    = var.region

  template {
    containers {
      image = "gcr.io/${var.project_id}/wp-repo/wordpress:latest"
      env {
        name  = "CLOUD_SQL_CONNECTION_NAME"
        value = google_sql_database_instance.my_instance.connection_name
      }
    }

    vpc_access {
      connector = module.serverless-connector.connector.id
      egress    = "ALL_TRAFFIC"
    }
  }

  traffic {
    percent         = 100
  }
}

# Crear el repositorio en Artifact Registry
resource "google_artifact_registry_repository" "docker_repo" {
  repository_id = "wp-repo"
  location      = "europe-southwest1"
  format        = "DOCKER"
}

# Crear el trigger de Cloud Build para GitHub para construir la imagen de Docker
resource "google_cloudbuild_trigger" "github_trigger" {
  name         = "github-trigger"
  description  = "Trigger for building Docker image from GitHub repository"
  github {
    owner      = var.owner
    name       = var.repository_name
    push {
      branch = var.branch_name
    }
  }
  filename     = "cloudbuild.yaml"  # Archivo de configuración de Cloud Build
}

# Crear una instancia de Cloud SQL con una IP privada y conexión de servicios privados
resource "google_sql_database_instance" "my_instance" {
  name                = "my-sql-instance"
  region              = var.region
  project             = var.project_id
  database_version    = "MYSQL_5_7"
  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc_network.self_link
    }
  }
}

