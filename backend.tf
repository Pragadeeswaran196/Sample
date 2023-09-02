terraform {
  backend "s3" {
    region = "us-east-1"
    bucket = "fk-prod-env-terraformstate"
    key    = "techops/jenkins-testing"
  }
}
