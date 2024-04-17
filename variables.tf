variable "project_id" {
  description = "ID del proyecto de Google Cloud"
}

variable "region" {
  description = "Región de Google Cloud donde se desplegarán los recursos"
}

variable "owner" {
  description = "Owner of the GitHub repository"
}

variable "repository_name" {
  description = "Name of the GitHub repository"
}

variable "branch_name" {
  description = "Branch name for Cloud Build trigger"
}

variable "function_bucket_name" {
  description = "Nombre del bucket de Cloud Storage para la función"
}