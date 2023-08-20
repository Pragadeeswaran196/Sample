terraform {
  required_providers {
    chronosphere = {
      version = "0.37.0"
      source   = "tf-registry.chronosphere.io/chronosphere/chronosphere"
    }
  }
}

provider "chronosphere" {
    org = "fourkites"
}
