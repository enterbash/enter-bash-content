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

resource "random_pet" "pets" {
  count     = 3
  length    = 2
  separator = "-"
}

resource "local_file" "pet_files" {
  count    = 3
  content  = "pet=${random_pet.pets[count.index].id}"
  filename = "${path.module}/pet-${count.index}.txt"
}

# TODO: Add the following outputs using splat expressions:
# output "all_pet_names" - list of all pet IDs: random_pet.pets[*].id
# output "all_file_paths" - list of all filenames: local_file.pet_files[*].filename

# TODO: Create a local_file "summary" that joins all pet names with newlines
# content = join("\n", random_pet.pets[*].id)
# filename = "${path.module}/summary.txt"
