terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# TODO: Add data sources to read from source/config.txt and source/version.txt
# TODO: Create a local_file resource named "combined" that writes both contents
