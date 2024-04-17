
variable "project" {
  description = "The Google Cloud project ID"
  type        = string
}

variable "region" {
  description = "The region where the resources will be created"
  type        = string
}

variable "bucket_name" {
  description = "The name of the GCS bucket to create"
  type        = string
}

variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "The branch in the GitHub repository to trigger builds from"
  type        = string
  default     = "^main$"
}
