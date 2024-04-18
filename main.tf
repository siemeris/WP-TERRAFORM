provider "google" {
  project = var.project_id
  region  = var.region
}

# Crear el repositorio en Artifact Registry para almacenar imágenes de Docker
resource "google_artifact_registry_repository" "docker_repo" {
  repository_id = "wp-repo"
  location      = "europe-southwest1"
  format        = "DOCKER"
}

# Crear el trigger de Cloud Build para GitHub para construir la imagen de Docker
# Reacciona a cambios en el repositorio, construyendo una imagen Docker cada 
# vez que se hace un push a la rama especificada
# En el .yaml las especificaciones del build
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

# Servicio de Cloud Run
resource "google_cloud_run_service" "default" {
  name     = "my-wordpress-app"
  location = "europe-southwest1"

  template {
    spec {
      containers {
        image = "europe-southwest1-docker.pkg.dev/${var.project_id}/wp-repo/wp-img:latest"
        #image = "europe-southwest1-docker.pkg.dev/${var.project_id}/wp-repo/wp-img:${SHORT_SHA}"
        #image = "gcr.io/${var.project_id}/wp-repo/wp-img:latest"

        resources {
          limits = {
            cpu    = "1"
            memory = "1Gi"
          }
        }

        ports {
          container_port = 80  # Puerto actualizado a 80
        }
        
        # Añadir aquí las variables de entorno si son necesarias
        env {
          name  = "DB_HOST"
          value = "db.cloudsql.internal" # Para la config del DNS
          # value = ":/cloudsql/${var.project_id}:${var.region}:my-wordpress-db"
        }
        env {
          name  = "DB_NAME"
          value = "wordpress"
        }
        env {
          name  = "DB_USER"
          value = "wp_user"
        }
        env {
          name  = "DB_PASSWORD"
          value = "${google_secret_manager_secret_version.db_password_version.secret_data}"
          # value = "sm://${google_secret_manager_secret.db_password.id}/latest"
        }
      }
    }

    #Configuramos conexiones específicas: Conector VPC, y la instancia de CLoud SQL
    metadata {
        annotations = {
            "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.vpc_connector.name
            "run.googleapis.com/cloudsql-instances" = "${var.project_id}:${var.region}:my-wordpress-db"
        }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  autogenerate_revision_name = true
}

# Quien puede invocar el servicio de Cloud Run
# Configurar el invocador (IAM) para el servicio Cloud Run
resource "google_cloud_run_service_iam_member" "invoker" {
  service  = google_cloud_run_service.default.name
  location = google_cloud_run_service.default.location
  role     = "roles/run.invoker"
  member   = "allUsers"  # Cambiar según los requisitos de seguridad
}

##Creamos instancia de Cloud SQL para MySQL, con ip Privada
resource "google_sql_database_instance" "mysql_instance" {
  name             = "my-wordpress-db"
  region           = var.region
  database_version = "MYSQL_8_0"

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.private_network.self_link
    }
  }
  # Asegura que la red se crea primero
  # Importante establecer el peering de VPC necesario para que Cloud SQL use una IP privada.
  depends_on = [
    google_compute_network.private_network,
    google_service_networking_connection.private_vpc_connection
  ]
}

resource "google_sql_database" "wordpress_database" {
  name     = "wordpress"
  instance = google_sql_database_instance.mysql_instance.name
}

# Crear el usuario de la base de datos con la contraseña almacenada en Secret Manager
resource "google_sql_user" "wordpress_user" {
  name     = "wp_user"
  instance = google_sql_database_instance.mysql_instance.name
  password = google_secret_manager_secret_version.db_password_version.secret_data
}

### Configuramos una red VPC y un conector de VPC para Cloud Run
resource "google_compute_network" "private_network" {
  name = "wordpress-private-network"
  auto_create_subnetworks = true # Esto crea automáticamente una subred en cada región
}

# Acceso a VPC sin servidores, permite que los servicios de Cloud Run 
# accedan a los recursos de la VPC   
resource "google_vpc_access_connector" "vpc_connector" {
  name          = "wordpress-vpc-connector"
  region        = var.region
  network       = google_compute_network.private_network.name
  ip_cidr_range = "10.8.0.0/28"
}

## Configurar el Peering de VPC
## Reservo un rango de direcciones IP para el peering
resource "google_compute_global_address" "private_ip_range" {
  name          = "my-private-ip-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.private_network.self_link
}

## Creo una conexión de servicio
#Una vez reservado el rango de IP, establezco una conexión de servicio 
# Esto habilita el peering de VPC entre tu red y los servicios de Google.
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.private_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]
}
