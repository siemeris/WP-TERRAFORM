# Habilitar la API de Cloud Build
resource "google_project_service" "cloudbuild" {
  project = var.project_id
  service = "cloudbuild.googleapis.com"
}

# Habilitar la API de Artifact Registry
resource "google_project_service" "artifact_registry" {
  project = var.project_id
  service = "artifactregistry.googleapis.com"
}

# Habilitar la API de Service Usage necesaria para Terraform
resource "google_project_service" "serviceusage" {
  project = var.project_id
  service = "serviceusage.googleapis.com"
}

# Habilitar servicios
resource "google_project_service" "compute" {
  project = var.project_id
  service = "compute.googleapis.com"
}

resource "google_project_service" "sqladmin" {
  project = var.project_id
  service = "sqladmin.googleapis.com"
}

resource "google_project_service" "run" {
  project = var.project_id
  service = "run.googleapis.com"
}

resource "google_project_service" "cloudresourcemanager" {
  project = var.project_id
  service = "cloudresourcemanager.googleapis.com"
}

resource "google_project_service" "vpcaccess" {
  project = var.project_id
  service = "vpcaccess.googleapis.com"
}

resource "google_project_service" "servicenetworking" {
  project = var.project_id
  service = "servicenetworking.googleapis.com"
}

resource "google_project_service" "clouddeploy" {
  project = var.project_id
  service = "clouddeploy.googleapis.com"
}

resource "google_project_service" "secretmanager" {
  project = var.project_id
  service = "secretmanager.googleapis.com"
}

resource "google_project_service" "dns" {
  project = var.project_id
  service = "dns.googleapis.com"
}

resource "google_project_service" "cloudfunctions" {
  project = var.project_id
  service = "cloudfunctions.googleapis.com"
}

resource "google_project_service" "cloudscheduler" {
  project = var.project_id
  service = "cloudscheduler.googleapis.com"
}