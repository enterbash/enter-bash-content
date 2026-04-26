# Solution: Create Output Values

## Solution

```hcl
resource "random_pet" "server" {
  length = 2
}

resource "local_file" "config" {
  content  = "server=${random_pet.server.id}\n"
  filename = "${path.module}/config.txt"
}

resource "random_integer" "priority" {
  min = 1
  max = 100
}

output "pet_name" {
  description = "The generated server name"
  value       = random_pet.server.id
}

output "config_path" {
  description = "Path to the config file"
  value       = local_file.config.filename
}

output "random_number" {
  description = "A random priority number"
  value       = random_integer.priority.result
}
```

```bash
terraform apply -auto-approve
terraform output
```

## Why this works

Outputs expose values after `apply`. They're useful for passing data between modules or displaying important information. `description` is required by best practices.
