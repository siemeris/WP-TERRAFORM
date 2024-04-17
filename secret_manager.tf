# Definir el Secret en Google Cloud Secrets Manager
resource "google_secret_manager_secret" "db_password" {
  secret_id = "db-password"
  replication {
    user_managed {
      replicas {
        location = "europe-west1"
      }
    }
  }
}

# Añadir la versión del Secret con la contraseña de la base de datos
resource "google_secret_manager_secret_version" "db_password_version" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = "your-password-here"
}