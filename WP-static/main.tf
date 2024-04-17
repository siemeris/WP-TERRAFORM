provider "google" {
  project     = var.project
  region      = var.region
}

# Crear un bucket de Google Cloud Storage para el sitio web estático
resource "google_storage_bucket" "static_site_bucket" {
  name          = var.bucket_name
  location      = var.region
  force_destroy = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }

  cors {
    origin          = ["*"]
    method          = ["GET"]
    response_header = ["Content-Type"]
    max_age_seconds = 3600
  }

  uniform_bucket_level_access = true
}

# Hacer que el bucket sea accesible públicamente
resource "google_storage_bucket_iam_binding" "bucket_public" {
  bucket = google_storage_bucket.static_site_bucket.name
  role   = "roles/storage.objectViewer"
  members = [
    "allUsers",
  ]
}

# Configurar Google Cloud Build para desplegar desde GitHub
resource "google_cloudbuild_trigger" "github_trigger" {
  project = var.project
  name    = "deploy-static-site"
  description = "Build and deploy static site on push"
  filename = "cloudbuild.yaml"

  included_files = ["**"]

  substitutions = {
    "_BUCKET_NAME" = var.bucket_name
  }

  github {
    owner = var.github_owner
    name  = var.github_repo

    push {
      branch = var.github_branch
    }
  }
}

output "website_url" {
  value       = "https://storage.googleapis.com/${google_storage_bucket.static_site_bucket.name}/"
  description = "The URL of the hosted static site"
}
