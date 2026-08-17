locals {
  name_prefix = "${var.project}-${var.environment}-${var.location_abbr}"

  common_tags = {
    project     = var.project
    environment = var.environment
    owner       = var.owner
    managed_by  = "terraform"
  }
}