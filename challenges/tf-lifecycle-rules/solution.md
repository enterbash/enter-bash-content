# Solution: Configure Lifecycle Rules

## Solution

```hcl
resource "local_file" "config" {
  content  = "app=myapp\nversion=1.0\n"
  filename = "${path.module}/config.txt"

  lifecycle {
    create_before_destroy = true   # create new before destroying old
    prevent_destroy       = false  # set true to protect critical resources
    ignore_changes        = [content]  # don't update if content changes externally
  }
}

resource "random_pet" "name" {
  lifecycle {
    create_before_destroy = true
  }
}
```

## Why this works

`lifecycle` blocks customize resource behavior. `create_before_destroy` prevents downtime during replacement. `prevent_destroy` protects critical resources. `ignore_changes` prevents drift detection for specified attributes.
