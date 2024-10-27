terraform {
  required_providers {
    google-beta = {
      source = "hashicorp/google-beta"
      version = "~> 6.8.0"
    }
  }
}

provider "google-beta" {
  project = "airflow-lab-439902"
  region  = "us-central1"
}

resource "google_project_service" "composer_api" {
  provider = google-beta
  project = "airflow-lab-439902"
  service = "composer.googleapis.com"
  // Disabling Cloud Composer API might irreversibly break all other
  // environments in your project.
  disable_on_destroy = false
  // this flag is introduced in 5.39.0 version of Terraform. If set to true it will
  //prevent you from disabling composer_api through Terraform if any environment was
  //there in the last 30 days
  check_if_service_has_usage_on_destroy = true
}

resource "google_composer_environment" "airflow_lab" {
  provider = google-beta
  name = "airflow-lab"

  config {

    // Add your environment configuration here

    software_config {
      image_version = "composer-3-airflow-2.9.3-build.3"
    }

  }
}

resource "google_composer_environment" "airflow_lab_dev" {
  provider = google-beta
  name = "airflow-lab-dev"

  config {

    // Add your environment configuration here

    software_config {
      image_version = "composer-3-airflow-2.9.3-build.3"
    }

  }
}

# Currently creating connections from Terraform is not supported?
# resource "google_cloudbuildv2_connection" "github-connection" {
#   name = "github-connection"
#   project  = "airflow-lab-439902"
#   location = "us-central1"

#   github_config {
#     authorizer_credential {
#       oauth_token_secret_version = "projects/352517100677/secrets/github-connection-github-oauthtoken-d6231b/versions/1"
#     }
#   }
# }

resource "google_cloudbuildv2_repository" "gihub-repo" {
  provider = google-beta
  name = "airflow-lab"
  project  = "airflow-lab-439902"
  location = "us-central1"
  parent_connection = "github-connection"
  remote_uri = "https://github.com/0903lokchan/airflow-lab.git"
}

# /generate create a service account suitable for Cloud Build
resource "google_service_account" "cloudbuild-sa" {
  provider = google-beta
  account_id = "cloudbuild-sa"
  display_name = "Cloud Build Service Account"
  project = "airflow-lab-439902"

  disabled = false
}


resource "google_cloudbuild_trigger" "test-dags" {
  provider = google-beta
  name     = "test-dags"
  description = "Perform unit tests on the DAGs before they are deployed to Composer."
  project  = "airflow-lab-439902"
  location = "us-central1"

  repository_event_config {
    repository = google_cloudbuildv2_repository.gihub-repo.id
    pull_request {
      branch = "^main$"
      comment_control = "COMMENTS_ENABLED_FOR_EXTERNAL_CONTRIBUTORS_ONLY"
    }
  }
  filename = "/cloud_builds/test-dags.cloudbuild.yaml"
  service_account = google_service_account.cloudbuild-sa.id
}
