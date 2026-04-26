terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# TODO: Create the following random resources:
# 1. random_pet "app_name" - length 3, separator "-"
# 2. random_integer "port" - min 3000, max 9000
# 3. random_password "db_password" - length 16, special = true
# 4. random_uuid "request_id"

# TODO: Create a local_file "config" that uses all four values
# filename: "${path.module}/config.txt"
# content should include app_name, port, password, and uuid
