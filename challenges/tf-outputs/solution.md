# Solution: Create Output Values

## What the validator checks

- Expected to find: output 
- Expected to find: output 
- Expected to find: output 
- pet_name output should reference random_pet.server.id
- config_path output should reference local_file.config.filename
- random_number output should reference random_integer.priority.result
- random_number output should have a description
- terraform plan shows pending changes — your config may be incomplete

## Solution

```hcl
resource "random_pet" "server" { length = 2 }
resource "local_file" "config" {
  content  = "server=${random_pet.server.id}\n"
  filename = "${path.module}/config.txt"
}
resource "random_integer" "priority" { min = 1; max = 100 }

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
