# Target del Cloud Deploy, destino del despliegue
resource "google_clouddeploy_target" "cloud_run_target" {
  name     = "cloud-run-target"
  project  = var.project_id
  location = var.region

  #COnfiguramos como se ejecutan las operaciones de despliegue esepecificando un WorkerPool
  execution_configs {
    worker_pool = "projects/${var.project_id}/locations/${var.region}/workerPools/default"
    usages = ["RENDER", "DEPLOY"]
  }
}

resource "google_clouddeploy_delivery_pipeline" "pipeline" {
  depends_on = [google_clouddeploy_target.cloud_run_target]  # Asegura que el target se crea primero
  name     = "sample-pipeline"
  project  = var.project_id
  location = var.region

  serial_pipeline {
    stages {
      target_id = google_clouddeploy_target.cloud_run_target.name  #Usar solo el nombre del target, no la ID completa
    }
  }
}


## La cuenta de servicio utilizada por cloud build no tiene los permisos necesarios
# para acceder al pipeline de entrega. Por lo tanto, necesitamos otorgarle los permisos necesarios.
data "google_project" "project" {
  project_id = var.project_id
}

resource "google_project_iam_member" "cloud_build_cloud_deploy_viewer" {
  project = data.google_project.project.project_id
  role    = "roles/clouddeploy.viewer"
  member  = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

## asignamos los roles Cloud Run Admin y Service Account User 
## a la cuenta de servicio de Cloud Build usando el número del proyecto:
resource "google_project_iam_member" "cloud_run_admin" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

resource "google_project_iam_member" "service_account_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}
