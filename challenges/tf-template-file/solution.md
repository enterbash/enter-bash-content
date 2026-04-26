# Solution: Use the templatefile Function

## Solution

```hcl
# config.tftpl (already created by setup)
# Application Configuration
# [general]
# name = "${app_name}"
# ...

resource "local_file" "config" {
  content = templatefile("${path.module}/config.tftpl", {
    app_name       = "myapp"
    app_port       = 8080
    app_env        = "production"
    max_connections = 100
    enable_ssl     = false
    ports          = [80, 443, 8080]
  })
  filename = "${path.module}/app.conf"
}
```

## Why this works

`templatefile(path, vars)` renders a `.tftpl` file with the given variables. It's more readable than inline heredocs for complex templates. The template uses `${var}` for interpolation and `%{ for/if }` for control flow.
