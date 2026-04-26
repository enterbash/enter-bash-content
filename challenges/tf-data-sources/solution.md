# Solution: Use Data Sources

## Solution

```hcl
# Read existing files as data sources
data "local_file" "source_config" {
  filename = "${path.module}/source/config.txt"
}

data "local_file" "source_version" {
  filename = "${path.module}/source/version.txt"
}

# Use the data in a resource
resource "local_file" "combined" {
  content  = "config=${data.local_file.source_config.content}version=${data.local_file.source_version.content}"
  filename = "${path.module}/combined.txt"
}
```

## Why this works

Data sources read existing infrastructure without managing it. `data.local_file.name.content` accesses the file contents. Data sources are read during `plan`, before any resources are created.
