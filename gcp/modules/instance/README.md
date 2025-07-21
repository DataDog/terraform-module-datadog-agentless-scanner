# Instance Module

This module creates a Google Cloud Managed Instance Group (MIG) for running Datadog Agentless Scanner instances.

## Resources Created

- **Instance Template**: Defines the configuration for instances in the group
- **Health Check**: TCP health check on port 22 for auto-healing
- **Managed Instance Group**: Zonal MIG that manages instance lifecycle and auto-healing

## Features

- Auto-healing with configurable health checks
- Rolling updates with recreate strategy
- Configurable instance count
- Automatic startup script execution for scanner installation
- SSH access configuration

## Usage

```hcl
module "instance" {
  source = "./modules/instance"

  project_id             = var.project_id
  region                 = var.region
  zone                   = var.zone
  network_name           = var.network_name
  subnetwork_name        = var.subnetwork_name
  service_account_email  = google_service_account.compute_instance_sa.email
  
  api_key               = var.api_key
  site                  = var.site
  ssh_public_key        = var.ssh_public_key
  ssh_username          = var.ssh_username
  instance_count        = var.instance_count
  scanner_version       = var.scanner_version
  scanner_channel       = var.scanner_channel
  scanner_repository    = var.scanner_repository
}
```

## Requirements

- Google Cloud Compute API must be enabled
- Network and subnetwork must exist
- Service account must be created with appropriate permissions
- Startup script template is included in the module at `startup-script.sh.tftpl` 