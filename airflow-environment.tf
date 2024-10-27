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
