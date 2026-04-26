# Enter Bash Content

Public challenge repository for [Enter Bash](https://enter-bash.pages.dev) — a hands-on DevOps & Cloud learning platform.

## Structure

```
challenges/
├── fix-broken-nginx/
│   ├── challenge.yaml      # Challenge definition
│   ├── validate.sh         # Validation script
│   └── files/              # Files copied into the lab container
│       ├── setup.sh
│       └── broken-nginx.conf
├── debug-file-permissions/
│   └── ...
└── docker-container-networking/
    └── ...
```

## Challenge Schema

Each challenge directory must contain a `challenge.yaml`:

```yaml
name: "Human-readable name"
type: skill | project
category: linux | kubernetes | docker | terraform | ansible | cicd
difficulty: easy | medium | hard
tags: [tag1, tag2]
time_estimate: "15m"
xp_reward: 100
packages: [apt-packages-to-install]
pre_install: []
namespace: ""
files:
  - source: files/some-file
    dest: /path/in/container
    executable: false
    cleanup: false
setup:
  - shell commands to run after files are copied
instructions: |
  Markdown instructions shown to the learner
hints:
  - "Progressive hints revealed one at a time"
validation:
  script: validate.sh
  success_message: "Shown on pass"
  failure_message: "Shown on fail"
```

## Contributing

1. Fork this repo
2. Create a new directory under `challenges/`
3. Add `challenge.yaml`, `validate.sh`, and any files needed
4. Submit a PR

### Validation Script Rules

- Must exit `0` on success, non-zero on failure
- Should print a human-readable message
- Runs inside the learner's container as the `learner` user
