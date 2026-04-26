# Solution: Use the templatefile Function

## What the validator checks

- Expected to find: templatefile
- Expected to find: config\.tftpl
- Expected to find: app_name
- Expected to find: environment
- Expected to find: ports
- terraform plan shows pending changes — your config may be incomplete

## Solution

```hcl
resource "local_file" "config" {
  content = templatefile("${path.module}/config.tftpl", {
    app_name        = "myapp"
    app_port        = 8080
    app_env         = "production"
    max_connections = 100
    enable_ssl      = false
    ports           = [80, 443, 8080]
  })
  filename = "${path.module}/app.conf"
}
```

`templatefile()` renders a `.tftpl` file with Jinja2-like syntax.
