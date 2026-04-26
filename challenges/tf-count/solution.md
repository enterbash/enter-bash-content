# Solution: Use Count Meta-Argument

## Solution

```hcl
variable "environments" {
  type    = list(string)
  default = ["dev", "staging", "prod"]
}

resource "local_file" "config" {
  count    = length(var.environments)
  content  = "environment=${var.environments[count.index]}\n"
  filename = "${path.module}/config-${var.environments[count.index]}.txt"
}
```

```bash
terraform plan  # should show 3 resources to create
terraform apply -auto-approve
ls *.txt
```

## Why this works

`count` creates multiple instances of a resource. `count.index` is the current iteration (0, 1, 2...). Access the list with `var.environments[count.index]`.
