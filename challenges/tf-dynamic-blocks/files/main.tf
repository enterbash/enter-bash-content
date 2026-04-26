terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

variable "provisioner_commands" {
  type = list(object({
    command     = string
    working_dir = string
  }))
  default = [
    {
      command     = "echo 'step1' >> ${path.module}/log.txt"
      working_dir = "."
    },
    {
      command     = "echo 'step2' >> ${path.module}/log.txt"
      working_dir = "."
    },
    {
      command     = "echo 'step3' >> ${path.module}/log.txt"
      working_dir = "."
    }
  ]
}

# TODO: Use a dynamic block to generate local-exec provisioners
# from the var.provisioner_commands list
resource "null_resource" "multi_step" {
  # Replace the hardcoded provisioners with a dynamic block
  provisioner "local-exec" {
    command = "echo 'step1' >> log.txt"
  }
  provisioner "local-exec" {
    command = "echo 'step2' >> log.txt"
  }
  provisioner "local-exec" {
    command = "echo 'step3' >> log.txt"
  }
}
