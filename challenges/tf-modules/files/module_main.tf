# This module creates a config file for an application
# TODO: Define the required variables and resources

# Variable: app_name (string, no default)
# Variable: environment (string, no default)

# Resource: local_file "config"
#   content: "app=<app_name>\nenv=<environment>"
#   filename: "${path.module}/<app_name>-<environment>.txt"

# Output: config_path - the filename of the created file
