## CLOUD FUNCTION 
resource "google_storage_bucket" "function_bucket" {
  location = "EU"
  # name = "ism-function-bucket"
  name = var.function_bucket_name
}

resource "google_storage_bucket_object" "function_zip" {
  name   = "function.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = "${path.module}/function.zip"
}

resource "google_cloudfunctions_function" "check-cloud-run-instances" {
  name                  = "stopCloudSQLInstance"
  description           = "Checks Cloud Run instances and stops Cloud SQL if no instances are running"
  runtime               = "nodejs10"  # Consider upgrading to a newer version of Node.js
  project               = var.project_id
  region                = "europe-west1"  // PErmission deied on locations/europe-southwest1
  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.function_zip.name
  trigger_http          = true
  entry_point           = "stopCloudSQLInstance"
}

#Persmisos rol de invocador para la función
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = var.project_id
  region         = "europe-west1"
  cloud_function = google_cloudfunctions_function.check-cloud-run-instances.name
  role           = "roles/cloudfunctions.invoker"
  member         = "serviceAccount:${var.project_id}@appspot.gserviceaccount.com"
}

#Permisos rol de desarrollador para la función
resource "google_project_iam_member" "cloud_functions_developer" {
  project = var.project_id
  role    = "roles/cloudfunctions.developer"
  member  = "serviceAccount:${var.project_id}@appspot.gserviceaccount.com"
}

### CLOUD SCHEDULER
resource "google_cloud_scheduler_job" "scheduler_job" {
  region   = "europe-west1"
  name     = "check-cloud-run-instances"
  schedule = "*/15 * * * *"

  http_target {
    uri         = google_cloudfunctions_function.check-cloud-run-instances.https_trigger_url
    http_method = "GET"
    oidc_token {
      service_account_email = google_service_account.scheduler_account.email
    }
  }
}

resource "google_service_account" "scheduler_account" {
  account_id   = "scheduler-account"
  display_name = "Scheduler Service Account"
}

resource "google_project_iam_member" "cloud_scheduler_admin" {
  project = var.project_id
  role    = "roles/cloudscheduler.admin"
  member  = "serviceAccount:${google_service_account.scheduler_account.email}"
}

resource "google_project_iam_member" "cloud_scheduler_invoker" {
  project = var.project_id
  role    = "roles/cloudfunctions.invoker"
  member  = "serviceAccount:${google_service_account.scheduler_account.email}"
}













# # Cloud Function
# resource "google_cloudfunctions_function" "check_cloud_run" {
#   name        = "check-cloud-run-instances"
#   description = "Function to check Cloud Run instances and stop Cloud SQL if none."
#   runtime     = "nodejs10"  # Asegúrate de elegir un runtime compatible

#   available_memory_mb = 128
#   timeout             = 60
#   entry_point         = "stopCloudSQLInstance"

#   source_archive_bucket = google_storage_bucket.function_source.name
#   source_archive_object = google_storage_bucket_object.function_source.name

#   trigger_http = true

#   event_trigger {
#     event_type = "providers/cloud.scheduler/eventTypes/scheduler.job.execute"
#     resource   = google_cloud_scheduler_job.scheduler_job.name
#   }
# }

# # Cloud Scheduler para activar la función regularmente
# resource "google_cloud_scheduler_job" "scheduler_job" {
#   name     = "check-cloud-run-job"
#   schedule = "*/30 * * * *"  # Cada 30 minutos

#   http_target {
#     http_method = "GET"
#     url         = google_cloudfunctions_function.check_cloud_run.https_trigger_url
#   }
# }

# # Permisos para que Cloud Function acceda a Cloud SQL y Cloud Run
# resource "google_cloudfunctions_function_iam_binding" "invoker" {
#   project        = var.project_id
#   region         = google_cloudfunctions_function.check_cloud_run.region
#   cloud_function = google_cloudfunctions_function.check_cloud_run.name
#   role           = "roles/cloudfunctions.invoker"
#   members        = [
#     "serviceAccount:YOUR_CLOUD_SCHEDULER_SERVICE_ACCOUNT"
#   ]
# }
