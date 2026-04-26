# Solution: Use Data Sources

## What the validator checks

- Expected to find: data "local_file" "source_config"
- Expected to find: data "local_file" "source_version"
- Expected to find: resource "local_file" "combined"
- Expected to find: data.local_file.source_config
- Expected to find: data.local_file.source_version
- terraform plan shows pending changes — your config may be incomplete

## Solution

```hcl
data "local_file" "source_config" {
  filename = "${path.module}/source/config.txt"
}

resource "local_file" "combined" {
  content  = data.local_file.source_config.content
  filename = "${path.module}/combined.txt"
}
```
